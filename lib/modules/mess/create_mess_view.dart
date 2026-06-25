import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'mess_controller.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/helpers/navigation_helper.dart';

class CreateMessView extends GetView<MessController> {
  const CreateMessView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createMessTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.startNewMess,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createMessAdminDesc,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: l10n.messNameLabel,
              hint: l10n.messNameHint,
              prefixIcon: Icons.home_work_outlined,
              controller: nameController,
            ),
            const SizedBox(height: 40),
            Obx(() => PrimaryButton(
                  text: l10n.createMessBtn,
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      controller.createMess(nameController.text.trim());
                    } else {
                      AppNavigation.showSnackBar('Error', l10n.enterMessNameError);
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
