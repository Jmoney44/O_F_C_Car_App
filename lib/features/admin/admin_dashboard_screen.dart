import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/car.dart';
import '../../models/car_order.dart';
import '../../models/offer.dart';
import '../../providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider).value;
    final orders = ref.watch(allOrdersProvider).value;
    final offers = ref.watch(allOffersProvider).value;

    String count<T>(List<T>? list, bool Function(T) test) =>
        list == null ? '–' : '${list.where(test).length}';

    final stats = [
      ('Cars on sale', count<Car>(cars, (c) => c.isAvailable)),
      ('Reserved', count<Car>(cars, (c) => c.status == CarStatus.reserved)),
      (
        'Orders to confirm',
        count<CarOrder>(orders, (o) => o.status == OrderStatus.pending),
      ),
      (
        'Offers to answer',
        count<Offer>(offers, (o) => o.status == OfferStatus.pending),
      ),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin area')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/cars/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add a car'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.9,
            children: [
              for (final (label, value) in stats)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(label, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final (icon, title, subtitle, path) in const [
            (
              Icons.directions_car_outlined,
              'Stock and QR codes',
              'Add, edit and print the code for each car',
              '/admin/cars',
            ),
            (
              Icons.receipt_long_outlined,
              'Orders',
              'Confirm reservations and mark cars as sold',
              '/admin/orders',
            ),
            (
              Icons.handshake_outlined,
              'Offers',
              'Accept or decline price offers',
              '/admin/offers',
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(path),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
