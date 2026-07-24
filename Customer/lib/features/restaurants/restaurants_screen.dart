import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/restaurant_providers.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class RestaurantsScreen extends ConsumerWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(openRestaurantsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              'Hey${user?.displayName != null ? ", ${user!.displayName!.split(' ').first}" : ''} 👋',
              style: const TextStyle(color: AppColors.blackSoft, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text('Where to today?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            restaurantsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
              ),
              error: (e, _) => Text('Could not load restaurants.', style: TextStyle(color: AppColors.orangeDark)),
              data: (restaurants) {
                if (restaurants.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text('No restaurants open right now.', style: TextStyle(color: AppColors.blackSoft)),
                    ),
                  );
                }
                return Column(
                  children: restaurants.map((r) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.push('/restaurant/${r.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.greyMid,
                                  borderRadius: BorderRadius.circular(10),
                                  image: r.imageUrl != null && r.imageUrl!.isNotEmpty
                                      ? DecorationImage(image: NetworkImage(r.imageUrl!), fit: BoxFit.cover)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(r.cuisine, style: const TextStyle(fontSize: 13, color: AppColors.blackSoft)),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        if (r.rating != null) '★ ${r.rating}',
                                        if (r.etaMinutes != null) '${r.etaMinutes} min',
                                      ].join(' · '),
                                      style: const TextStyle(fontSize: 12, color: AppColors.blackSoft),
                                    ),
                                  ],
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
