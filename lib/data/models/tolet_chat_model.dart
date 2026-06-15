import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat message for property-related conversations between
/// tenants and landlords.
class ToletMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? text;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isSeen;
  final bool isTyping;
  final String? reportedBy;
  final String? reportReason;
  final DateTime createdAt;

  ToletMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.text,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isSeen = false,
    this.isTyping = false,
    this.reportedBy,
    this.reportReason,
    required this.createdAt,
  });

  factory ToletMessageModel.fromJson(Map<String, dynamic> json) {
    return ToletMessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? '',
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isSeen: json['is_seen'] as bool? ?? false,
      isTyping: json['is_typing'] as bool? ?? false,
      reportedBy: json['reported_by'] as String?,
      reportReason: json['report_reason'] as String?,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'is_seen': isSeen,
      'is_typing': isTyping,
      'reported_by': reportedBy,
      'report_reason': reportReason,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

/// A chat conversation between a tenant and a landlord about a property.
class ToletChatModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  ToletChatModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ToletChatModel.fromJson(Map<String, dynamic> json) {
    return ToletChatModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      tenantId: json['tenant_id'] as String,
      landlordId: json['landlord_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? (json['last_message_at'] is Timestamp
              ? (json['last_message_at'] as Timestamp).toDate()
              : DateTime.parse(json['last_message_at'] as String))
          : null,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'property_id': propertyId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}