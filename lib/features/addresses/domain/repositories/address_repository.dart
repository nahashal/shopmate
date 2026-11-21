import '../entities/saved_address.dart';

abstract class AddressRepository {
  Stream<List<SavedAddress>> watchAddresses(String userId);

  /// Creates the address if its id is empty, otherwise updates it.
  /// If it is marked default, every other address stops being default.
  Future<void> saveAddress(String userId, SavedAddress address);

  /// If the deleted address was the default, another one becomes default.
  Future<void> deleteAddress(String userId, String addressId);

  Future<void> setDefault(String userId, String addressId);
}
