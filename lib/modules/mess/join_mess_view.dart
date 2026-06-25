import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import 'mess_controller.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/helpers/navigation_helper.dart';

class JoinMessView extends GetView<MessController> {
  const JoinMessView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinMessTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.enterInviteCode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.askAdminCodeDesc,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: l10n.inviteCodeLabel,
              hint: l10n.inviteCodeHint,
              prefixIcon: Icons.qr_code,
              controller: codeController,
            ),
            const SizedBox(height: 40),
            Obx(() => PrimaryButton(
                  text: l10n.joinMessBtn,
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (codeController.text.trim().length == 6) {
                      controller.joinMess(codeController.text.trim());
                    } else {
                      AppNavigation.showSnackBar('Error', l10n.enterValidCodeError);
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
