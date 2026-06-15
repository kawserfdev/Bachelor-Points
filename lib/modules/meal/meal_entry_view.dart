import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'meal_controller.dart';
import 'widgets/meal_preview_widget.dart';
import '../../shared/widgets/primary_button.dart';

class MealEntryView extends GetView<MealController> {
  const MealEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Entry'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateSelector(context),
              const SizedBox(height: 24),
              const MealPreviewWidget(),
              const SizedBox(height: 32),
              
              // Warning if cutoff passed
              Obx(() {
                if (!controller.canEdit) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orangeAccent),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Editing locked. The cutoff time has passed for this date.',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              _buildMealSelector(context, 'Breakfast', Icons.breakfast_dining, controller.breakfast, 'breakfast'),
              const SizedBox(height: 24),
              _buildMealSelector(context, 'Lunch', Icons.lunch_dining, controller.lunch, 'lunch'),
              const SizedBox(height: 24),
              _buildMealSelector(context, 'Dinner', Icons.dinner_dining, controller.dinner, 'dinner'),
              const SizedBox(height: 24),
              _buildGuestMealSelector(context),
              const SizedBox(height: 48),
              
              Obx(() => PrimaryButton(
                    text: 'SAVE MEALS',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.canEdit ? controller.saveMeal : () {},
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          controller.changeDate(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Obx(() => Text(
                      "${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestMealSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'Guest Meals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Extra meals for guests (adds to your total)',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: Slider(
                  value: controller.guestMeals.value,
                  min: 0.0,
                  max: 10.0,
                  divisions: 20,
                  label: controller.guestMeals.value.toStringAsFixed(1),
                  onChanged: controller.canEdit
                      ? (v) => controller.updatePortion('guest', v)
                      : null,
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  controller.guestMeals.value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMealSelector(BuildContext context, String title, IconData icon, RxDouble currentValue, String type) {
    final options = [0.0, 0.5, 1.0, 1.5, 2.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            return Obx(() {
              final isSelected = currentValue.value == option;
              return ChoiceChip(
                label: Text(option.toString()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.updatePortion(type, option);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }
}
