import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../listing_management/listing_management_controller.dart';
import '../../../data/models/property_model.dart';

/// Manage user's property listings by status.
class ListingManagementView extends GetView<ListingManagementController> {
  const ListingManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Listings'), bottom: const TabBar(isScrollable: true, tabs: [
          Tab(text: 'Active'), Tab(text: 'Pending'), Tab(text: 'Rejected'), Tab(text: 'Expired'), Tab(text: 'Archived'),
        ])),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          return TabBarView(children: [
            _buildTab(context, controller.activeListings),
            _buildTab(context, controller.pendingListings),
            _buildTab(context, controller.rejectedListings),
            _buildTab(context, controller.expiredListings),
            _buildTab(context, controller.archivedListings),
          ]);
        }),
      ),
    );
  }

  Widget _buildTab(BuildContext context, List<PropertyModel> items) {
    if (items.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home_outlined, size: 48, color: Colors.grey[400]), const SizedBox(height: 8), Text('No listings', style: TextStyle(color: Colors.grey[500]))]));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(child: Icon(_statusIcon(p.status), size: 20)),
            title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('₹${p.price.toInt()}/mo • ${p.area}'),
            trailing: PopupMenuButton(itemBuilder: (ctx) => [
              if (p.status == 'draft') const PopupMenuItem(value: 'delete', child: Text('Delete')),
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
            ], onSelected: (v) {
              if (v == 'delete') controller.deleteListing(p.id);
              if (v == 'archive') controller.archiveListing(p.id);
            }),
          ),
        );
      },
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'live': case 'approved': return Icons.check_circle;
      case 'draft': case 'submitted': case 'under_review': return Icons.hourglass_bottom;
      case 'rejected': return Icons.cancel;
      case 'expired': return Icons.timer_off;
      case 'archived': return Icons.archive;
      default: return Icons.help;
    }
  }
}