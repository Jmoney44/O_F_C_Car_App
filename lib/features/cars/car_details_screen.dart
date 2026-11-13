import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/formatters.dart';
import '../../models/car.dart';
import '../../models/offer.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

/// The customer's accepted offer for [carId], if they have one.
final acceptedOfferProvider = Provider.family<Offer?, String>((ref, carId) {
  final offers = ref.watch(myOffersProvider).value ?? const <Offer>[];
  return offers
      .where((o) => o.carId == carId && o.status == OfferStatus.accepted)
      .firstOrNull;
});

Future<void> callShowroom(BuildContext context) async {
  final uri = Uri(scheme: 'tel', path: AppConfig.showroomPhone);
  if (!await launchUrl(uri) && context.mounted) {
    showMessage(context, 'Call us on ${AppConfig.showroomPhone}');
  }
}

/// Where a scanned QR code lands, and where every car tile leads.
class CarDetailsScreen extends ConsumerWidget {
  const CarDetailsScreen({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final car = ref.watch(carProvider(carId));
    return AsyncView<Car?>(
      value: car,
      onRetry: () => ref.invalidate(carsProvider),
      data: (car) {
        if (car == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.no_crash_outlined,
              title: 'This car is no longer listed',
              message: 'It may have been sold or removed from stock.',
              actionLabel: 'Browse other cars',
              onAction: () => context.go('/browse'),
            ),
          );
        }
        return _CarDetails(car: car);
      },
    );
  }
}

class _CarDetails extends ConsumerWidget {
  const _CarDetails({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;
    final accepted = ref.watch(acceptedOfferProvider(car.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            actions: [
              if (isAdmin) ...[
                IconButton(
                  tooltip: 'QR code',
                  icon: const Icon(Icons.qr_code_2),
                  onPressed: () => context.push('/admin/cars/${car.id}/qr'),
                ),
                IconButton(
                  tooltip: 'Edit car',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/admin/cars/${car.id}/edit'),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FavoriteButton(carId: car.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _Gallery(imageUrls: car.imageUrls),
                  // Keeps the back and action buttons readable on any photo.
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.surface.withValues(alpha: 0.85),
                              theme.colorScheme.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    CarStatusBadge(status: car.status),
                    const SizedBox(width: 8),
                    StatusBadge(label: car.condition.label),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  car.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatMoney(car.price),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (accepted != null && car.isAvailable) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.handshake_outlined),
                      title: Text(
                        'Your offer of ${formatMoney(accepted.amount)} was accepted',
                      ),
                      subtitle: const Text(
                        'Reserve now to buy at the agreed price.',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _SpecGrid(car: car),
                if (car.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'About this car',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => callShowroom(context),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call the showroom'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: car.isAvailable
              ? Row(
                  children: [
                    if (accepted == null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/car/${car.id}/offer'),
                          child: const Text('Make an offer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push('/car/${car.id}/reserve'),
                        child: const Text('Reserve'),
                      ),
                    ),
                  ],
                )
              : Text(
                  car.status == CarStatus.sold ? 'This car has been sold.' : 'This car is reserved. Call the showroom to join the waiting list.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.length < 2) return CarImage(url: urls.firstOrNull, iconSize: 72);
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: urls.length,
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: (_, index) => CarImage(url: urls[index], iconSize: 72),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_page + 1} / ${urls.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.calendar_today_outlined, 'Year', '${car.year}'),
      (Icons.speed_outlined, 'Mileage', formatKm(car.mileageKm)),
      (Icons.settings_outlined, 'Transmission', car.transmission.label),
      (Icons.local_gas_station_outlined, 'Fuel', car.fuelType.label),
      (Icons.directions_car_outlined, 'Body', car.bodyType.label),
      (Icons.palette_outlined, 'Colour', car.color),
    ];
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (icon, label, value) in specs)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(icon, color: theme.colorScheme.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: theme.textTheme.bodySmall),
                              Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
