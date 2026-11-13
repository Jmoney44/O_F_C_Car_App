import 'dart:async';
import 'dart:typed_data';

import '../../core/app_exception.dart';
import '../../models/app_user.dart';
import '../../models/car.dart';
import '../../models/car_order.dart';
import '../../models/offer.dart';
import '../repositories.dart';

/// Sample data held in memory, used until Firebase is configured and in
/// tests. Nothing is saved between launches.
///
/// Any email and password signs in; an email containing "admin" gets the
/// admin area.
Repositories demoRepositories() {
  final cars = DemoCarRepository();
  return Repositories(
    auth: DemoAuthRepository(),
    cars: cars,
    favorites: DemoFavoritesRepository(),
    offers: DemoOfferRepository(),
    orders: DemoOrderRepository(cars),
    isDemo: true,
  );
}

/// A value that can be watched: new listeners get the current value first.
class _Live<T> {
  _Live(this._value);

  T _value;
  final _changes = StreamController<T>.broadcast();

  T get value => _value;
  set value(T next) {
    _value = next;
    _changes.add(next);
  }

  Stream<T> watch() async* {
    yield _value;
    yield* _changes.stream;
  }
}

int _nextId = 1000;
String _newId(String prefix) => '$prefix${_nextId++}';

class DemoAuthRepository implements AuthRepository {
  final _user = _Live<AppUser?>(null);

  @override
  Stream<AppUser?> watchUser() => _user.watch();

  @override
  Future<void> signIn({required String email, required String password}) async {
    final name = email.split('@').first;
    _user.value = AppUser(
      uid: 'demo-${email.toLowerCase()}',
      name: name.isEmpty ? 'Guest' : name[0].toUpperCase() + name.substring(1),
      email: email,
      phone: '+1 555 0100',
      isAdmin: email.toLowerCase().contains('admin'),
    );
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _user.value = AppUser(
      uid: 'demo-${email.toLowerCase()}',
      name: name,
      email: email,
      phone: phone,
      isAdmin: email.toLowerCase().contains('admin'),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final user = _user.value;
    if (user == null) throw const AppException('You are signed out.');
    _user.value = AppUser(
      uid: user.uid,
      name: name,
      email: user.email,
      phone: phone,
      isAdmin: user.isAdmin,
    );
  }

  @override
  Future<void> signOut() async => _user.value = null;
}

class DemoCarRepository implements CarRepository {
  final _cars = _Live<List<Car>>(_sampleCars());

  @override
  Stream<List<Car>> watchCars() => _cars.watch();

  @override
  Future<Car?> getCar(String id) async {
    for (final car in _cars.value) {
      if (car.id == id) return car;
    }
    return null;
  }

  @override
  String newCarId() => _newId('car');

