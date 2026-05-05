import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../settings_controller.dart';
import '../../../core/theme/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isAdmin.value) {
          return const Center(
            child: Text('You do not have permission to view settings.', style: TextStyle(color: Colors.red)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGeneralSettings(context),
            const SizedBox(height: 16),
            _buildBazarScheduleCard(context),
            const SizedBox(height: 16),
            _buildRoleManagementCard(),
          ],
        );
      }),
    );
  }

  Widget _buildGeneralSettings(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text('General Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: [
          ListTile(
            title: const Text('Meal Cutoff Time'),
            subtitle: Text('Current: ${controller.messSettings.value?.mealCutoffTime ?? "Not set"}'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 22, minute: 0),
              );
              if (time != null) {
                final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                controller.updateCutoffTime(formatted);
              }
            },
          ),
          const Divider(),
          GetX<ThemeController>(
            builder: (themeController) => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between light and dark theme'),
              value: themeController.isDarkMode.value,
              secondary: Icon(themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode),
              onChanged: (value) => themeController.switchTheme(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBazarScheduleCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Bazar Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Assign New Duty'),
              onPressed: () => _showAssignDutyDialog(context),
            ),
          ),
          Obx(() => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.schedules.length,
            itemBuilder: (context, index) {
              final schedule = controller.schedules[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                title: Text(schedule.userName ?? 'Unknown User'),
                subtitle: Text(schedule.date.toLocal().toString().split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteBazarDuty(schedule.id),
                ),
              );
            },
          )),
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
                  return DropdownMenuItem(value: m.userId, child: Text(m.fullName ?? 'Unknown'));
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
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedUserId != null && selectedDate != null) {
                  Get.back();
                  controller.assignBazarDuty(selectedUserId!, selectedDate!);
                } else {
                  Get.snackbar('Error', 'Please select a member and date');
                }
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleManagementCard() {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: const Text('Role Management', style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Obx(() => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.members.length,
            itemBuilder: (context, index) {
              final member = controller.members[index];
              return ListTile(
                title: Text(member.fullName ?? 'Unknown'),
                subtitle: Text(member.email ?? ''),
                trailing: DropdownButton<String>(
                  value: member.role,
                  items: const [
                    DropdownMenuItem(value: 'member', child: Text('Member')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (newRole) {
                    if (newRole != null && newRole != member.role) {
                      controller.changeMemberRole(member.id, newRole);
                    }
                  },
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
