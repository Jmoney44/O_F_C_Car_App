import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../models/car.dart';
import '../../models/car_filter.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _browse(BuildContext context, WidgetRef ref, CarFilter filter) {
    ref.read(carFilterProvider.notifier).set(filter);
    context.go('/browse');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final cars = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user == null || user.firstName.isEmpty
                  ? 'Welcome'
                  : 'Hello, ${user.firstName}',
            ),
            Text(
              AppConfig.appName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: AsyncView<List<Car>>(
        value: cars,
        onRetry: () => ref.invalidate(carsProvider),
        data: (all) {
          final onSale = const CarFilter().apply(all);
          if (onSale.isEmpty) {
            return const EmptyState(
              icon: Icons.directions_car_outlined,
              title: 'No cars listed yet',
              message: 'New stock will appear here as soon as it is added.',
            );
          }
          final featured = onSale.where((car) => car.featured).toList();
          final bodyTypes = BodyType.values
              .where((type) => onSale.any((car) => car.bodyType == type))
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  readOnly: true,
                  onTap: () => _browse(context, ref, const CarFilter()),
                  decoration: const InputDecoration(
                    hintText: 'Search make, model or colour',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _ScanBanner(onTap: () => context.push('/scan')),
              ),
              if (featured.isNotEmpty) ...[
                const SectionHeader(title: 'Featured'),
                SizedBox(
                  height: 292,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, index) =>
                        CarCard(car: featured[index], width: 280),
                  ),
                ),
              ],
              const SectionHeader(title: 'Browse by body type'),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bodyTypes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => ActionChip(
                    label: Text(bodyTypes[index].label),
                    onPressed: () => _browse(
                      context,
                      ref,
                      CarFilter(bodyType: bodyTypes[index]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Latest arrivals',
                actionLabel: 'See all',
                onAction: () => _browse(context, ref, const CarFilter()),
              ),
              for (final car in onSale.take(5))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: CarCard(car: car),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget {
  const _ScanBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner, size: 40, color: scheme.secondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'At the showroom?',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan the code on any car to see its full details.',
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
