import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../../notifications/providers/notification_providers.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.isAdmin.value &&
            controller.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (controller.isAdmin.value) ...[
              _buildGeneralSettings(context),
              const SizedBox(height: 16),
            ],
            _buildAppearanceCard(context),
            const SizedBox(height: 16),
            _buildNotificationPreferencesCard(context),
            if (controller.isAdmin.value) ...[
              const SizedBox(height: 16),
              _buildBazarScheduleCard(context),
            ],
            if (controller.messId != null) ...[
              const SizedBox(height: 16),
              _buildMealPlanRequestCard(context),
              const SizedBox(height: 16),
              _buildMembershipCard(context),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildGeneralSettings(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text(
          'General Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: [
          ListTile(
            title: const Text('Meal Cutoff Time'),
            subtitle: Text(
              'Current: ${controller.messSettings.value?.mealCutoffTime ?? "Not set"}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 22, minute: 0),
              );
              if (time != null) {
                final formatted =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                controller.updateCutoffTime(formatted);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text(
          'Appearance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeControllerProvider);
              final themeCtrl = ref.read(themeControllerProvider.notifier);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Theme Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    subtitle: const Text(
                      'Clean interface with high readability',
                    ),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: const Icon(Icons.light_mode_outlined),
                    onChanged: (value) {
                      if (value != null) {
                        themeCtrl.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    subtitle: const Text(
                      'Comfortable for low-light environments',
                    ),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: const Icon(Icons.dark_mode_outlined),
                    onChanged: (value) {
                      if (value != null) {
                        themeCtrl.setThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System'),
                    subtitle: const Text('Match system settings automatically'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: const Icon(Icons.settings_suggest_outlined),
                    onChanged: (value) {
                      if (value != null) {
                        themeCtrl.setThemeMode(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final prefsAsync = ref.watch(notificationPrefsProvider);

              return prefsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading preferences: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                data: (prefs) {
                  final controller = ref.read(
                    notificationPrefsProvider.notifier,
                  );

                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Meal Notifications'),
                        subtitle: const Text(
                          'Get notified when meals are added or changed',
                        ),
                        value: prefs.mealNotifications,
                        onChanged: (val) =>
                            controller.toggleMealNotifications(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Expense Notifications'),
                        subtitle: const Text(
                          'Get notified when a new expense is logged',
                        ),
                        value: prefs.expenseNotifications,
                        onChanged: (val) =>
                            controller.toggleExpenseNotifications(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Deposit Notifications'),
                        subtitle: const Text(
                          'Get notified when deposits are recorded or approved',
                        ),
                        value: prefs.depositNotifications,
                        onChanged: (val) =>
                            controller.toggleDepositNotifications(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Shopping Notifications'),
                        subtitle: const Text('Receive shopping duty reminders'),
                        value: prefs.shoppingNotifications,
                        onChanged: (val) =>
                            controller.toggleShoppingNotifications(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text(
                          'Enable push notifications to this device',
                        ),
                        value: prefs.pushNotifications,
                        onChanged: (val) =>
                            controller.togglePushNotifications(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Notification Sound'),
                        value: prefs.sound,
                        onChanged: (val) => controller.toggleSound(val),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Vibration'),
                        value: prefs.vibration,
                        onChanged: (val) => controller.toggleVibration(val),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBazarScheduleCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text(
          'Bazar Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Assign New Duty'),
              onPressed: () => _showAssignDutyDialog(context),
            ),
          ),
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.schedules.length,
              itemBuilder: (context, index) {
                final schedule = controller.schedules[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                  title: Text(schedule.userName ?? 'Unknown User'),
                  subtitle: Text(
                    schedule.date.toLocal().toString().split(' ')[0],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.deleteBazarDuty(schedule.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDutyDialog(BuildContext context) {
    String? selectedUserId;
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Bazar Duty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Member'),
                items: controller.members.map((m) {
                  return DropdownMenuItem(
                    value: m.userId,
                    child: Text(m.fullName ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (val) => selectedUserId = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                child: const Text('Select Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedUserId != null && selectedDate != null) {
                  Navigator.of(context).pop();
                  controller.assignBazarDuty(selectedUserId!, selectedDate!);
                } else {
                  AppNavigation.showSnackBar(
                    'Error',
                    'Please select a member and date',
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mess Membership',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you want to leave this mess, you can submit an exit request. '
              'The manager or admin will need to approve your request before you are removed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.exit_to_app_rounded),
                label: const Text('Request to Exit Mess'),
                onPressed: () => _showExitRequestDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitRequestDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit Mess Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for exiting the mess. This will be visible to the manager/admin.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Exiting *',
                  hintText: 'e.g. Moving to a new place / Leaving the city',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                    padding:  EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: const Color(0xFF365FF4),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     padding:  EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      Get.snackbar(
                        'Validation',
                        'Reason is required.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    controller.submitExitRequest(reason);
                  },
                  child: const Text('Request Submit'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealPlanRequestCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Default Meal Plan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your current regular daily portions:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPortionIndicator(context, 'Breakfast', controller.currentDefaultBreakfast.value),
                    _buildPortionIndicator(context, 'Lunch', controller.currentDefaultLunch.value),
                    _buildPortionIndicator(context, 'Dinner', controller.currentDefaultDinner.value),
                  ],
                )),
            const SizedBox(height: 16),
            Obx(() {
              final pending = controller.hasPendingMealPlanRequest.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pending ? Colors.grey : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(pending ? Icons.hourglass_empty : Icons.edit_calendar),
                  label: Text(pending ? 'Change Request Pending Manager Approval' : 'Request Meal Plan Change'),
                  onPressed: pending ? null : () => _showMealPlanRequestDialog(context),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPortionIndicator(BuildContext context, String label, double val) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
          ),
          child: Text(
            val.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showMealPlanRequestDialog(BuildContext context) {
    final now = DateTime.now();
    DateTime tempStart = DateTime(now.year, now.month, now.day);
    DateTime tempEnd = DateTime(now.year, now.month, now.day);
    
    double reqBreakfast = controller.currentDefaultBreakfast.value;
    double reqLunch = controller.currentDefaultLunch.value;
    double reqDinner = controller.currentDefaultDinner.value;
    final reasonController = TextEditingController();
    final options = [0.0, 0.5, 1.0, 1.5, 2.0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Request Meal Plan Change'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Request updates to your regular daily portions for a specific date range. This requires approval from the manager.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
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
                                setDialogState(() {
                                  tempStart = picked;
                                  if (tempEnd.isBefore(tempStart)) {
                                    tempEnd = tempStart;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${tempStart.day}/${tempStart.month}/${tempStart.year}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                        const SizedBox(width: 8),
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
                                setDialogState(() => tempEnd = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('End Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${tempEnd.day}/${tempEnd.month}/${tempEnd.year}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    _buildDialogPortionSelector(
                      context,
                      'Breakfast',
                      Icons.breakfast_dining,
                      reqBreakfast,
                      options,
                      (val) => setDialogState(() => reqBreakfast = val),
                    ),
                    const SizedBox(height: 12),
                    _buildDialogPortionSelector(
                      context,
                      'Lunch',
                      Icons.lunch_dining,
                      reqLunch,
                      options,
                      (val) => setDialogState(() => reqLunch = val),
                    ),
                    const SizedBox(height: 12),
                    _buildDialogPortionSelector(
                      context,
                      'Dinner',
                      Icons.dinner_dining,
                      reqDinner,
                      options,
                      (val) => setDialogState(() => reqDinner = val),
                    ),
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Change *',
                        hintText: 'e.g. Diet change, leaving city for few days, etc.',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      Get.snackbar(
                        'Validation',
                        'Reason is required.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    controller.submitMealPlanRequest(
                      breakfastVal: reqBreakfast,
                      lunchVal: reqLunch,
                      dinnerVal: reqDinner,
                      reason: reason,
                      startDate: tempStart,
                      endDate: tempEnd,
                    );
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogPortionSelector(
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
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
