import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../models/car_order.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

Tone orderTone(OrderStatus status) => switch (status) {
  OrderStatus.pending => Tone.warning,
  OrderStatus.confirmed || OrderStatus.completed => Tone.success,
  OrderStatus.cancelled => Tone.danger,
};

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: AsyncView<List<CarOrder>>(
        value: ref.watch(myOrdersProvider),
        onRetry: () => ref.invalidate(myOrdersProvider),
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Cars you reserve will be tracked here.',
              actionLabel: 'Browse cars',
              onAction: () => context.go('/browse'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return CarListTile(
                imageUrl: order.carImage,
                title: order.carTitle,
                subtitle:
                    '${order.code} · ${formatDate(order.createdAt)}\n${formatMoney(order.price)} · ${order.paymentMethod.label}',
                trailing: StatusBadge(
                  label: order.status.label,
                  tone: orderTone(order.status),
                ),
                onTap: () => context.push('/car/${order.carId}'),
                footer: order.status != OrderStatus.pending
                    ? null
                    : Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final yes = await confirmAction(
                              context,
                              title: 'Cancel this reservation?',
                              message:
                                  'Your request for the ${order.carTitle} will be withdrawn.',
                              confirmLabel: 'Cancel reservation',
                            );
                            if (!yes || !context.mounted) return;
                            await runGuarded(
                              context,
                              () => ref
                                  .read(repositoriesProvider)
                                  .orders
                                  .updateStatus(order, OrderStatus.cancelled),
                            );
                          },
                          child: const Text('Cancel reservation'),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
