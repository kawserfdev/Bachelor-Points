import 'package:flutter/material.dart';

class ToletItem {
  final String id;
  final String title;
  final String titleBn;
  final String description;
  final String descriptionBn;
  final String image;
  final double price;
  final String location;
  final String type; // 'Seat' or 'Full Flat'
  final int totalSeats;
  final int occupiedSeats;
  final String managerName;
  final String managerImage;

  ToletItem({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.description,
    required this.descriptionBn,
    required this.image,
    required this.price,
    required this.location,
    required this.type,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.managerName,
    required this.managerImage,
  });
}

// Global Mock Dataset
final List<ToletItem> mockTolets = [
  ToletItem(
    id: '1',
    title: 'Luxury Seat in Dhanmondi',
    titleBn: 'Elite Executive Living',
    description: 'Modern shared living space designed for professionals and students. Located in a quiet neighborhood with easy access to metro and public transport.',
    descriptionBn: 'উন্নতমানের এবং সুশৃঙ্খল মেস। পড়াশোনা বা চাকরির জন্য উপযুক্ত পরিবেশ। সিসিটিভি ক্যামেরা দ্বারা সুরক্ষিত এবং ২৪ ঘণ্টা পানির সুবিধা।',
    image: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    price: 4500,
    location: 'Road 15, Dhanmondi, Dhaka',
    type: 'Seat',
    totalSeats: 10,
    occupiedSeats: 8,
    managerName: 'Md. Ariful Islam',
    managerImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
  ),
  ToletItem(
    id: '2',
    title: '3BHK Corporate Flat',
    titleBn: '৩বিএইচকে কর্পোরেট ফ্ল্যাট',
    description: 'Beautifully curated corporate housing layout with full modern amenities.',
    descriptionBn: 'সম্পূর্ণ আধুনিক সুযোগ-সুবিধা সহ সুন্দর সাজানো কর্পোরেট হাউজিং লেআউট।',
    image: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80',
    price: 32000,
    location: 'Banani Block C, Dhaka',
    type: 'Full Flat',
    totalSeats: 1,
    occupiedSeats: 0,
    managerName: 'Asif Rahman',
    managerImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
  ),
  ToletItem(
    id: '3',
    title: 'Student Mess - Farmgate',
    titleBn: 'স্টুডেন্ট মেস - ফার্মগেট',
    description: 'Perfect for students looking for a focused and calm environment.',
    descriptionBn: 'মনোযোগী এবং শান্ত পরিবেশ খুঁজছেন এমন শিক্ষার্থীদের জন্য উপযুক্ত।',
    image: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=600&q=80',
    price: 3200,
    location: 'Tejgaon College Area',
    type: 'Seat',
    totalSeats: 6,
    occupiedSeats: 5,
    managerName: 'Kamal Hossain',
    managerImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
  ),
];