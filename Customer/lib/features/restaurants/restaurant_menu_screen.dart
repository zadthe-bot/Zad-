import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/restaurant_providers.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../core/theme/app_colors.dart';

class RestaurantMenuScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantMenuScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantProvider(restaurantId));
    final menuAsync = ref.watch(menuProvider(restaurantId));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink()),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              restaurantAsync.when(
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
                data: (r) => r == null
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 2),
                            Text(r.cuisine, style: const TextStyle(color: AppColors.blackSoft, fontSize: 14)),
                          ],
                        ),
                      ),
              ),
              menuAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                error: (e, _) => const Text('Could not load menu.'),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No menu items yet.', style: TextStyle(color: AppColors.blackSoft))),
                    );
                  }
                  return Column(
                    children: items.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    if (item.description != null && item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(item.description!, style: const TextStyle(fontSize: 12, color: AppColors.blackSoft)),
                                    ],
                                    const SizedBox(height: 6),
                                    Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final restaurant = restaurantAsync.valueOrNull;
                                  final added = ref.read(cartProvider.notifier).addItem(
                                        restaurantId,
                                        restaurant?.name ?? '',
                                        CartItem(id: item.id, name: item.name, price: item.price, qty: 1),
                                      );
                                  if (!added && context.mounted) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Start a new order?'),
                                        content: const Text('Your cart has items from another restaurant. Clear it and add this instead?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear cart')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      ref.read(cartProvider.notifier).clear();
                                      ref.read(cartProvider.notifier).addItem(
                                            restaurantId,
                                            restaurant?.name ?? '',
                                            CartItem(id: item.id, name: item.name, price: item.price, qty: 1),
                                          );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(color: AppColors.black, shape: BoxShape.circle),
                                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          if (cart.count > 0 && cart.restaurantId == restaurantId)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                onPressed: () => context.push('/cart'),
                child: Text('View cart · ${cart.count} item${cart.count > 1 ? 's' : ''}'),
              ),
            ),
        ],
      ),
    );
  }
}
