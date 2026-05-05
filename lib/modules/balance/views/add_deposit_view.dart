import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../balance_controller.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class AddDepositView extends StatefulWidget {
  const AddDepositView({super.key});

  @override
  State<AddDepositView> createState() => _AddDepositViewState();
}

class _AddDepositViewState extends State<AddDepositView> {
  final controller = Get.find<BalanceController>();
  final formKey = GlobalKey<FormState>();
  
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Deposit')),
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
                label: 'Deposit Amount (৳)',
                hint: 'e.g. 5000',
                prefixIcon: Icons.account_balance_wallet,
                controller: amountController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(val) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              
              Obx(() => PrimaryButton(
                    text: 'SAVE DEPOSIT',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.addDeposit(
                          amount: double.parse(amountController.text),
                          date: selectedDate,
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                  DateFormat('MMMM dd, yyyy').format(selectedDate),
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
