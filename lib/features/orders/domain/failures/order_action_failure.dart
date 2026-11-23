class OrderActionFailure implements Exception {
  final String message;

  const OrderActionFailure(this.message);

  @override
  String toString() => message;
}
