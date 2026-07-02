import 'package:bachelorpoints/core/theme/app_theme.dart';
import 'package:bachelorpoints/data/models/property_model.dart';
import 'package:bachelorpoints/modules/tolet/listing_management/listing_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/number_converter.dart';

class ListingManagementView extends StatelessWidget {
  const ListingManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ListingManagementController>();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Listings'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Rejected'),
              Tab(text: 'Expired'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _ListingTab(
                listingsBuilder: () => controller.activeListings,
                emptyIcon: Icons.home_outlined,
                emptyMessage: 'No active listings',
                tabStatus: 'active',
                controller: controller,
              ),
              _ListingTab(
                listingsBuilder: () => controller.pendingListings,
                emptyIcon: Icons.hourglass_empty_outlined,
                emptyMessage: 'No pending listings',
                tabStatus: 'pending',
                controller: controller,
              ),
              _ListingTab(
                listingsBuilder: () => controller.rejectedListings,
                emptyIcon: Icons.cancel_outlined,
                emptyMessage: 'No rejected listings',
                tabStatus: 'rejected',
                controller: controller,
              ),
              _ListingTab(
                listingsBuilder: () => controller.expiredListings,
                emptyIcon: Icons.timer_off_outlined,
                emptyMessage: 'No expired listings',
                tabStatus: 'expired',
                controller: controller,
              ),
              _ListingTab(
                listingsBuilder: () => controller.archivedListings,
                emptyIcon: Icons.archive_outlined,
                emptyMessage: 'No archived listings',
                tabStatus: 'archived',
                controller: controller,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ListingTab extends StatelessWidget {
  final RxList<PropertyModel> Function() listingsBuilder;
  final IconData emptyIcon;
  final String emptyMessage;
  final String tabStatus;
  final ListingManagementController controller;

  const _ListingTab({
    required this.listingsBuilder,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.tabStatus,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final listings = listingsBuilder();
      if (listings.isEmpty) {
        return _EmptyState(icon: emptyIcon, message: emptyMessage);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final property = listings[index];
          return _PropertyCard(
            property: property,
            tabStatus: tabStatus,
            controller: controller,
          );
        },
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final String tabStatus;
  final ListingManagementController controller;

  const _PropertyCard({
    required this.property,
    required this.tabStatus,
    required this.controller,
  });

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'expired':
      case 'archived':
      default:
        return Colors.grey;
    }
  }

  List<PopupMenuEntry<String>> _menuItems() {
    switch (tabStatus) {
      case 'active':
        return const [
          PopupMenuItem(value: 'boost', child: Text('Boost')),
          PopupMenuItem(value: 'archive', child: Text('Archive')),
        ];
      case 'draft':
      case 'pending':
        return const [
          PopupMenuItem(value: 'delete', child: Text('Delete')),
          PopupMenuItem(value: 'archive', child: Text('Archive')),
        ];
      case 'rejected':
        return const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ];
      case 'expired':
      case 'archived':
      default:
        return const [
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ];
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'boost':
        controller.boostListing(property.id);
        break;
      case 'archive':
        controller.archiveListing(property.id);
        break;
      case 'delete':
        controller.deleteListing(property.id);
        break;
      case 'edit':
        context.push('/tolet/post');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(property.status);
    final thumbnail =
        (property.images != null && property.images!.isNotEmpty)
            ? property.images!.first
            : null;
    final isBangla =
        Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tolet/property?id=${property.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnail != null
                        ? Image.network(
                            thumbnail,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _PlaceholderImage(),
                          )
                        : _PlaceholderImage(),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                property.title ?? 'Untitled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (value) =>
                                  _onMenuSelected(context, value),
                              itemBuilder: (_) => _menuItems(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          convert('৳${property.price ?? '-'} · ${property.area ?? ''}, ${property.district ?? ''}'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                (property.status ?? 'unknown')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (property.isBoosted == true) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.5),
                                  ),
                                ),
                                child: const Text(
                                  '⚡ BOOSTED',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Rejection notes
              if (property.status?.toLowerCase() == 'rejected' &&
                  property.reviewNotes != null &&
                  property.reviewNotes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.reviewNotes!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.home_outlined, color: Colors.grey[400], size: 32),
    );
  }
}