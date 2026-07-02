import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../expense_controller.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../core/localization/number_converter.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final controller = Get.find<ExpenseController>();
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'bazar';
  DateTime selectedDate = DateTime.now();

  /// Whether the current locale is Bangla.
  bool get _isBangla =>
      Localizations.localeOf(context).languageCode == 'bn';

  /// Converts ASCII digits in [text] to Bangla digits when the current
  /// locale is Bangla; otherwise returns [text] unchanged.
  String _convert(String text) =>
      _isBangla ? NumberConverter.englishToBangla(text) : text;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.addExpenseTitle)),
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
                label: local.expenseTitleLabel,
                hint: local.expenseTitleHint,
                prefixIcon: Icons.title,
                controller: titleController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return local.enterTitleError;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: local.categoryLabel,
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                ),
                items: [
                  DropdownMenuItem(value: 'bazar', child: Text(local.categoryBazar)),
                  DropdownMenuItem(value: 'rent', child: Text(local.categoryRent)),
                  DropdownMenuItem(value: 'wifi', child: Text(local.categoryWifi)),
                  DropdownMenuItem(value: 'other', child: Text(local.categoryOther)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: local.amountLabel,
                hint: local.amountHint,
                prefixIcon: Icons.attach_money,
                controller: amountController,
                validator: (val) {
                  if (val == null || val.isEmpty) return local.enterAmountError;
                  if (double.tryParse(val) == null) return local.enterValidNumberError;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: local.noteOptionalLabel,
                hint: local.noteOptionalHint,
                prefixIcon: Icons.description,
                controller: descriptionController,
              ),
              const SizedBox(height: 48),

              Obx(() => PrimaryButton(
                    text: local.submitForApprovalBtn,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.addExpense(
                          amount: double.parse(amountController.text),
                          category: selectedCategory,
                          date: selectedDate,
                          description: titleController.text.trim(),
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
                  _convert(DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).languageCode).format(selectedDate)),
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
