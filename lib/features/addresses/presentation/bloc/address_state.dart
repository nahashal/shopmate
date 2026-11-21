import 'package:equatable/equatable.dart';

import '../../domain/entities/saved_address.dart';

class AddressState extends Equatable {
  final List<SavedAddress> addresses;
  final bool isLoading;
  final String? errorMessage;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// The default address, or the first one if none is marked.
  SavedAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  AddressState copyWith({
    List<SavedAddress>? addresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [addresses, isLoading, errorMessage];
}
