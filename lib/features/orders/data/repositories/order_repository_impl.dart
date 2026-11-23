import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../products/data/mappers/product_firestore_mapper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order_request.dart';
import '../../domain/failures/order_action_failure.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _orders(String userId) {
    return _firestore.collection('users').doc(userId).collection('orders');
  }

  CollectionReference<Map<String, dynamic>> _cart(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  @override
  Stream<List<ShopOrder>> watchOrders(String userId) {
    return _orders(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required ShippingAddress address,
    required String paymentMethod,
  }) async {
    final orderRef = _orders(userId).doc(); // Firestore creates the ID
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);

    final batch = _firestore.batch();

    // 1. Save the order
    batch.set(orderRef, {
      'items': items
          .map(
            (item) => {
              'product': ProductFirestoreMapper.toMap(item.product),
              'quantity': item.quantity,
            },
          )
          .toList(),
      'address': {
        'fullName': address.fullName,
        'phone': address.phone,
        'addressLine': address.addressLine,
        'city': address.city,
        'pinCode': address.pinCode,
      },
      'subtotal': subtotal,
      'shippingFee': 0.0,
      'paymentMethod': paymentMethod,
      'status': OrderStatus.placed.name,
      'createdAt': Timestamp.now(),
    });

    // 2. Remove the ordered items from the cart
    for (final item in items) {
      batch.delete(_cart(userId).doc(item.product.id.toString()));
    }

    // Both happen together, or neither does
    await batch.commit();

    return orderRef.id;
  }

  @override
  Future<void> submitRequest({
    required String userId,
    required String orderId,
    required OrderRequest request,
  }) async {
    final ref = _orders(userId).doc(orderId);

    // A transaction reads the LATEST status from the server and writes
    // only if nothing changed in between.
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw const OrderActionFailure('This order no longer exists.');
      }

      final current = OrderStatus.values.firstWhere(
        (status) => status.name == snapshot.data()!['status'],
        orElse: () => OrderStatus.placed,
      );

      final (allowedFrom, newStatus, notAllowed) = switch (request.type) {
        OrderRequestType.cancel => (
          OrderStatus.placed,
          OrderStatus.cancelled,
          'This order has already shipped and can no longer be cancelled.',
        ),
        OrderRequestType.returnOrder => (
          OrderStatus.delivered,
          OrderStatus.returnRequested,
          'Only delivered orders can be returned.',
        ),
        OrderRequestType.exchange => (
          OrderStatus.delivered,
          OrderStatus.exchangeRequested,
          'Only delivered orders can be exchanged.',
        ),
      };

      if (current != allowedFrom) {
        throw OrderActionFailure(notAllowed);
      }

      transaction.update(ref, {
        'status': newStatus.name,
        'request': _requestToMap(request),
      });
    });
  }

  Map<String, dynamic> _requestToMap(OrderRequest request) {
    return {
      'type': request.type.name,
      'reason': request.reason,
      'comment': request.comment,
      'createdAt': Timestamp.fromDate(request.createdAt),
    };
  }

  OrderRequest? _requestFromMap(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);

    return OrderRequest(
      type: OrderRequestType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => OrderRequestType.cancel,
      ),
      reason: map['reason'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ShopOrder _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final address = Map<String, dynamic>.from(data['address'] as Map);

    return ShopOrder(
      id: doc.id,
      items: (data['items'] as List).map((raw) {
        final item = Map<String, dynamic>.from(raw as Map);
        return CartItem(
          product: ProductFirestoreMapper.fromMap(
            Map<String, dynamic>.from(item['product'] as Map),
          ),
          quantity: (item['quantity'] as num).toInt(),
        );
      }).toList(),
      address: ShippingAddress(
        fullName: address['fullName'] ?? '',
        phone: address['phone'] ?? '',
        addressLine: address['addressLine'] ?? '',
        city: address['city'] ?? '',
        pinCode: address['pinCode'] ?? '',
      ),
      subtotal: (data['subtotal'] as num).toDouble(),
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0,
      paymentMethod: data['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => OrderStatus.placed,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      request: _requestFromMap(data['request']),
    );
  }
}
