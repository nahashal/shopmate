import 'package:equatable/equatable.dart';

class ShippingAddress extends Equatable {
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String pinCode;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.pinCode,
  });

  String get formatted => '$addressLine, $city - $pinCode';

  @override
  List<Object?> get props => [fullName, phone, addressLine, city, pinCode];
}
