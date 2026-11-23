import 'package:equatable/equatable.dart';

/// `return` is a reserved word in Dart, so the return type is `returnOrder`.
enum OrderRequestType { cancel, returnOrder, exchange }

extension OrderRequestTypeDetails on OrderRequestType {
  String get title => switch (this) {
    OrderRequestType.cancel => 'Cancel order',
    OrderRequestType.returnOrder => 'Return order',
    OrderRequestType.exchange => 'Exchange order',
  };

  String get question => switch (this) {
    OrderRequestType.cancel => 'Why do you want to cancel?',
    OrderRequestType.returnOrder => 'Why are you returning this order?',
    OrderRequestType.exchange => 'Why do you want an exchange?',
  };

  String get submitLabel => switch (this) {
    OrderRequestType.cancel => 'Cancel order',
    OrderRequestType.returnOrder => 'Request return',
    OrderRequestType.exchange => 'Request exchange',
  };

  /// Heading on the order details screen.
  String get heading => switch (this) {
    OrderRequestType.cancel => 'Cancellation',
    OrderRequestType.returnOrder => 'Return request',
    OrderRequestType.exchange => 'Exchange request',
  };

  String get note => switch (this) {
    OrderRequestType.cancel =>
      'This is a cash on delivery order, so nothing has been charged.',
    OrderRequestType.returnOrder =>
      'Once approved, we\'ll arrange a pickup and refund you.',
    OrderRequestType.exchange =>
      'We\'ll replace the same products. Mention the size or colour you '
          'need in the comment.',
  };

  String get successMessage => switch (this) {
    OrderRequestType.cancel => 'Your order has been cancelled',
    OrderRequestType.returnOrder =>
      'Return requested. We\'ll contact you about pickup.',
    OrderRequestType.exchange => 'Exchange requested. We\'ll be in touch soon.',
  };

  List<String> get reasons => switch (this) {
    OrderRequestType.cancel => const [
      'Ordered by mistake',
      'Found a better price elsewhere',
      'Delivery time is too long',
      'Need to change the delivery address',
      'Changed my mind',
      OrderRequest.otherReason,
    ],
    OrderRequestType.returnOrder => const [
      'Item is damaged or defective',
      'Wrong item delivered',
      'Item not as described',
      'Missing parts or accessories',
      'Quality not as expected',
      'No longer needed',
      OrderRequest.otherReason,
    ],
    OrderRequestType.exchange => const [
      'Wrong size or fit',
      'Wrong colour or variant',
      'Item is damaged or defective',
      'Wrong item delivered',
      OrderRequest.otherReason,
    ],
  };
}

class OrderRequest extends Equatable {
  static const otherReason = 'Other';

  final OrderRequestType type;
  final String reason;
  final String comment;
  final DateTime createdAt;

  const OrderRequest({
    required this.type,
    required this.reason,
    this.comment = '',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [type, reason, comment, createdAt];
}
