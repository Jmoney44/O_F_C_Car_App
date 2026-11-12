import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_luxury/core/car_link.dart';
import 'package:ofc_luxury/core/validators.dart';
import 'package:ofc_luxury/data/repositories.dart';
import 'package:ofc_luxury/models/car.dart';
import 'package:ofc_luxury/models/car_filter.dart';
import 'package:ofc_luxury/models/car_order.dart';

Car _car(
  String id, {
  String make = 'BMW',
  int price = 50000,
  int year = 2022,
  BodyType body = BodyType.sedan,
  CarStatus status = CarStatus.available,
}) {
  return Car(
    id: id,
    make: make,
    model: 'X',
    year: year,
    price: price,
    mileageKm: 1000,
    bodyType: body,
    fuelType: FuelType.petrol,
    transmission: Transmission.automatic,
    condition: CarCondition.used,
    color: 'Black',
    status: status,
  );
}

CarOrder _order(OrderStatus status) => CarOrder(
  id: 'o1',
  code: 'OFC-1',
  carId: 'c1',
  carTitle: 'Car',
  price: 1,
  userId: 'u1',
  userName: 'A',
  userEmail: 'a@b.co',
  phone: '+1234567',
  fulfilment: Fulfilment.pickup,
  paymentMethod: PaymentMethod.bankTransfer,
  status: status,
);

void main() {
  group('CarLink', () {
    test('a generated link parses back to the same id', () {
      expect(CarLink.parse(CarLink.forCar('aB3_x-9Zk2')), 'aB3_x-9Zk2');
    });

    test('accepts links from any domain and bare ids', () {
      expect(CarLink.parse('https://old.example.com/car/abc123?x=1'), 'abc123');
      expect(CarLink.parse('  abc123  '), 'abc123');
    });

    test('rejects text that is not a car code', () {
      expect(CarLink.parse(''), isNull);
      expect(CarLink.parse('https://example.com/'), isNull);
      expect(CarLink.parse('https://example.com/car/'), isNull);
      expect(CarLink.parse('WIFI:S:home;P:secret;;'), isNull);
      expect(CarLink.parse('https://example.com/car/a b'), isNull);
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('jo@ofc.com'), isNull);
      expect(Validators.email('jo@ofc'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('password needs 8 characters', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('numbers', () {
      expect(Validators.positiveInt('0'), isNotNull);
      expect(Validators.positiveInt('12,500'), isNull);
      expect(Validators.nonNegativeInt('0'), isNull);
      expect(Validators.year('1900'), isNotNull);
      expect(Validators.year('${DateTime.now().year}'), isNull);
    });
  });

  group('CarFilter', () {
    final cars = [
      _car('a', make: 'BMW', price: 50000, year: 2020),
      _car('b', make: 'Audi', price: 30000, year: 2023, body: BodyType.suv),
      _car('c', make: 'Audi', price: 90000, status: CarStatus.sold),
      _car('d', make: 'Lexus', price: 70000, status: CarStatus.reserved),
    ];
    List<String> ids(CarFilter filter) =>
        filter.apply(cars).map((car) => car.id).toList();

    test('hides sold cars but keeps reserved ones', () {
      expect(ids(const CarFilter()), unorderedEquals(['a', 'b', 'd']));
    });

    test('filters by make, body type and maximum price', () {
      expect(ids(const CarFilter(make: 'Audi')), ['b']);
      expect(ids(const CarFilter(bodyType: BodyType.suv)), ['b']);
      expect(
        ids(const CarFilter(maxPrice: 50000)),
        unorderedEquals(['a', 'b']),
      );
    });

    test('search matches every word, ignoring case', () {
      expect(ids(const CarFilter(query: 'audi suv')), ['b']);
      expect(ids(const CarFilter(query: 'audi coupe')), isEmpty);
    });

    test('sorts by price', () {
      expect(ids(const CarFilter(sort: CarSort.priceLow)), ['b', 'a', 'd']);
      expect(ids(const CarFilter(sort: CarSort.priceHigh)), ['d', 'a', 'b']);
    });

    test('copyWith can clear a filter', () {
      const filter = CarFilter(make: 'Audi', maxPrice: 1);
      final cleared = filter.copyWith(make: null);
      expect(cleared.make, isNull);
      expect(cleared.maxPrice, 1);
      expect(filter.activeCount, 2);
    });
  });

  test('Car survives a round trip through its stored form', () {
    final car = _car('a', body: BodyType.coupe, status: CarStatus.reserved);
    final copy = Car.fromMap('a', car.toMap());
    expect(copy.title, car.title);
    expect(copy.bodyType, BodyType.coupe);
    expect(copy.status, CarStatus.reserved);
  });

  test('order status drives the car status', () {
    expect(
      carStatusAfter(_order(OrderStatus.pending), OrderStatus.confirmed),
      CarStatus.reserved,
    );
    expect(
      carStatusAfter(_order(OrderStatus.confirmed), OrderStatus.completed),
      CarStatus.sold,
    );
    expect(
      carStatusAfter(_order(OrderStatus.confirmed), OrderStatus.cancelled),
      CarStatus.available,
    );
    // Withdrawing a request that was never confirmed must not touch the car.
    expect(
      carStatusAfter(_order(OrderStatus.pending), OrderStatus.cancelled),
      isNull,
    );
  });
}
