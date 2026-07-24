import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_providers.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

const _statusLabel = {
  'placed': 'Order placed',
  'preparing': 'Preparing',
  'on_the_way': 'On the way',
  'delivered': 'Delivered',
};

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return const SizedBox();
    final ordersAsync = ref.watch(customerOrdersProvider(user.uid));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Your orders', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
              error: (e, _) => const Text('Could not load orders.'),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: Text('No orders yet.', style: TextStyle(color: AppColors.blackSoft))),
                  );
                }
                return Column(
                  children: orders.map((o) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.push('/orders/${o.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.restaurantName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 3),
                                    Text('${o.items.length} item${o.items.length > 1 ? 's' : ''} · \$${o.total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.blackSoft)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(999)),
                                child: Text(
                                  _statusLabel[o.status] ?? o.status,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