  @override
  Future<String> uploadPhoto({
    required String carId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    throw const AppException(
      'Photos need Firebase Storage. Connect Firebase to upload.',
    );
  }

  @override
  Future<void> saveCar(Car car) async {
    final existing = _cars.value.where((c) => c.id == car.id).firstOrNull;
    final saved = car.copyWith(
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    _cars.value = [
      saved,
      for (final other in _cars.value)
        if (other.id != car.id) other,
    ];
  }

  @override
  Future<void> setStatus(String carId, CarStatus status) async {
    _cars.value = [
      for (final car in _cars.value)
        car.id == carId ? car.copyWith(status: status) : car,
    ];
  }

  @override
  Future<void> deleteCar(String carId) async {
    _cars.value = _cars.value.where((car) => car.id != carId).toList();
  }
}

class DemoFavoritesRepository implements FavoritesRepository {
  final _byUser = <String, _Live<Set<String>>>{};

  _Live<Set<String>> _for(String userId) =>
      _byUser.putIfAbsent(userId, () => _Live(<String>{}));

  @override
  Stream<Set<String>> watchFavoriteIds(String userId) => _for(userId).watch();

  @override
  Future<void> setFavorite({
    required String userId,
    required String carId,
    required bool favorite,
  }) async {
    final live = _for(userId);
    live.value = favorite
        ? {...live.value, carId}
        : live.value.difference({carId});
  }
}

class DemoOfferRepository implements OfferRepository {
  final _offers = _Live<List<Offer>>([]);

  @override
  Stream<List<Offer>> watchAllOffers() => _offers.watch();

  @override
  Stream<List<Offer>> watchUserOffers(String userId) {
    return _offers.watch().map(
      (offers) => offers.where((offer) => offer.userId == userId).toList(),
    );
  }

  @override
  Future<void> createOffer(Offer offer) async {
    _offers.value = [
      offer.copyWith(id: _newId('offer'), createdAt: DateTime.now()),
      ..._offers.value,
    ];
  }

  @override
  Future<void> respond({
    required String offerId,
    required OfferStatus status,
    String reply = '',
  }) async {
    _offers.value = [
      for (final offer in _offers.value)
        offer.id == offerId
            ? offer.copyWith(status: status, reply: reply)
            : offer,
    ];
  }
}

class DemoOrderRepository implements OrderRepository {
  DemoOrderRepository(this._cars);

  final CarRepository _cars;
  final _orders = _Live<List<CarOrder>>([]);

  @override
  Stream<List<CarOrder>> watchAllOrders() => _orders.watch();

  @override
  Stream<List<CarOrder>> watchUserOrders(String userId) {
    return _orders.watch().map(
      (orders) => orders.where((order) => order.userId == userId).toList(),
    );
  }

  @override
  Future<void> createOrder(CarOrder order) async {
    _orders.value = [
      order.copyWith(id: _newId('order'), createdAt: DateTime.now()),
      ..._orders.value,
    ];
  }

  @override
  Future<void> updateStatus(CarOrder order, OrderStatus status) async {
    final carStatus = carStatusAfter(order, status);
    _orders.value = [
      for (final other in _orders.value)
        other.id == order.id ? other.copyWith(status: status) : other,
    ];
    if (carStatus != null) await _cars.setStatus(order.carId, carStatus);
  }
}

List<Car> _sampleCars() {
  final now = DateTime.now();
  Car car(
    int n,
    String make,
    String model,
    int year,
    int price,
    int km,
    BodyType body,
    FuelType fuel,
    String color,
    String photo, {
    Transmission transmission = Transmission.automatic,
    CarStatus status = CarStatus.available,
    bool featured = false,
  }) {
    return Car(
      id: 'demo-car-$n',
      make: make,
      model: model,
      year: year,
      price: price,
      mileageKm: km,
      bodyType: body,
      fuelType: fuel,
      transmission: transmission,
      condition: km == 0 ? CarCondition.brandNew : CarCondition.used,
      color: color,
      description:
          'A well-kept $year $make $model in $color. Full service history, '
          'inspected by the OFC workshop and ready to drive away.',
      imageUrls: ['assets/demo/$photo.jpg'],
      status: status,
      featured: featured,
      createdAt: now.subtract(Duration(days: n)),
    );
  }

  return [
    car(
      1,
      'Mercedes-Benz',
      'S 580 e',
      2024,
      128000,
      0,
      BodyType.sedan,
      FuelType.hybrid,
      'Emerald Green',
      'mercedes_s580',
      featured: true,
    ),
    car(
      2,
      'Range Rover',
      'SV',
      2023,
      164500,
      12400,
      BodyType.suv,
      FuelType.diesel,
      'Ostuni Pearl White',
      'range_rover',
      featured: true,
    ),
    car(
      3,
      'Porsche',
      '911 Carrera S',
      2022,
      139900,
      18200,
      BodyType.coupe,
      FuelType.petrol,
      'Carrara White',
      'porsche_911',
      featured: true,
    ),
    car(
      4,
      'BMW',
      '750e xDrive',
      2024,
      119700,
      0,
      BodyType.sedan,
      FuelType.hybrid,
      'Oxide Grey',
      'bmw_750e',
    ),
    car(
      5,
      'Lexus',
      'LX 600',
      2023,
      107300,
      21000,
      BodyType.suv,
      FuelType.petrol,
      'Black Onyx',
      'lexus_lx600',
      status: CarStatus.reserved,
    ),
    car(
      6,
      'Bentley',
      'Continental GTC',
      2019,
      219000,
      26500,
      BodyType.convertible,
      FuelType.petrol,
      'Azure Purple',
      'bentley_gtc',
    ),
    car(
      7,
      'Toyota',
      'Land Cruiser 300',
      2024,
      98500,
      0,
      BodyType.suv,
      FuelType.diesel,
      'Pearl White',
      'land_cruiser_300',
    ),
    car(
      8,
      'Audi',
      'RS6 Avant',
      2022,
      124000,
      30100,
      BodyType.wagon,
      FuelType.petrol,
      'Nardo Grey',
      'audi_rs6',
    ),
    car(
      9,
      'Ford',
      'F-150 Raptor',
      2021,
      86900,
      15800,
      BodyType.pickup,
      FuelType.petrol,
      'Velocity Blue',
      'ford_raptor',
    ),
  ];
}
