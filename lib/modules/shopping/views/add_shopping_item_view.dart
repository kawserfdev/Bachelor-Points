import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bachelorpoints/l10n/app_localizations.dart';
import '../../../core/responsive/responsive.dart';
import '../shopping_controller.dart';

/// Responsive Add Shopping Item form.
///
/// Layout strategy (layout-only redesign — no business logic changes):
/// * **Mobile**  — preserves the original single-column form.
/// * **Tablet/Desktop** — centers the form inside a surface card with a header,
///   and lays out the item name + quantity fields side by side.
///
/// The controller ([ShoppingController]) is reused as-is; the form only calls
/// the existing `requestItem` method.
class AddShoppingItemView extends StatefulWidget {
  const AddShoppingItemView({super.key});

  @override
  State<AddShoppingItemView> createState() => _AddShoppingItemViewState();
}

class _AddShoppingItemViewState extends State<AddShoppingItemView> {
  final ShoppingController controller = Get.find<ShoppingController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedPriority = 'normal';

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.requestItem(
        name: _nameController.text,
        quantity: _qtyController.text,
        priority: _selectedPriority,
        note: _noteController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.shoppingFormTitle)),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, sizeClass, constraints) {
            final isWide = deviceType != DeviceType.mobile;
            return SingleChildScrollView(
              padding: isWide
                  ? const EdgeInsets.all(32)
                  : const EdgeInsets.all(20.0),
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
                child: Icon(Icons.add_shopping_cart_rounded,
                    color: cs.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.shoppingFormTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      local.shoppingFormDesc,
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

  /// The shared form fields. When [isWide] is true, the item name + quantity
  /// are laid out side by side.
  Widget _buildForm(
    BuildContext context,
    AppLocalizations local, {
    required bool isWide,
  }) {
    final theme = Theme.of(context);

    final nameField = TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Item Name *',
        hintText: 'e.g. Rice, Onion, Fish, Eggs',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shopping_bag_outlined),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter the item name.';
        }
        return null;
      },
    );

    final qtyField = TextFormField(
      controller: _qtyController,
      decoration: const InputDecoration(
        labelText: 'Quantity / Measurement',
        hintText: 'e.g. 10 KG, 2 Liters, 1 Dozen',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.scale_outlined),
      ),
      textCapitalization: TextCapitalization.sentences,
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 16),
                  Expanded(child: qtyField),
                ],
              ),
            )
          else ...[
            nameField,
            const SizedBox(height: 20),
            qtyField,
          ],
          const SizedBox(height: 20),

          // Priority Header
          Text(
            'Priority Level',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Priority Segmented Button
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'normal',
                  label: Text(local.shoppingPriorityNormal),
                  icon: const Icon(Icons.star_outline_rounded),
                ),
                ButtonSegment<String>(
                  value: 'urgent',
                  label: Text(local.shoppingPriorityUrgent),
                  icon: const Icon(Icons.warning_amber_rounded),
                ),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedPriority = value.first;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Optional Notes
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Optional Note / Details',
              hintText: 'e.g. Buy fresh from Sunday bazar, miniket brand',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'Submit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
