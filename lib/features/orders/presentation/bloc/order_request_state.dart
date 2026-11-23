import 'package:equatable/equatable.dart';

enum OrderRequestStatus { idle, submitting, success, failure }

class OrderRequestState extends Equatable {
  final OrderRequestStatus status;
  final String? errorMessage;

  const OrderRequestState({
    this.status = OrderRequestStatus.idle,
    this.errorMessage,
  });

  bool get isSubmitting => status == OrderRequestStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage];
}
