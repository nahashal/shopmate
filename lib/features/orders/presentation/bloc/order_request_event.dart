import 'package:equatable/equatable.dart';

import '../../domain/entities/order_request.dart';

abstract class OrderRequestEvent extends Equatable {
  const OrderRequestEvent();

  @override
  List<Object?> get props => [];
}

class OrderRequestSubmitted extends OrderRequestEvent {
  final String userId;
  final String orderId;
  final OrderRequest request;

  const OrderRequestSubmitted({
    required this.userId,
    required this.orderId,
    required this.request,
  });

  @override
  List<Object?> get props => [userId, orderId, request];
}
