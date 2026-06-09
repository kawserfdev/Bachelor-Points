import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mess_controller.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';

class CreateMessView extends GetView<MessController> {
  const CreateMessView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Mess')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Start a new Mess',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You will become the Admin and can invite others.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Mess Name',
              hint: 'E.g., Bachelor Point',
              prefixIcon: Icons.home_work_outlined,
              controller: nameController,
            ),
            const SizedBox(height: 40),
            Obx(() => PrimaryButton(
                  text: 'CREATE MESS',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      controller.createMess(nameController.text.trim());
                    } else {
                      Get.snackbar('Error', 'Please enter a mess name');
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
