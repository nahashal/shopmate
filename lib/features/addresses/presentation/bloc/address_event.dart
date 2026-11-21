import 'package:equatable/equatable.dart';

import '../../domain/entities/saved_address.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class AddressesStarted extends AddressEvent {
  final String userId;

  const AddressesStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddressesStopped extends AddressEvent {
  const AddressesStopped();
}

class AddressSaved extends AddressEvent {
  final SavedAddress address;

  const AddressSaved(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressDeleted extends AddressEvent {
  final String addressId;

  const AddressDeleted(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class AddressDefaultSet extends AddressEvent {
  final String addressId;

  const AddressDefaultSet(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

/// Used inside the BLoC when Firestore sends new data.
class AddressesUpdated extends AddressEvent {
  final List<SavedAddress> addresses;

  const AddressesUpdated(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

/// Used inside the BLoC when the Firestore stream fails.
class AddressesLoadFailed extends AddressEvent {
  const AddressesLoadFailed();
}
