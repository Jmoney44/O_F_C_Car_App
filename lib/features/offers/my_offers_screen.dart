import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../models/offer.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

Tone offerTone(OfferStatus status) => switch (status) {
  OfferStatus.pending => Tone.warning,
  OfferStatus.accepted => Tone.success,
  OfferStatus.declined => Tone.danger,
};

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My offers')),
      body: AsyncView<List<Offer>>(
        value: ref.watch(myOffersProvider),
        onRetry: () => ref.invalidate(myOffersProvider),
        data: (offers) {
          if (offers.isEmpty) {
            return const EmptyState(
              icon: Icons.handshake_outlined,
              title: 'No offers yet',
              message: 'Open a car and tap "Make an offer" to propose a price.',
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
                    'You offered ${formatMoney(offer.amount)} · listed at ${formatMoney(offer.listPrice)}\n${formatDate(offer.createdAt)}',
                trailing: StatusBadge(
                  label: offer.status.label,
                  tone: offerTone(offer.status),
                ),
                onTap: () => context.push('/car/${offer.carId}'),
                footer:
                    offer.reply.isEmpty && offer.status != OfferStatus.accepted
                    ? null
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (offer.reply.isNotEmpty)
                            Text('Showroom: ${offer.reply}'),
                          if (offer.status == OfferStatus.accepted) ...[
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: () =>
                                  context.push('/car/${offer.carId}/reserve'),
                              child: const Text('Reserve at this price'),
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
