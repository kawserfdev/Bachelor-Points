import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../request_controller.dart';

class ApprovalView extends GetView<RequestController> {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pendingRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.pendingRequests.isEmpty) {
          return const Center(child: Text('No pending requests.'));
        }

        return ListView.builder(
          itemCount: controller.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = controller.pendingRequests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${request.userName ?? 'User'} - ${request.type.capitalizeFirst}'),
                subtitle: Text('${request.details ?? 'No details'}\n${request.createdAt.toLocal().toString().split('.')[0]}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => controller.updateRequestStatus(request.id, 'approved'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => controller.updateRequestStatus(request.id, 'rejected'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
