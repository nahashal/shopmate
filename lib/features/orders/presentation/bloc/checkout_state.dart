import 'package:equatable/equatable.dart';

enum CheckoutStatus { idle, submitting, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final String? orderId;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.errorMessage,
  });

  bool get isSubmitting => status == CheckoutStatus.submitting;

  @override
  List<Object?> get props => [status, orderId, errorMessage];
}
