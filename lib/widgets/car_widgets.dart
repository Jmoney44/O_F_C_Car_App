import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/car.dart';
import '../providers.dart';
import 'common.dart';

/// A car photo, or a neutral placeholder when there is none or it fails.
class CarImage extends StatelessWidget {
  const CarImage({super.key, required this.url, this.iconSize = 48});

  final String? url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.directions_car_filled_outlined,
          size: iconSize,
          color: scheme.outline,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}

class CarStatusBadge extends StatelessWidget {
  const CarStatusBadge({super.key, required this.status});

  final CarStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: status.label,
      tone: switch (status) {
        CarStatus.available => Tone.success,
        CarStatus.reserved => Tone.warning,
        CarStatus.sold => Tone.danger,
      },
    );
  }
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoriteIdsProvider).value?.contains(carId) ?? false;
    final userId = ref.watch(userIdProvider);
    return IconButton.filledTonal(
      tooltip: isFavorite ? 'Remove from saved' : 'Save this car',
      visualDensity: VisualDensity.compact,
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Colors.redAccent : null,
      onPressed: userId == null
          ? null
          : () => runGuarded(
              context,
              () => ref
                  .read(repositoriesProvider)
                  .favorites
                  .setFavorite(
                    userId: userId,
                    carId: carId,
                    favorite: !isFavorite,
                  ),
            ),
    );
  }
}

/// The standard car tile used on the home, browse and saved screens.
class CarCard extends StatelessWidget {
  const CarCard({super.key, required this.car, this.width});

  final Car car;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: () => context.push('/car/${car.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CarImage(url: car.coverImage),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(carId: car.id),
                    ),
                    if (!car.isAvailable)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: CarStatusBadge(status: car.status),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatKm(car.mileageKm)} · ${car.transmission.label} · ${car.fuelType.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatMoney(car.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact row with a thumbnail, used in order, offer and admin lists.
class CarListTile extends StatelessWidget {
  const CarListTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.footer,
    this.onTap,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 84,
                      height: 64,
                      child: CarImage(url: imageUrl, iconSize: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              if (footer != null) ...[const SizedBox(height: 12), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
