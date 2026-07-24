import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartState {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItem> items;

  CartState({this.restaurantId, this.restaurantName, this.items = const []});

  double get total => items.fold(0, (sum, i) => sum + i.price * i.qty);
  int get count => items.fold(0, (sum, i) => sum + i.qty);

  CartState copyWith({String? restaurantId, String? restaurantName, List<CartItem>? items}) {
    return CartState(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  /// Returns true if the item was added, false if it was blocked
  /// because the cart holds items from a different restaurant
  /// (caller should confirm with the user and call clear() first).
  bool addItem(String restaurantId, String restaurantName, CartItem item) {
    if (state.restaurantId != null && state.restaurantId != restaurantId) {
      return false;
    }
    final existingIndex = state.items.indexWhere((i) => i.id == item.id);
    List<CartItem> newItems;
    if (existingIndex >= 0) {
      newItems = [...state.items];
      newItems[existingIndex] = newItems[existingIndex].copyWith(qty: newItems[existingIndex].qty + 1);
    } else {
      newItems = [...state.items, item];
    }
    state = state.copyWith(restaurantId: restaurantId, restaurantName: restaurantName, items: newItems);
    return true;
  }

  void changeQty(String itemId, int delta) {
    final newItems = state.items
        .map((i) => i.id == itemId ? i.copyWith(qty: i.qty + delta) : i)
        .where((i) => i.qty > 0)
        .toList();
    state = state.copyWith(items: newItems);
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
