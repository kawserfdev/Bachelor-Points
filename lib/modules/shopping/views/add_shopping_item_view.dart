import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shopping_controller.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Bazar Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informational Banner Card
                Card(
                  elevation: 0,
                  color: colorScheme.secondaryContainer.withAlpha(40),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your requested item will be sent to the mess manager/admin for approval before showing up on the shopping list.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Item Name
                TextFormField(
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
                ),
                const SizedBox(height: 20),

                // Quantity / Measurement
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity / Measurement',
                    hintText: 'e.g. 10 KG, 2 Liters, 1 Dozen',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
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
                    segments: const [
                      ButtonSegment<String>(
                        value: 'normal',
                        label: Text('Normal'),
                        icon: Icon(Icons.star_outline_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'urgent',
                        label: Text('Urgent'),
                        icon: Icon(Icons.warning_amber_rounded),
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
          ),
        ),
      ),
    );
  }
}
