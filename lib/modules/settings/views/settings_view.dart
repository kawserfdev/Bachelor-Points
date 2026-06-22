import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/helpers/navigation_helper.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: Obx(() {
        if (controller.isLoading.value && controller.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isAdmin.value) {
          return const Center(
            child: Text(
              'You do not have permission to view settings.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGeneralSettings(context),
            const SizedBox(height: 16),
            _buildAppearanceCard(context),
            const SizedBox(height: 16),
            _buildBazarScheduleCard(context),
            // const SizedBox(height: 16),
            // _buildRoleManagementCard(),
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

  // Widget _buildRoleManagementCard() {
  //   return Card(
  //     elevation: 2,
  //     child: ExpansionTile(
  //       title: const Text('Role Management', style: TextStyle(fontWeight: FontWeight.bold)),
  //       children: [
  //         Obx(() => ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: controller.members.length,
  //           itemBuilder: (context, index) {
  //             final member = controller.members[index];
  //             return ListTile(
  //               title: Text(member.fullName ?? 'Unknown'),
  //               subtitle: Text(member.email ?? ''),
  //               trailing: DropdownButton<String>(
  //                 value: member.role,
  //                 items: const [
  //                   DropdownMenuItem(value: 'member', child: Text('Member')),
  //                   DropdownMenuItem(value: 'manager', child: Text('Manager')),
  //                   DropdownMenuItem(value: 'admin', child: Text('Admin')),
  //                 ],
  //                 onChanged: (newRole) {
  //                   if (newRole != null && newRole != member.role) {
  //                     controller.changeMemberRole(member.id, newRole);
  //                   }
  //                 },
  //               ),
  //             );
  //           },
  //         )),
  //       ],
  //     ),
  //   );
  // }
}
