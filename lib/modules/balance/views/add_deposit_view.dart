import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../balance_controller.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';

class AddDepositView extends StatefulWidget {
  const AddDepositView({super.key});

  @override
  State<AddDepositView> createState() => _AddDepositViewState();
}

class _AddDepositViewState extends State<AddDepositView> {
  final controller = Get.find<BalanceController>();
  final formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();
  String selectedPaymentMethod = 'cash';
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.addDepositTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateSelector(context),
              const SizedBox(height: 24),

              CustomTextField(
                label: local.depositAmountLabel,
                hint: local.depositAmountHint,
                prefixIcon: Icons.account_balance_wallet,
                controller: amountController,
                validator: (val) {
                  if (val == null || val.isEmpty) return AppLocalizations.of(context)!.enterAmountError;
                  if (double.tryParse(val) == null) return AppLocalizations.of(context)!.enterValidNumberError;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: local.paymentMethodLabel,
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(local.paymentMethodCash)),
                  DropdownMenuItem(value: 'bkash', child: Text(local.paymentMethodBkash)),
                  DropdownMenuItem(value: 'nagad', child: Text(local.paymentMethodNagad)),
                  DropdownMenuItem(value: 'bank', child: Text(local.paymentMethodBank)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedPaymentMethod = value);
                },
              ),
              const SizedBox(height: 48),

              Obx(() => PrimaryButton(
                    text: local.submitForApprovalBtn,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.addDeposit(
                          amount: double.parse(amountController.text),
                          date: selectedDate,
                          paymentMethod: selectedPaymentMethod,
                        );
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          setState(() => selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).languageCode).format(selectedDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
