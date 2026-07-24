import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double total;
  final String address;
  final String status; // placed, preparing, on_the_way, delivered
  final Timestamp? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.address,
    required this.status,
    this.createdAt,
  });

  static const statusSteps = ['placed', 'preparing', 'on_the_way', 'delivered'];

  int get stepIndex => statusSteps.indexOf(status).clamp(0, 3);

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = (map['items'] as List<dynamic>? ?? []);
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      items: rawItems
          .map((i) => CartItem(
                id: i['id'],
                name: i['name'],
                price: (i['price'] as num).toDouble(),
                qty: i['qty'],
              ))
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
      address: map['address'] ?? '',
      status: map['status'] ?? 'placed',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
