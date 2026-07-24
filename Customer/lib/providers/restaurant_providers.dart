import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final openRestaurantsProvider = StreamProvider<List<Restaurant>>((ref) {
  return ref.watch(firestoreServiceProvider).openRestaurants();
});

final restaurantProvider = FutureProvider.family<Restaurant?, String>((ref, id) {
  return ref.watch(firestoreServiceProvider).getRestaurant(id);
});

final menuProvider = StreamProvider.family<List<MenuItem>, String>((ref, restaurantId) {
  return ref.watch(firestoreServiceProvider).menuForRestaurant(restaurantId);
});
