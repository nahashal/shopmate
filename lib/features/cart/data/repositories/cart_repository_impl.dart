import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../products/data/mappers/product_firestore_mapper.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;

  CartRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _cart(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  @override
  Stream<List<CartItem>> watchCart(String userId) {
    return _cart(userId)
        .orderBy('addedAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return CartItem(
              product: ProductFirestoreMapper.fromMap(
                Map<String, dynamic>.from(data['product'] as Map),
              ),
              quantity: (data['quantity'] as num).toInt(),
            );
          }).toList(),
        );
  }

  @override
  Future<void> addItem(String userId, Product product) {
    return _cart(userId).doc(product.id.toString()).set({
      'product': ProductFirestoreMapper.toMap(product),
      'quantity': 1,
      'addedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateQuantity(String userId, int productId, int quantity) {
    return _cart(userId)
        .doc(productId.toString())
        .update({'quantity': quantity});
  }

  @override
  Future<void> removeItem(String userId, int productId) {
    return _cart(userId).doc(productId.toString()).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    final snapshot = await _cart(userId).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
