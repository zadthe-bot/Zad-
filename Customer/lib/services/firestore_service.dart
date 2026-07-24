import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Restaurant>> openRestaurants() {
    return _db
        .collection('restaurants')
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Restaurant.fromMap(d.id, d.data())).toList());
  }

  Future<Restaurant?> getRestaurant(String id) async {
    final doc = await _db.collection('restaurants').doc(id).get();
    if (!doc.exists) return null;
    return Restaurant.fromMap(doc.id, doc.data()!);
  }

  Stream<List<MenuItem>> menuForRestaurant(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MenuItem.fromMap(d.id, d.data())).toList());
  }

  Future<String> placeOrder({
    required String customerId,
    required String customerName,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required double total,
    required String address,
  }) async {
    final ref = await _db.collection('orders').add({
      'customerId': customerId,
      'customerName': customerName,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'address': address,
      'status': 'placed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<OrderModel> orderStream(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()!));
  }

  Stream<List<OrderModel>> customerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList());
  }
}
