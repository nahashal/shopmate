import 'package:cloud_firestore/cloud_firestore.dart';

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
          (snapshot) =>
              snapshot.docs.map((doc) => _fromMap(doc.data())).toList(),
        );
  }

  @override
  Future<void> addFavorite(String userId, Product product) {
    return _favorites(userId)
        .doc(product.id.toString())
        .set({..._toMap(product), 'addedAt': Timestamp.now()});
  }

  @override
  Future<void> removeFavorite(String userId, int productId) {
    return _favorites(userId).doc(productId.toString()).delete();
  }

  Map<String, dynamic> _toMap(Product product) {
    return {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'category': product.category,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'stock': product.stock,
      'brand': product.brand,
      'thumbnail': product.thumbnail,
      'images': product.images,
    };
  }

  Product _fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num).toDouble(),
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brand: map['brand'] as String?,
      thumbnail: map['thumbnail'] ?? '',
      images: List<String>.from(map['images'] ?? const []),
    );
  }
}
