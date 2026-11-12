import 'dart:typed_data';

import '../models/app_user.dart';
import '../models/car.dart';
import '../models/car_order.dart';
import '../models/offer.dart';

/// The app talks to its backend only through these interfaces, so screens
/// work the same against Firebase and against the built-in demo data.
abstract interface class AuthRepository {
  /// Emits the signed-in user (with their profile), or null when signed out.
  Stream<AppUser?> watchUser();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> updateProfile({required String name, required String phone});
  Future<void> signOut();
}

abstract interface class CarRepository {
  Stream<List<Car>> watchCars();
  Future<Car?> getCar(String id);

  /// Reserves an id for a car that has not been saved yet, so its photos can
  /// be uploaded and its QR code generated before the first save.
  String newCarId();
  Future<String> uploadPhoto({
    required String carId,
    required Uint8List bytes,
    required String fileName,
  });
  Future<void> saveCar(Car car);
  Future<void> setStatus(String carId, CarStatus status);
  Future<void> deleteCar(String carId);
}

abstract interface class FavoritesRepository {
  Stream<Set<String>> watchFavoriteIds(String userId);
  Future<void> setFavorite({
    required String userId,
    required String carId,
    required bool favorite,
  });
}

abstract interface class OfferRepository {
  Stream<List<Offer>> watchUserOffers(String userId);
  Stream<List<Offer>> watchAllOffers();
  Future<void> createOffer(Offer offer);
  Future<void> respond({
    required String offerId,
    required OfferStatus status,
    String reply = '',
  });
}

abstract interface class OrderRepository {
  Stream<List<CarOrder>> watchUserOrders(String userId);
  Stream<List<CarOrder>> watchAllOrders();
  Future<void> createOrder(CarOrder order);

  /// Moves an order to [status] and keeps the car's availability in step:
  /// confirmed → reserved, completed → sold, and cancelling a confirmed
  /// order puts the car back on sale.
  Future<void> updateStatus(CarOrder order, OrderStatus status);
}

/// The car status that should follow an order moving to [next], or null when
/// the car should be left as it is.
CarStatus? carStatusAfter(CarOrder order, OrderStatus next) {
  return switch (next) {
    OrderStatus.confirmed => CarStatus.reserved,
    OrderStatus.completed => CarStatus.sold,
    OrderStatus.cancelled =>
      order.status == OrderStatus.confirmed ? CarStatus.available : null,
    OrderStatus.pending => null,
  };
}

class Repositories {
  const Repositories({
    required this.auth,
    required this.cars,
    required this.favorites,
    required this.offers,
    required this.orders,
    this.isDemo = false,
  });

  final AuthRepository auth;
  final CarRepository cars;
  final FavoritesRepository favorites;
  final OfferRepository offers;
  final OrderRepository orders;

  /// True when running on sample data because Firebase is not set up yet.
  final bool isDemo;
}
