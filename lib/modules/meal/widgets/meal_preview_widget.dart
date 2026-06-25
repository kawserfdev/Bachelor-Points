import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../meal_controller.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

class MealPreviewWidget extends StatelessWidget {
  const MealPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MealController>();
    final local = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            local.totalMealsSelected,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.totalDailyMeals.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBreakdownItem(context, local.breakfast, controller.breakfast),
              _buildBreakdownItem(context, local.lunch, controller.lunch),
              _buildBreakdownItem(context, local.dinner, controller.dinner),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, String title, RxDouble portion) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => Text(
              portion.value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )),
      ],
    );
  }
}
