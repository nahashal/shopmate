import '../../domain/entities/product.dart';

class ProductFirestoreMapper {
  static Map<String, dynamic> toMap(Product product) {
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

  static Product fromMap(Map<String, dynamic> map) {
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
