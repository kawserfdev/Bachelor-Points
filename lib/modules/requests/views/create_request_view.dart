import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../request_controller.dart';

class CreateRequestView extends GetView<RequestController> {
  const CreateRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final typeController = TextEditingController(text: 'meal');
    final detailsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: 'meal',
              decoration: const InputDecoration(
                labelText: 'Request Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'meal', child: Text('Meal Request')),
                DropdownMenuItem(value: 'leave', child: Text('Leave Request')),
              ],
              onChanged: (value) {
                if (value != null) {
                  typeController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(
                labelText: 'Details / Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (detailsController.text.isEmpty) {
                        Get.snackbar('Error', 'Please provide details');
                        return;
                      }
                      controller.submitRequest(
                        typeController.text,
                        detailsController.text,
                      );
                    },
              child: controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Submit Request'),
            )),
          ],
        ),
      ),
    );
  }
}
