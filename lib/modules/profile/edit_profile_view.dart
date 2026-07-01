import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../core/responsive/responsive.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = context.isWide;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.nameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.updateYourProfile,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.keepInfoUpToDate,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // On wide screens, lay the short fields out in two
                      // columns; the multi-line bio spans the full width.
                      if (isWide) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.nameController,
                                decoration: InputDecoration(
                                  labelText: l10n.fieldFullName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: controller.validateName,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.phoneController,
                                decoration: InputDecoration(
                                  labelText: l10n.phoneNumberLabel,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.addressController,
                                decoration: InputDecoration(
                                  labelText: l10n.addressLabel,
                                  prefixIcon:
                                      const Icon(Icons.location_on_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.nidController,
                                decoration: InputDecoration(
                                  labelText: l10n.nidNumberLabel,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            labelText: l10n.fieldFullName,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator: controller.validateName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.phoneController,
                          decoration: InputDecoration(
                            labelText: l10n.phoneNumberLabel,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.addressController,
                          decoration: InputDecoration(
                            labelText: l10n.addressLabel,
                            prefixIcon:
                                const Icon(Icons.location_on_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.nidController,
                          decoration: InputDecoration(
                            labelText: l10n.nidNumberLabel,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: controller.bioController,
                        decoration: InputDecoration(
                          labelText: l10n.bioLabel,
                          prefixIcon: const Icon(Icons.info_outline),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.saveProfile(context),
                      ),
                      const SizedBox(height: 32),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.saveProfile(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.saveChangesBtn,
                                style: const TextStyle(fontSize: 16),
                              ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
