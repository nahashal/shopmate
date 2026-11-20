import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersStarted extends OrdersEvent {
  final String userId;

  const OrdersStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}
