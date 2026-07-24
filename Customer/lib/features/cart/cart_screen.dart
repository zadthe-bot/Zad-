import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_providers.dart';
import '../../core/theme/app_colors.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _addressCtrl = TextEditingController();
  String? _error;
  bool _placing = false;

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Add a delivery address.');
      return;
    }
    setState(() { _error = null; _placing = true; });
    final cart = ref.read(cartProvider);
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final orderId = await ref.read(firestoreServiceProvider).placeOrder(
            customerId: user.uid,
            customerName: user.displayName ?? 'Customer',
            restaurantId: cart.restaurantId!,
            restaurantName: cart.restaurantName ?? '',
            items: cart.items,
            total: cart.total,
            address: _addressCtrl.text.trim(),
          );
      ref.read(cartProvider.notifier).clear();
      if (mounted) context.go('/orders/$orderId');
    } catch (e) {
      setState(() => _error = 'Could not place order. Try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your order')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your cart is empty.', style: TextStyle(color: AppColors.blackSoft)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => context.go('/'), child: const Text('Browse restaurants')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your order')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(cart.restaurantName ?? '', style: const TextStyle(color: AppColors.blackSoft, fontSize: 13)),
            const SizedBox(height: 14),
            ...cart.items.map((i) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(i.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('\$${i.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.blackSoft, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(cartProvider.notifier).changeQty(i.id, -1),
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 22,
                        ),
                        Text('${i.qty}', style: const TextStyle(fontSize: 15)),
                        IconButton(
                          onPressed: () => ref.read(cartProvider.notifier).changeQty(i.id, 1),
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 22,
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'Delivery address')),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.orangeDark, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _placing ? null : _placeOrder,
              child: Text(_placing ? 'Placing order…' : 'Place order · \$${cart.total.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
