import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../products/data/mappers/product_firestore_mapper.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _favorites(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  @override
  Stream<List<Product>> watchFavorites(String userId) {
    return _favorites(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductFirestoreMapper.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> addFavorite(String userId, Product product) {
    return _favorites(userId).doc(product.id.toString()).set({
      ...ProductFirestoreMapper.toMap(product),
      'addedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> removeFavorite(String userId, int productId) {
    return _favorites(userId).doc(productId.toString()).delete();
  }
}
