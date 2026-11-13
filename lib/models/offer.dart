import '../core/formatters.dart';

enum OfferStatus {
  pending('Pending'),
  accepted('Accepted'),
  declined('Declined');

  const OfferStatus(this.label);
  final String label;
}

/// A price a customer proposes for a car. The showroom accepts or declines.
class Offer {
  const Offer({
    required this.id,
    required this.carId,
    required this.carTitle,
    required this.listPrice,
    required this.amount,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.carImage,
    this.message = '',
    this.status = OfferStatus.pending,
    this.reply = '',
    this.createdAt,
  });

  final String id;
  final String carId;
  final String carTitle;
  final String? carImage;
  final int listPrice;
  final int amount;
  final String userId;
  final String userName;
  final String userPhone;
  final String message;
  final OfferStatus status;

  /// Optional note from the showroom when it responds.
  final String reply;
  final DateTime? createdAt;

  factory Offer.fromMap(String id, Map<String, dynamic> map) {
    return Offer(
      id: id,
      carId: map['carId'] as String? ?? '',
      carTitle: map['carTitle'] as String? ?? '',
      carImage: map['carImage'] as String?,
      listPrice: (map['listPrice'] as num?)?.toInt() ?? 0,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: OfferStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OfferStatus.pending,
      ),
      reply: map['reply'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'carId': carId,
    'carTitle': carTitle,
    'carImage': carImage,
    'listPrice': listPrice,
    'amount': amount,
    'userId': userId,
    'userName': userName,
    'userPhone': userPhone,
    'message': message,
    'status': status.name,
    'reply': reply,
  };

  Offer copyWith({
    String? id,
    OfferStatus? status,
    String? reply,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      carId: carId,
      carTitle: carTitle,
      carImage: carImage,
      listPrice: listPrice,
      amount: amount,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      message: message,
      status: status ?? this.status,
      reply: reply ?? this.reply,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
