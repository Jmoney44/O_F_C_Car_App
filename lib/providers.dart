import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories.dart';
import 'models/app_user.dart';
import 'models/car.dart';
import 'models/car_filter.dart';
import 'models/car_order.dart';
import 'models/offer.dart';

/// Overridden in `main.dart` with the Firebase or the demo implementation.
final repositoriesProvider = Provider<Repositories>(
  (ref) => throw UnimplementedError('repositoriesProvider was not overridden'),
);

final currentUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(repositoriesProvider).auth.watchUser(),
);

/// The signed-in user's id, or null. Data providers key off this so they
/// reload when a different person signs in.
final userIdProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider).value?.uid,
);

final carsProvider = StreamProvider<List<Car>>(
  (ref) => ref.watch(repositoriesProvider).cars.watchCars(),
);

/// One car out of the live stock list; the data is null when it was removed.
final carProvider = Provider.family<AsyncValue<Car?>, String>((ref, id) {
  return ref
      .watch(carsProvider)
      .whenData((cars) => cars.where((car) => car.id == id).firstOrNull);
});

final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(const {});
  return ref.watch(repositoriesProvider).favorites.watchFavoriteIds(userId);
});

final myOffersProvider = StreamProvider<List<Offer>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(repositoriesProvider).offers.watchUserOffers(userId);
});

final myOrdersProvider = StreamProvider<List<CarOrder>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(repositoriesProvider).orders.watchUserOrders(userId);
});

final allOffersProvider = StreamProvider<List<Offer>>(
  (ref) => ref.watch(repositoriesProvider).offers.watchAllOffers(),
);

final allOrdersProvider = StreamProvider<List<CarOrder>>(
  (ref) => ref.watch(repositoriesProvider).orders.watchAllOrders(),
);

class CarFilterNotifier extends Notifier<CarFilter> {
  @override
  CarFilter build() => const CarFilter();

  void set(CarFilter filter) => state = filter;
  void setQuery(String query) => state = state.copyWith(query: query);
  void clear() => state = CarFilter(query: state.query, sort: state.sort);
}

final carFilterProvider = NotifierProvider<CarFilterNotifier, CarFilter>(
  CarFilterNotifier.new,
);

final filteredCarsProvider = Provider<AsyncValue<List<Car>>>((ref) {
  final filter = ref.watch(carFilterProvider);
  return ref.watch(carsProvider).whenData(filter.apply);
});
