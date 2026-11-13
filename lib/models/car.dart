import '../core/formatters.dart';

enum BodyType {
  sedan('Sedan'),
  suv('SUV'),
  coupe('Coupe'),
  convertible('Convertible'),
  hatchback('Hatchback'),
  pickup('Pickup'),
  van('Van'),
  wagon('Wagon');

  const BodyType(this.label);
  final String label;
}

enum FuelType {
  petrol('Petrol'),
  diesel('Diesel'),
  hybrid('Hybrid'),
  electric('Electric');

  const FuelType(this.label);
  final String label;
}

enum Transmission {
  automatic('Automatic'),
  manual('Manual');

  const Transmission(this.label);
  final String label;
}

enum CarCondition {
  brandNew('New'),
  used('Used');

  const CarCondition(this.label);
  final String label;
}

enum CarStatus {
  available('Available'),
  reserved('Reserved'),
  sold('Sold');

  const CarStatus(this.label);
  final String label;
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

class Car {
  const Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.mileageKm,
    required this.bodyType,
    required this.fuelType,
    required this.transmission,
    required this.condition,
    required this.color,
    this.description = '',
    this.imageUrls = const [],
    this.status = CarStatus.available,
    this.featured = false,
    this.createdAt,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  final int price;
  final int mileageKm;
  final BodyType bodyType;
  final FuelType fuelType;
  final Transmission transmission;
  final CarCondition condition;
  final String color;
  final String description;
  final List<String> imageUrls;
  final CarStatus status;
  final bool featured;
  final DateTime? createdAt;

  String get title => '$year $make $model';
  String? get coverImage => imageUrls.isEmpty ? null : imageUrls.first;
  bool get isAvailable => status == CarStatus.available;

  factory Car.fromMap(String id, Map<String, dynamic> map) {
    return Car(
      id: id,
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: (map['year'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toInt() ?? 0,
      mileageKm: (map['mileageKm'] as num?)?.toInt() ?? 0,
      bodyType: _enumByName(BodyType.values, map['bodyType'], BodyType.sedan),
      fuelType: _enumByName(FuelType.values, map['fuelType'], FuelType.petrol),
      transmission: _enumByName(
        Transmission.values,
        map['transmission'],
        Transmission.automatic,
      ),
      condition: _enumByName(
        CarCondition.values,
        map['condition'],
        CarCondition.used,
      ),
      color: map['color'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? const []),
      status: _enumByName(CarStatus.values, map['status'], CarStatus.available),
      featured: map['featured'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  /// Everything except [createdAt], which the data layer stamps itself.
  Map<String, dynamic> toMap() => {
    'make': make,
    'model': model,
    'year': year,
    'price': price,
    'mileageKm': mileageKm,
    'bodyType': bodyType.name,
    'fuelType': fuelType.name,
    'transmission': transmission.name,
    'condition': condition.name,
    'color': color,
    'description': description,
    'imageUrls': imageUrls,
    'status': status.name,
    'featured': featured,
  };

  Car copyWith({
    String? id,
    List<String>? imageUrls,
    CarStatus? status,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      make: make,
      model: model,
      year: year,
      price: price,
      mileageKm: mileageKm,
      bodyType: bodyType,
      fuelType: fuelType,
      transmission: transmission,
      condition: condition,
      color: color,
      description: description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      featured: featured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
