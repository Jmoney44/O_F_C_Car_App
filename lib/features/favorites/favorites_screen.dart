import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/car.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteIdsProvider);
    final cars = ref.watch(carsProvider);
    final saved = switch ((ids, cars)) {
      (AsyncValue(hasValue: true), AsyncValue(hasValue: true)) =>
        AsyncData<List<Car>>([
          for (final car in cars.value!)
            if (ids.value!.contains(car.id)) car,
        ]),
      (AsyncValue(:final error?, :final stackTrace?), _) ||
      (
        _,
        AsyncValue(:final error?, :final stackTrace?),
      ) => AsyncError<List<Car>>(error, stackTrace),
      _ => const AsyncLoading<List<Car>>(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Saved cars')),
      body: AsyncView<List<Car>>(
        value: saved,
        onRetry: () {
          ref.invalidate(favoriteIdsProvider);
          ref.invalidate(carsProvider);
        },
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Nothing saved yet',
              message: 'Tap the heart on a car to keep it here.',
              actionLabel: 'Browse cars',
              onAction: () => context.go('/browse'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => CarCard(car: list[index]),
          );
        },
      ),
    );
  }
}
