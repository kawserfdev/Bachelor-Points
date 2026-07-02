import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/modules/tolet/property_post/property_post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/localization/number_converter.dart';

class PropertyPostView extends GetView<PropertyPostController> {
  const PropertyPostView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Basic Info',
                  color: const Color(0xFF6366F1),
                  child: _BasicInfoSection(controller: controller),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  color: const Color(0xFF0EA5E9),
                  child: _LocationSection(controller: controller),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.tune_rounded,
                  title: 'Property Details',
                  color: const Color(0xFF10B981),
                  child: _DetailsSection(controller: controller),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.star_outline_rounded,
                  title: 'Amenities',
                  color: const Color(0xFFF59E0B),
                  child: _AmenitiesSection(controller: controller),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.photo_camera_outlined,
                  title: 'Photos',
                  color: const Color(0xFFEC4899),
                  child: _PhotosSection(controller: controller),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.error.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.error.value,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActions(controller: controller),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          controller.isEditing ? 'Edit Property' : 'Post Property',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset Form',
          onPressed: () => _confirmReset(context),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Form'),
        content: const Text(
            'Are you sure you want to clear all fields? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.resetForm();
              Navigator.pop(ctx);
            },
            child:
                const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Card wrapper
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: color,
          ),
        ),
        children: [
          Divider(color: color.withOpacity(0.15), height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 1 — Basic Info
// ---------------------------------------------------------------------------

class _BasicInfoSection extends StatelessWidget {
  final PropertyPostController controller;
  const _BasicInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StyledTextField(
          label: 'Title',
          hint: 'e.g. Spacious 3-bedroom flat in Dhanmondi',
          icon: Icons.title_rounded,
          onChanged: (v) => controller.title.value = v,
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          label: 'Description',
          hint: 'Describe the property, surroundings, terms, etc.',
          icon: Icons.description_outlined,
          maxLines: 4,
          onChanged: (v) => controller.description.value = v,
        ),
        const SizedBox(height: 14),
        Obx(
          () => _StyledDropdown<String>(
            label: 'Property Type',
            icon: Icons.home_work_outlined,
            value: controller.propertyType.value.isEmpty
                ? null
                : controller.propertyType.value,
            items: PropertyPostController.propertyTypes,
            itemLabel: (t) => t[0].toUpperCase() + t.substring(1),
            onChanged: (v) {
              if (v != null) controller.propertyType.value = v;
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 2 — Location
// ---------------------------------------------------------------------------

class _LocationSection extends StatelessWidget {
  final PropertyPostController controller;
  const _LocationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => _StyledDropdown<String>(
            label: 'Division',
            icon: Icons.map_outlined,
            value: controller.division.value.isEmpty
                ? null
                : controller.division.value,
            items: PropertyPostController.divisions,
            itemLabel: (d) => d,
            onChanged: (v) {
              if (v != null) controller.division.value = v;
            },
          ),
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          label: 'District',
          hint: 'e.g. Dhaka',
          icon: Icons.location_city_outlined,
          onChanged: (v) => controller.district.value = v,
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          label: 'Upazila',
          hint: 'e.g. Dhanmondi',
          icon: Icons.place_outlined,
          onChanged: (v) => controller.upazila.value = v,
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          label: 'Area *',
          hint: 'e.g. Road 8, Dhanmondi',
          icon: Icons.near_me_outlined,
          onChanged: (v) => controller.area.value = v,
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          label: 'Road (optional)',
          hint: 'e.g. Road No. 12/A',
          icon: Icons.add_road_rounded,
          onChanged: (v) => controller.road.value = v,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 3 — Details
// ---------------------------------------------------------------------------

class _DetailsSection extends StatelessWidget {
  final PropertyPostController controller;
  const _DetailsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Price
        _StyledTextField(
          label: 'Price / Month',
          hint: '0.00',
          icon: Icons.currency_exchange_rounded,
          prefix: const Text(
            '৳ ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF6366F1),
            ),
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (v) =>
              controller.price.value = double.tryParse(v) ?? 0.0,
        ),
        const SizedBox(height: 16),
        Obx(() => _CounterRow(
              label: 'Bedrooms',
              icon: Icons.bed_outlined,
              value: controller.bedrooms.value,
              onDecrement: () {
                if (controller.bedrooms.value > 0) {
                  controller.bedrooms.value--;
                }
              },
              onIncrement: () => controller.bedrooms.value++,
            )),
        const SizedBox(height: 12),
        Obx(() => _CounterRow(
              label: 'Bathrooms',
              icon: Icons.bathroom_outlined,
              value: controller.bathrooms.value,
              onDecrement: () {
                if (controller.bathrooms.value > 0) {
                  controller.bathrooms.value--;
                }
              },
              onIncrement: () => controller.bathrooms.value++,
            )),
        const SizedBox(height: 12),
        Obx(() => _CounterRow(
              label: 'Floor',
              icon: Icons.layers_outlined,
              value: controller.floor.value,
              onDecrement: () {
                if (controller.floor.value > 0) {
                  controller.floor.value--;
                }
              },
              onIncrement: () => controller.floor.value++,
            )),
        const SizedBox(height: 16),
        // Area sqft
        _StyledTextField(
          label: 'Area (sqft)',
          hint: 'e.g. 1200',
          icon: Icons.square_foot_rounded,
          suffix: const Text(
            ' sqft',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (v) =>
              controller.areaSqft.value = double.tryParse(v) ?? 0.0,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 4 — Amenities
// ---------------------------------------------------------------------------

class _AmenitiesSection extends StatelessWidget {
  final PropertyPostController controller;
  const _AmenitiesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.amenities;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PropertyPostController.availableAmenities.map((amenity) {
          final isSelected = selected.contains(amenity);
          return FilterChip(
            label: Text(amenity),
            selected: isSelected,
            onSelected: (_) => controller.toggleAmenity(amenity),
            selectedColor: AppTheme.primary.withOpacity(0.15),
            checkmarkColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.grey.shade700,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide(
              color:
                  isSelected ? AppTheme.primary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.transparent,
            showCheckmark: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          );
        }).toList(),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Section 5 — Photos (stub)
// ---------------------------------------------------------------------------

class _PhotosSection extends StatelessWidget {
  final PropertyPostController controller;
  const _PhotosSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.images;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (images.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    images[i],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          DashedContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFFEC4899),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add Photos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFFEC4899),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Bottom Action Buttons
// ---------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  final PropertyPostController controller;
  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Obx(() {
        final isSubmitting = controller.isSubmitting.value;

        return Row(
          children: [
            // Save as Draft
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        await controller.saveDraft();
                      },
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Draft'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Submit for Review
            Expanded(
              child: Obx(
                () => FilledButton.icon(
                  onPressed: (isSubmitting || !controller.isEditing)
                      ? null
                      : () async {
                          await controller.submitForReview();
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor:
                        AppTheme.primary.withOpacity(0.35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Widgets
// ---------------------------------------------------------------------------

class _StyledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _StyledTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
        prefix: prefix,
        suffix: suffix,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.8),
        ),
        labelStyle: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppTheme.primary),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.8),
        ),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CounterRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla =
        Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrement,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              convert('$value'),
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _CounterButton(
            icon: Icons.add_rounded,
            onPressed: onIncrement,
            isAdd: true,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isAdd;

  const _CounterButton({
    required this.icon,
    required this.onPressed,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAdd
          ? AppTheme.primary.withOpacity(0.1)
          : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isAdd ? AppTheme.primary : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class DashedContainer extends StatelessWidget {
  final Widget child;

  const DashedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: const Color(0xFFEC4899)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 5.0;
    const radius = 16.0;

    final rect =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(radius));
    final path = Path()..addRRect(rect);

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final len =
            distance + dashWidth > metric.length ? metric.length - distance : dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}