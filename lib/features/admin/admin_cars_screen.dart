import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../models/car.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

class AdminCarsScreen extends ConsumerWidget {
  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock and QR codes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/cars/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add a car'),
      ),
      body: AsyncView<List<Car>>(
        value: ref.watch(carsProvider),
        onRetry: () => ref.invalidate(carsProvider),
        data: (cars) {
          if (cars.isEmpty) {
            return const EmptyState(
              icon: Icons.directions_car_outlined,
              title: 'No cars yet',
              message: 'Add your first car to generate its QR code.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: cars.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarListTile(
                imageUrl: car.coverImage,
                title: car.title,
                subtitle:
                    '${formatMoney(car.price)} · ${formatKm(car.mileageKm)}',
                trailing: CarStatusBadge(status: car.status),
                onTap: () => context.push('/car/${car.id}'),
                footer: Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            context.push('/admin/cars/${car.id}/qr'),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('QR code'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: () =>
                            context.push('/admin/cars/${car.id}/edit'),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
