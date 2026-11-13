import 'car.dart';

enum CarSort {
  newest('Newest listings'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  yearNew('Year: newest first'),
  mileageLow('Mileage: lowest first');

  const CarSort(this.label);
  final String label;
}

const _unset = Object();

/// What the customer has typed and picked on the browse screen.
class CarFilter {
  const CarFilter({
    this.query = '',
    this.make,
    this.bodyType,
    this.fuelType,
    this.transmission,
    this.condition,
    this.maxPrice,
    this.sort = CarSort.newest,
  });

  final String query;
  final String? make;
  final BodyType? bodyType;
  final FuelType? fuelType;
  final Transmission? transmission;
  final CarCondition? condition;
  final int? maxPrice;
  final CarSort sort;

  /// Number of filters set, not counting the search text or the sort order.
  int get activeCount => [
    make,
    bodyType,
    fuelType,
    transmission,
    condition,
    maxPrice,
  ].where((value) => value != null).length;

  CarFilter copyWith({
    String? query,
    Object? make = _unset,
    Object? bodyType = _unset,
    Object? fuelType = _unset,
    Object? transmission = _unset,
    Object? condition = _unset,
    Object? maxPrice = _unset,
    CarSort? sort,
  }) {
    return CarFilter(
      query: query ?? this.query,
      make: make == _unset ? this.make : make as String?,
      bodyType: bodyType == _unset ? this.bodyType : bodyType as BodyType?,
      fuelType: fuelType == _unset ? this.fuelType : fuelType as FuelType?,
      transmission: transmission == _unset
          ? this.transmission
          : transmission as Transmission?,
      condition: condition == _unset
          ? this.condition
          : condition as CarCondition?,
      maxPrice: maxPrice == _unset ? this.maxPrice : maxPrice as int?,
      sort: sort ?? this.sort,
    );
  }

  /// Sold cars are never shown to customers.
  List<Car> apply(Iterable<Car> cars) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final result = cars.where((car) {
      if (car.status == CarStatus.sold) return false;
      if (make != null && car.make != make) return false;
      if (bodyType != null && car.bodyType != bodyType) return false;
      if (fuelType != null && car.fuelType != fuelType) return false;
      if (transmission != null && car.transmission != transmission) {
        return false;
      }
      if (condition != null && car.condition != condition) return false;
      if (maxPrice != null && car.price > maxPrice!) return false;
      if (words.isEmpty) return true;
      final haystack =
          '${car.title} ${car.color} ${car.bodyType.label} ${car.fuelType.label}'
              .toLowerCase();
      return words.every(haystack.contains);
    }).toList();

    int byDate(Car a, Car b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    switch (sort) {
      case CarSort.newest:
        result.sort(byDate);
      case CarSort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case CarSort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case CarSort.yearNew:
        result.sort((a, b) => b.year.compareTo(a.year));
      case CarSort.mileageLow:
        result.sort((a, b) => a.mileageKm.compareTo(b.mileageKm));
    }
    return result;
  }
}
