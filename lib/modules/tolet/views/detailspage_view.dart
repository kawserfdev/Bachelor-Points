import 'package:flutter/material.dart';

import '../../../data/models/toletItem_model.dart';
import '../../../core/localization/number_converter.dart';

class DetailsPage extends StatelessWidget {
  final ToletItem item;

  const DetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBangla =
        Localizations.localeOf(context).languageCode == 'bn';
    String convert(String text) =>
        isBangla ? NumberConverter.englishToBangla(text) : text;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Details (বিস্তারিত)',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Top Main Image Block
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(item.image, height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
            ),

            // Base Info Container
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(4)),
                              child: Text('STUDENT MESS • ছাত্র মেস', style: TextStyle(color: const Color(0xFF0D9488), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(item.titleBn, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('MONTHLY / মাসিক', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(convert('৳ ${item.price.toStringAsFixed(0)}'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                         Text('+ Utilities (বিদ্যুৎ বিল আলাদা)', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.right),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF0D9488), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.location}\n(সেক্টর ১০, উত্তরা, ঢাকা)',
                          style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // Amenity Icon Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildAmenityCard(Icons.wifi, 'HIGH SPEED WIFI', '(ওয়াইফাই)'),
                  _buildAmenityCard(Icons.restaurant, '3 MEALS/DAY', '(তিনবেলা খাবার)'),
                  _buildAmenityCard(Icons.cleaning_services, 'CLEANING', '(পরিচ্ছন্নতা)'),
                  _buildAmenityCard(Icons.security, '24/7 SECURITY', '(নিরাপত্তা)'),
                ],
              ),
            ),

            // Description Block
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DESCRIPTION / বর্ণনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(item.description, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4)),
                  const SizedBox(height: 8),
                  Text(item.descriptionBn, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),

            // Location Interactive Mini Map Box Component
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOCATION / মানচিত্র', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=600&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 30),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Landlord / Manager Details
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MANAGED BY / ব্যবস্থাপক', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundImage: NetworkImage(item.managerImage)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.managerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Verified Manager (যাচাইকৃত)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          label: const Text('CALL'),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('CHAT'),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Live Vacancy Widget Bar
            _buildSectionContainer(
              color: const Color(0xFF1E3A8A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VACANCY / আসন খালি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)),
                        child: Text(convert('${item.totalSeats - item.occupiedSeats} LEFT'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: item.occupiedSeats / item.totalSeats,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFF10B981),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    convert('${item.occupiedSeats} of ${item.totalSeats} seats occupied (${item.totalSeats}টির মধ্যে ${item.occupiedSeats}টি বুকড)'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  )
                ],
              ),
            ),

            // Terms Notes Block Footnote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.teal, size: 16),
                      SizedBox(width: 8),
                      Text('Advance: 1 Month Rent (১ মাসের অগ্রিম)', style: TextStyle(fontSize: 13, color: Colors.black87))
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.teal, size: 16),
                      SizedBox(width: 8),
                      Text('Notice period: 1 Month (১ মাসের নোটিশ)', style: TextStyle(fontSize: 13, color: Colors.black87))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),

      // Sticky Bottom Footer Interaction CTA Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002266),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text(
            'Send Booking Request (বুকিং রিকোয়েস্ট পাঠান)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Refactored UI helper elements to clean up code footprint
  Widget _buildSectionContainer({required Widget child, Color color = Colors.white}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: color == Colors.white ? Border.all(color: const Color(0xFFE2E8F0)) : null,
      ),
      child: child,
    );
  }

  Widget _buildAmenityCard(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}