import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../balance_controller.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../core/localization/number_converter.dart';

/// Responsive Add Deposit form.
///
/// Layout strategy (layout-only redesign — no business logic changes):
/// * **Mobile**  — preserves the original single-column form.
/// * **Tablet/Desktop** — centers the form inside a card with a max width,
///   and lays out the amount + payment method fields side by side.
///
/// The controller ([BalanceController]) is reused as-is; the form only calls
/// the existing `addDeposit` method.
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

  /// Whether the current locale is Bangla.
  bool get _isBangla =>
      Localizations.localeOf(context).languageCode == 'bn';

  /// Converts ASCII digits in [text] to Bangla digits when the current
  /// locale is Bangla; otherwise returns [text] unchanged.
  String _convert(String text) =>
      _isBangla ? NumberConverter.englishToBangla(text) : text;

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
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, sizeClass, constraints) {
            final isWide = deviceType != DeviceType.mobile;
            return SingleChildScrollView(
              padding: isWide
                  ? const EdgeInsets.all(32)
                  : const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 720 : double.infinity,
                  ),
                  child: isWide
                      ? _buildWideCard(context, local)
                      : _buildForm(context, local, isWide: false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tablet/Desktop: form wrapped in a surface card with a header.
  Widget _buildWideCard(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: cs.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.depositFormTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      local.depositFormDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _buildForm(context, local, isWide: true),
        ],
      ),
    );
  }

  /// The shared form fields. When [isWide] is true, the amount + payment
  /// method are laid out side by side.
  Widget _buildForm(
    BuildContext context,
    AppLocalizations local, {
    required bool isWide,
  }) {
    final amountField = CustomTextField(
      label: local.depositAmountLabel,
      hint: local.depositAmountHint,
      prefixIcon: Icons.account_balance_wallet,
      controller: amountController,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return AppLocalizations.of(context)!.enterAmountError;
        }
        if (double.tryParse(val) == null) {
          return AppLocalizations.of(context)!.enterValidNumberError;
        }
        return null;
      },
    );

    final paymentField = DropdownButtonFormField<String>(
      initialValue: selectedPaymentMethod,
      decoration: InputDecoration(
        labelText: local.paymentMethodLabel,
        prefixIcon: const Icon(Icons.payment),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withAlpha(128),
      ),
      items: [
        DropdownMenuItem(
            value: 'cash', child: Text(local.paymentMethodCash)),
        DropdownMenuItem(
            value: 'bkash', child: Text(local.paymentMethodBkash)),
        DropdownMenuItem(
            value: 'nagad', child: Text(local.paymentMethodNagad)),
        DropdownMenuItem(
            value: 'bank', child: Text(local.paymentMethodBank)),
      ],
      onChanged: (value) {
        if (value != null) setState(() => selectedPaymentMethod = value);
      },
    );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(context),
          const SizedBox(height: 24),
          if (isWide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: amountField),
                  const SizedBox(width: 16),
                  Expanded(child: paymentField),
                ],
              ),
            )
          else ...[
            amountField,
            const SizedBox(height: 16),
            paymentField,
          ],
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
