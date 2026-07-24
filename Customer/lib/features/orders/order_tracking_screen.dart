import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_providers.dart';
import '../../core/widgets/heat_gauge.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order status')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
        error: (e, _) => const Center(child: Text('Could not load this order.')),
        data: (order) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(order.restaurantName, style: const TextStyle(color: AppColors.blackSoft, fontSize: 13)),
              const SizedBox(height: 2),
              Text(HeatGauge.labels[order.stepIndex.clamp(0, 3)], style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text('Delivering to ${order.address}', style: const TextStyle(color: AppColors.blackSoft, fontSize: 13)),
              const SizedBox(height: 20),
              HeatGauge(stepIndex: order.stepIndex),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      ...order.items.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${i.qty}× ${i.name}'),
                                Text('\$${(i.price * i.qty).toStringAsFixed(2)}'),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/orders'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text('All orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
