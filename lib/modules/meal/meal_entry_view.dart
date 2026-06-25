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
              const SizedBox(height: 32),
              _buildBulkActionsSection(context),
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

  Widget _buildBulkActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Meal Plan & Bulk Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Set your regular meal portions for a long duration, or close specific meals for one or more days.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSetMealPlanBottomSheet(context),
                  icon: const Icon(Icons.playlist_add_check, size: 20),
                  label: const Text('Set Plan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCloseMealsBottomSheet(context),
                  icon: const Icon(Icons.block, size: 20),
                  label: const Text('Close Meals'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetMealPlanBottomSheet(BuildContext context) {
    final now = DateTime.now();
    double tempBreakfast = 1.0;
    double tempLunch = 1.0;
    double tempDinner = 1.0;
    
    final durations = [
      {'label': '1 Day', 'days': 1},
      {'label': '3 Days', 'days': 3},
      {'label': '7 Days', 'days': 7},
      {'label': '30 Days', 'days': 30},
      {'label': '3 Months', 'days': 90},
      {'label': '6 Months', 'days': 180},
      {'label': '1 Year', 'days': 365},
    ];
    int selectedDurationIndex = 3; // Default: 30 Days
    DateTime selectedStart = DateTime(now.year, now.month, now.day);

    final mealOptions = [0.0, 0.5, 1.0, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Set Regular Meal Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Define your default daily portions and apply them for a set duration.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSheetMealSelector(
                      context,
                      'Breakfast',
                      Icons.breakfast_dining,
                      tempBreakfast,
                      mealOptions,
                      (val) => setSheetState(() => tempBreakfast = val),
                    ),
                    const SizedBox(height: 16),
                    _buildSheetMealSelector(
                      context,
                      'Lunch',
                      Icons.lunch_dining,
                      tempLunch,
                      mealOptions,
                      (val) => setSheetState(() => tempLunch = val),
                    ),
                    const SizedBox(height: 16),
                    _buildSheetMealSelector(
                      context,
                      'Dinner',
                      Icons.dinner_dining,
                      tempDinner,
                      mealOptions,
                      (val) => setSheetState(() => tempDinner = val),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedStart,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setSheetState(() => selectedStart = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  "${selectedStart.day}/${selectedStart.month}/${selectedStart.year}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<int>(
                            value: selectedDurationIndex,
                            underline: const SizedBox.shrink(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedDurationIndex = val);
                              }
                            },
                            items: List.generate(durations.length, (index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(durations[index]['label'] as String),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: () async {
                        final durationDays = durations[selectedDurationIndex]['days'] as int;
                        Navigator.pop(context);
                        await controller.saveMealPlan(
                          breakfastPortion: tempBreakfast,
                          lunchPortion: tempLunch,
                          dinnerPortion: tempDinner,
                          durationDays: durationDays,
                          startDate: selectedStart,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'APPLY MEAL PLAN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetMealSelector(
    BuildContext context,
    String title,
    IconData icon,
    double currentValue,
    List<double> options,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return ChoiceChip(
              label: Text(option.toString()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCloseMealsBottomSheet(BuildContext context) {
    final now = DateTime.now();
    DateTime tempStart = DateTime(now.year, now.month, now.day);
    DateTime tempEnd = DateTime(now.year, now.month, now.day);
    
    bool closeBreakfast = false;
    bool closeLunch = false;
    bool closeDinner = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isAllClosed = closeBreakfast && closeLunch && closeDinner;
            
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Close Meals',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turn off specific meals for a single day or a range of dates.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempStart,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  tempStart = picked;
                                  if (tempEnd.isBefore(tempStart)) {
                                    tempEnd = tempStart;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${tempStart.day}/${tempStart.month}/${tempStart.year}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempEnd.isBefore(tempStart) ? tempStart : tempEnd,
                                firstDate: tempStart,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setSheetState(() => tempEnd = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${tempEnd.day}/${tempEnd.month}/${tempEnd.year}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Select Meals to Close',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    SwitchListTile(
                      title: const Text('All Meals', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Close Breakfast, Lunch, and Dinner'),
                      value: isAllClosed,
                      onChanged: (val) {
                        setSheetState(() {
                          closeBreakfast = val;
                          closeLunch = val;
                          closeDinner = val;
                        });
                      },
                      activeThumbColor: Colors.redAccent,
                      activeTrackColor: Colors.redAccent.withValues(alpha: 0.5),
                    ),
                    const Divider(),
                    
                    CheckboxListTile(
                      title: const Text('Breakfast'),
                      value: closeBreakfast,
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => closeBreakfast = val);
                        }
                      },
                      activeColor: Colors.redAccent,
                    ),
                    CheckboxListTile(
                      title: const Text('Lunch'),
                      value: closeLunch,
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => closeLunch = val);
                        }
                      },
                      activeColor: Colors.redAccent,
                    ),
                    CheckboxListTile(
                      title: const Text('Dinner'),
                      value: closeDinner,
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => closeDinner = val);
                        }
                      },
                      activeColor: Colors.redAccent,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: (!closeBreakfast && !closeLunch && !closeDinner)
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await controller.closeMeals(
                                startDate: tempStart,
                                endDate: tempEnd,
                                closeBreakfast: closeBreakfast,
                                closeLunch: closeLunch,
                                closeDinner: closeDinner,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'CLOSE SELECTED MEALS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

