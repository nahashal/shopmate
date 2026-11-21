import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../orders/domain/entities/shipping_address.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _addresses(String userId) {
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  @override
  Stream<List<SavedAddress>> watchAddresses(String userId) {
    return _addresses(userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> saveAddress(String userId, SavedAddress address) async {
    final collection = _addresses(userId);
    final isNew = address.id.isEmpty;
    final ref = isNew ? collection.doc() : collection.doc(address.id);

    final batch = _firestore.batch();

    batch.set(ref, {
      'label': address.label,
      'fullName': address.address.fullName,
      'phone': address.address.phone,
      'addressLine': address.address.addressLine,
      'city': address.address.city,
      'pinCode': address.address.pinCode,
      'isDefault': address.isDefault,
      if (isNew) 'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));

    // Only one address can be the default
    if (address.isDefault) {
      final currentDefaults = await collection
          .where('isDefault', isEqualTo: true)
          .get();

      for (final doc in currentDefaults.docs) {
        if (doc.id != ref.id) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    final snapshot = await _addresses(userId).orderBy('createdAt').get();

    final deleted = snapshot.docs
        .where((doc) => doc.id == addressId)
        .firstOrNull;
    if (deleted == null) return;

    final batch = _firestore.batch();
    batch.delete(deleted.reference);

    // Deleting the default? Make the oldest remaining one the default.
    if (deleted.data()['isDefault'] == true) {
      final next = snapshot.docs
          .where((doc) => doc.id != addressId)
          .firstOrNull;
      if (next != null) {
        batch.update(next.reference, {'isDefault': true});
      }
    }

    await batch.commit();
  }

  @override
  Future<void> setDefault(String userId, String addressId) async {
    final snapshot = await _addresses(userId).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final shouldBeDefault = doc.id == addressId;
      final isDefault = doc.data()['isDefault'] == true;

      if (isDefault != shouldBeDefault) {
        batch.update(doc.reference, {'isDefault': shouldBeDefault});
      }
    }

    await batch.commit();
  }

  SavedAddress _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return SavedAddress(
      id: doc.id,
      label: data['label'] ?? 'Other',
      isDefault: data['isDefault'] == true,
      address: ShippingAddress(
        fullName: data['fullName'] ?? '',
        phone: data['phone'] ?? '',
        addressLine: data['addressLine'] ?? '',
        city: data['city'] ?? '',
        pinCode: data['pinCode'] ?? '',
      ),
    );
  }
}
