import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../models/car.dart';
import '../../models/car_filter.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  late final _search = TextEditingController(
    text: ref.read(carFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final cars = ref.read(carsProvider).value ?? const <Car>[];
    final result = await showModalBottomSheet<CarFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        initial: ref.read(carFilterProvider),
        makes: {for (final car in cars) car.make}.toList()..sort(),
        highestPrice: cars.fold(
          0,
          (max, car) => car.price > max ? car.price : max,
        ),
      ),
    );
    if (result != null) ref.read(carFilterProvider.notifier).set(result);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(carFilterProvider);
    final cars = ref.watch(filteredCarsProvider);
    // Another screen (the home shortcuts) may have replaced the filter.
    if (_search.text != filter.query) _search.text = filter.query;

    return Scaffold(
      appBar: AppBar(title: const Text('Browse cars')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onChanged: ref.read(carFilterProvider.notifier).setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search make, model or colour',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: filter.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: () => ref
                                  .read(carFilterProvider.notifier)
                                  .setQuery(''),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Badge(
                  isLabelVisible: filter.activeCount > 0,
                  label: Text('${filter.activeCount}'),
                  offset: const Offset(-4, 4),
                  child: IconButton(
                    tooltip: 'Filters',
                    icon: const Icon(Icons.tune),
                    onPressed: _openFilters,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<List<Car>>(
              value: cars,
              onRetry: () => ref.invalidate(carsProvider),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No cars match',
                    message: 'Try a different search or fewer filters.',
                    actionLabel: 'Clear filters',
                    onAction: () => ref
                        .read(carFilterProvider.notifier)
                        .set(const CarFilter()),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: list.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        '${list.length} ${list.length == 1 ? 'car' : 'cars'} · ${filter.sort.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    }
                    return CarCard(car: list[index - 1]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initial,
    required this.makes,
    required this.highestPrice,
  });

  final CarFilter initial;
  final List<String> makes;
  final int highestPrice;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late CarFilter _filter = widget.initial;

  Widget _group<T>({
    required String title,
    required List<T> options,
    required T? selected,
    required String Function(T) label,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(label(option)),
                selected: option == selected,
                onSelected: (on) => onChanged(on ? option : null),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rounded up so the slider always reaches the dearest car.
    final ceiling = ((widget.highestPrice / 10000).ceil() * 10000)
        .clamp(10000, 1 << 31)
        .toDouble();
    final price = (_filter.maxPrice ?? ceiling).clamp(0, ceiling).toDouble();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, scroll) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    'Filter and sort',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CarSort>(
                    initialValue: _filter.sort,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: [
                      for (final sort in CarSort.values)
                        DropdownMenuItem(value: sort, child: Text(sort.label)),
                    ],
                    onChanged: (sort) =>
                        setState(() => _filter = _filter.copyWith(sort: sort)),
                  ),
                  if (widget.makes.isNotEmpty)
                    _group<String>(
                      title: 'Make',
                      options: widget.makes,
                      selected: _filter.make,
                      label: (make) => make,
                      onChanged: (make) => setState(
                        () => _filter = _filter.copyWith(make: make),
                      ),
                    ),
                  _group<BodyType>(
                    title: 'Body type',
                    options: BodyType.values,
                    selected: _filter.bodyType,
                    label: (type) => type.label,
                    onChanged: (type) => setState(
                      () => _filter = _filter.copyWith(bodyType: type),
                    ),
                  ),
                  _group<CarCondition>(
                    title: 'Condition',
                    options: CarCondition.values,
                    selected: _filter.condition,
                    label: (condition) => condition.label,
                    onChanged: (condition) => setState(
                      () => _filter = _filter.copyWith(condition: condition),
                    ),
                  ),
                  _group<FuelType>(
                    title: 'Fuel',
                    options: FuelType.values,
                    selected: _filter.fuelType,
                    label: (fuel) => fuel.label,
                    onChanged: (fuel) => setState(
                      () => _filter = _filter.copyWith(fuelType: fuel),
                    ),
                  ),
                  _group<Transmission>(
                    title: 'Transmission',
                    options: Transmission.values,
                    selected: _filter.transmission,
                    label: (transmission) => transmission.label,
                    onChanged: (transmission) => setState(
                      () => _filter = _filter.copyWith(
                        transmission: transmission,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _filter.maxPrice == null
                          ? 'Maximum price: any'
                          : 'Maximum price: ${formatMoney(price)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Slider(
                    value: price,
                    max: ceiling,
                    divisions: (ceiling / 5000).round().clamp(1, 400),
                    onChanged: (value) => setState(
                      () => _filter = _filter.copyWith(
                        maxPrice: value >= ceiling ? null : value.round(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                        () => _filter = CarFilter(query: _filter.query),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _filter),
                      child: const Text('Show cars'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
