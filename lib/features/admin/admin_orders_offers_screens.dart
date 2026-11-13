import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../models/car_order.dart';
import '../../models/offer.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';
import '../offers/my_offers_screen.dart';
import '../orders/my_orders_screen.dart';

ButtonStyle get _compact =>
    FilledButton.styleFrom(minimumSize: const Size.fromHeight(40));

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    CarOrder order,
    OrderStatus status,
  ) async {
    if (status == OrderStatus.cancelled) {
      final yes = await confirmAction(
        context,
        title: 'Cancel this order?',
        message: order.status == OrderStatus.confirmed
            ? 'The ${order.carTitle} will go back on sale.'
            : '${order.userName}\'s request will be declined.',
        confirmLabel: 'Cancel order',
      );
      if (!yes || !context.mounted) return;
    }
    await runGuarded(
      context,
      () => ref.read(repositoriesProvider).orders.updateStatus(order, status),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: AsyncView<List<CarOrder>>(
        value: ref.watch(allOrdersProvider),
        onRetry: () => ref.invalidate(allOrdersProvider),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final (next, nextLabel) = switch (order.status) {
                OrderStatus.pending => (OrderStatus.confirmed, 'Confirm'),
                OrderStatus.confirmed => (
                  OrderStatus.completed,
                  'Mark as sold',
                ),
                _ => (null, ''),
              };
              return CarListTile(
                imageUrl: order.carImage,
                title: order.carTitle,
                subtitle:
                    '${order.code} · ${formatDate(order.createdAt)} · ${formatMoney(order.price)}',
                trailing: StatusBadge(
                  label: order.status.label,
                  tone: orderTone(order.status),
                ),
                onTap: () => context.push('/car/${order.carId}'),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${order.userName} · ${order.phone}'),
                    Text(
                      '${order.paymentMethod.label} · ${order.fulfilment.label}',
                    ),
                    if (order.address.isNotEmpty) Text('To: ${order.address}'),
                    if (order.note.isNotEmpty) Text('Note: ${order.note}'),
                    if (order.offerId != null)
                      const Text('Price from an accepted offer'),
                    if (next != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: _compact,
                              onPressed: () => _move(
                                context,
                                ref,
                                order,
                                OrderStatus.cancelled,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: _compact,
                              onPressed: () => _move(context, ref, order, next),
                              child: Text(nextLabel),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class AdminOffersScreen extends ConsumerWidget {
  const AdminOffersScreen({super.key});

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    Offer offer,
    OfferStatus status,
  ) async {
    final controller = TextEditingController();
    final accepting = status == OfferStatus.accepted;
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accepting ? 'Accept this offer?' : 'Decline this offer?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${offer.userName} offered ${formatMoney(offer.amount)} for the '
              '${offer.carTitle} (listed at ${formatMoney(offer.listPrice)}).',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 2,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Message to the customer (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(accepting ? 'Accept' : 'Decline'),
          ),
        ],
      ),
    );
    if (reply == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref
          .read(repositoriesProvider)
          .offers
          .respond(offerId: offer.id, status: status, reply: reply),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: AsyncView<List<Offer>>(
        value: ref.watch(allOffersProvider),
        onRetry: () => ref.invalidate(allOffersProvider),
        data: (offers) {
          if (offers.isEmpty) {
            return const EmptyState(
              icon: Icons.handshake_outlined,
              title: 'No offers yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return CarListTile(
                imageUrl: offer.carImage,
                title: offer.carTitle,
                subtitle:
                    'Offer ${formatMoney(offer.amount)} · listed at ${formatMoney(offer.listPrice)}\n${formatDate(offer.createdAt)}',
                trailing: StatusBadge(
                  label: offer.status.label,
                  tone: offerTone(offer.status),
                ),
                onTap: () => context.push('/car/${offer.carId}'),
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${offer.userName} · ${offer.userPhone}'),
                    if (offer.message.isNotEmpty) Text('"${offer.message}"'),
                    if (offer.reply.isNotEmpty)
                      Text('You replied: ${offer.reply}'),
                    if (offer.status == OfferStatus.pending) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: _compact,
                              onPressed: () => _respond(
                                context,
                                ref,
                                offer,
                                OfferStatus.declined,
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: _compact,
                              onPressed: () => _respond(
                                context,
                                ref,
                                offer,
                                OfferStatus.accepted,
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
