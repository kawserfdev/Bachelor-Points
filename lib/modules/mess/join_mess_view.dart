import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mess_controller.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';

class JoinMessView extends GetView<MessController> {
  const JoinMessView({super.key});

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Join Mess')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Invite Code',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask your Mess Admin for the 6-character code.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Invite Code',
              hint: 'E.g., A1B2C3',
              prefixIcon: Icons.qr_code,
              controller: codeController,
            ),
            const SizedBox(height: 40),
            Obx(() => PrimaryButton(
                  text: 'JOIN MESS',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (codeController.text.trim().length == 6) {
                      controller.joinMess(codeController.text.trim());
                    } else {
                      Get.snackbar('Error', 'Please enter a valid 6-character code');
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
