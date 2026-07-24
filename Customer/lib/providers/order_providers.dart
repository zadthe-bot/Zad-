import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'restaurant_providers.dart';

final orderStreamProvider = StreamProvider.family<OrderModel, String>((ref, orderId) {
  return ref.watch(firestoreServiceProvider).orderStream(orderId);
});

final customerOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  return ref.watch(firestoreServiceProvider).customerOrders(customerId);
});
