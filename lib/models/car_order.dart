import '../core/formatters.dart';

enum OrderStatus {
  pending('Awaiting confirmation'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;
}

enum Fulfilment {
  pickup('Collect from showroom'),
  delivery('Deliver to my address');

  const Fulfilment(this.label);
  final String label;
}

enum PaymentMethod {
  bankTransfer('Bank transfer'),
  payAtShowroom('Pay at the showroom');

  const PaymentMethod(this.label);
  final String label;
}

/// A customer's request to reserve and buy a car. No money moves in the app:
/// the showroom confirms the reservation and takes payment by the chosen
/// method.
class CarOrder {
  const CarOrder({
    required this.id,
    required this.code,
    required this.carId,
    required this.carTitle,
    required this.price,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.phone,
    required this.fulfilment,
    required this.paymentMethod,
    this.carImage,
    this.offerId,
    this.address = '',
    this.note = '',
    this.status = OrderStatus.pending,
    this.createdAt,
  });

  final String id;

  /// Short reference the customer can quote, e.g. `OFC-M3K9X2`.
  final String code;
  final String carId;
  final String carTitle;
  final String? carImage;
  final int price;

  /// Set when the price comes from an accepted offer instead of the list price.
  final String? offerId;
  final String userId;
  final String userName;
  final String userEmail;
  final String phone;
  final Fulfilment fulfilment;
  final PaymentMethod paymentMethod;
  final String address;
  final String note;
  final OrderStatus status;
  final DateTime? createdAt;

  static String newCode([DateTime? now]) {
    final millis = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return 'OFC-${millis.toRadixString(36).toUpperCase()}';
  }

  factory CarOrder.fromMap(String id, Map<String, dynamic> map) {
    return CarOrder(
      id: id,
      code: map['code'] as String? ?? '',
      carId: map['carId'] as String? ?? '',
      carTitle: map['carTitle'] as String? ?? '',
      carImage: map['carImage'] as String?,
      price: (map['price'] as num?)?.toInt() ?? 0,
      offerId: map['offerId'] as String?,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      fulfilment: Fulfilment.values.firstWhere(
        (value) => value.name == map['fulfilment'],
        orElse: () => Fulfilment.pickup,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (value) => value.name == map['paymentMethod'],
        orElse: () => PaymentMethod.bankTransfer,
      ),
      address: map['address'] as String? ?? '',
      note: map['note'] as String? ?? '',
      status: OrderStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'code': code,
    'carId': carId,
    'carTitle': carTitle,
    'carImage': carImage,
    'price': price,
    'offerId': offerId,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'phone': phone,
    'fulfilment': fulfilment.name,
    'paymentMethod': paymentMethod.name,
    'address': address,
    'note': note,
    'status': status.name,
  };

  CarOrder copyWith({String? id, OrderStatus? status, DateTime? createdAt}) {
    return CarOrder(
      id: id ?? this.id,
      code: code,
      carId: carId,
      carTitle: carTitle,
      carImage: carImage,
      price: price,
      offerId: offerId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      phone: phone,
      fulfilment: fulfilment,
      paymentMethod: paymentMethod,
      address: address,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
