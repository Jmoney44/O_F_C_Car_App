import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/app_exception.dart';
import '../../models/app_user.dart';
import '../../models/car.dart';
import '../../models/car_order.dart';
import '../../models/offer.dart';
import '../repositories.dart';

Repositories firebaseRepositories() {
  final firestore = FirebaseFirestore.instance;
  return Repositories(
    auth: FirebaseAuthRepository(FirebaseAuth.instance, firestore),
    cars: FirebaseCarRepository(firestore, FirebaseStorage.instance),
    favorites: FirebaseFavoritesRepository(firestore),
    offers: FirebaseOfferRepository(firestore),
    orders: FirebaseOrderRepository(firestore),
  );
}

typedef _Json = Map<String, dynamic>;

/// Turns Firebase errors into messages a customer can act on.
Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on FirebaseAuthException catch (error) {
    throw AppException(switch (error.code) {
      'invalid-email' => 'That email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Please choose a stronger password.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'No internet connection.',
      _ => 'We could not sign you in. Please try again.',
    });
  } on FirebaseException catch (error) {
    throw AppException(switch (error.code) {
      'permission-denied' => 'You do not have permission to do that.',
      'unavailable' => 'No internet connection.',
      _ => 'Something went wrong. Please try again.',
    });
  }
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<_Json> get _users => _firestore.collection('users');

  @override
  Stream<AppUser?> watchUser() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<_Json>>? profileSub;

    controller = StreamController<AppUser?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((user) {
          profileSub?.cancel();
          if (user == null) {
            controller.add(null);
            return;
          }
          profileSub = _users.doc(user.uid).snapshots().listen((snapshot) {
            controller.add(
              AppUser.fromMap(user.uid, {
                'name': user.displayName ?? '',
                'email': user.email ?? '',
                ...?snapshot.data(),
              }),
            );
          }, onError: controller.addError);
        }, onError: controller.addError);
      },
      onCancel: () async {
        await profileSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);
      // The password is never stored here: Firebase Auth owns it.
      await _users.doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<void> updateProfile({required String name, required String phone}) {
    return _guard(() async {
      final user = _auth.currentUser!;
      await user.updateDisplayName(name);
      await _users.doc(user.uid).set({
        'name': name,
        'phone': phone,
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);
}

class FirebaseCarRepository implements CarRepository {
  FirebaseCarRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<_Json> get _cars => _firestore.collection('cars');

  /// The showroom's whole stock is streamed and filtered on the device. That
  /// keeps search and filters instant and is fine for a single dealer's
  /// inventory; move to server-side queries if stock grows into the thousands.
  @override
  Stream<List<Car>> watchCars() {
    return _cars
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs) Car.fromMap(doc.id, doc.data()),
          ],
        );
  }

  @override
  Future<Car?> getCar(String id) {
    return _guard(() async {
      final doc = await _cars.doc(id).get();
      final data = doc.data();
      return data == null ? null : Car.fromMap(doc.id, data);
    });
  }

  @override
  String newCarId() => _cars.doc().id;

  @override
  Future<String> uploadPhoto({
    required String carId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _guard(() async {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final ref = _storage.ref('cars/$carId/${stamp}_$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return ref.getDownloadURL();
    });
  }

  @override
  Future<void> saveCar(Car car) {
    return _guard(() async {
      final doc = _cars.doc(car.id);
      final exists = (await doc.get()).exists;
      await doc.set({
        ...car.toMap(),
        if (!exists) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> setStatus(String carId, CarStatus status) {
    return _guard(() => _cars.doc(carId).update({'status': status.name}));
  }

  @override
  Future<void> deleteCar(String carId) {
    return _guard(() async {
      await _cars.doc(carId).delete();
      // Photos are removed on a best-effort basis; a leftover file is harmless.
      try {
        final photos = await _storage.ref('cars/$carId').listAll();
        await Future.wait(photos.items.map((item) => item.delete()));
      } on FirebaseException {
        // Ignored on purpose.
      }
    });
  }
}

class FirebaseFavoritesRepository implements FavoritesRepository {
  FirebaseFavoritesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<_Json> _favorites(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  @override
  Stream<Set<String>> watchFavoriteIds(String userId) {
    return _favorites(userId)
        .snapshots()
        .map((snapshot) => {for (final doc in snapshot.docs) doc.id});
  }

  @override
  Future<void> setFavorite({
    required String userId,
    required String carId,
    required bool favorite,
  }) {
    final doc = _favorites(userId).doc(carId);
    return _guard(
      () => favorite
          ? doc.set({'createdAt': FieldValue.serverTimestamp()})
          : doc.delete(),
    );
  }
}

class FirebaseOfferRepository implements OfferRepository {
  FirebaseOfferRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<_Json> get _offers => _firestore.collection('offers');

  List<Offer> _list(QuerySnapshot<_Json> snapshot) => [
    for (final doc in snapshot.docs) Offer.fromMap(doc.id, doc.data()),
  ];

  @override
  Stream<List<Offer>> watchUserOffers(String userId) {
    return _offers
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_list);
  }

  @override
  Stream<List<Offer>> watchAllOffers() {
    return _offers
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_list);
  }

  @override
  Future<void> createOffer(Offer offer) {
    return _guard(
      () => _offers.add({
        ...offer.toMap(),
        'status': OfferStatus.pending.name,
        'reply': '',
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  @override
  Future<void> respond({
    required String offerId,
    required OfferStatus status,
    String reply = '',
  }) {
    return _guard(
      () => _offers.doc(offerId).update({
        'status': status.name,
        'reply': reply,
        'respondedAt': FieldValue.serverTimestamp(),
      }),
    );
  }
}

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<_Json> get _orders => _firestore.collection('orders');

  List<CarOrder> _list(QuerySnapshot<_Json> snapshot) => [
    for (final doc in snapshot.docs) CarOrder.fromMap(doc.id, doc.data()),
  ];

  @override
  Stream<List<CarOrder>> watchUserOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_list);
  }

  @override
  Stream<List<CarOrder>> watchAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_list);
  }

  @override
  Future<void> createOrder(CarOrder order) {
    return _guard(
      () => _orders.add({
        ...order.toMap(),
        'status': OrderStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  @override
  Future<void> updateStatus(CarOrder order, OrderStatus status) {
    return _guard(() async {
      final batch = _firestore.batch();
      batch.update(_orders.doc(order.id), {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final carStatus = carStatusAfter(order, status);
      if (carStatus != null) {
        batch.update(_firestore.collection('cars').doc(order.carId), {
          'status': carStatus.name,
        });
      }
      await batch.commit();
    });
  }
}
