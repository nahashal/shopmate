import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/shipping_address.dart';

class SavedAddress extends Equatable {
  /// Firestore document ID. Empty for an address not saved yet.
  final String id;

  /// 'Home', 'Work' or 'Other'
  final String label;

  final ShippingAddress address;
  final bool isDefault;

  const SavedAddress({
    this.id = '',
    required this.label,
    required this.address,
    this.isDefault = false,
  });

  SavedAddress copyWith({bool? isDefault}) {
    return SavedAddress(
      id: id,
      label: label,
      address: address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, label, address, isDefault];
}
