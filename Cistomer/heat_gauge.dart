import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Order-status "heat gauge": fills grey -> peach -> orange -> black
/// as the order progresses, playing on food getting closer/hotter.
class HeatGauge extends StatelessWidget {
  final int stepIndex; // 0 = placed, 1 = preparing, 2 = on the way, 3 = delivered
  static const labels = ['Order placed', 'Preparing', 'On the way', 'Delivered'];

  const HeatGauge({super.key, required this.stepIndex});

  Color _segColor(int segIndex) {
    if (segIndex >= stepIndex) return AppColors.greyMid;
    if (segIndex == 0) return AppColors.heatStep1;
    if (segIndex == 1) return AppColors.heatStep2;
    return AppColors.heatStep3;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                height: 8,
                decoration: BoxDecoration(
                  color: _segColor(i),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map((l) => Text(l, style: const TextStyle(fontSize: 10, color: AppColors.blackSoft)))
              .toList(),
        ),
      ],
    );
  }
}
