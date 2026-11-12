import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore tabanlı uygulama içi bildirim modeli.
/// macOS sunumu dahil tüm platformlarda gerçek zamanlı bildirim akışı sağlar.
class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // 'transfer_received', 'expense_created', 'expense_approved', 'expense_rejected', 'fraud_alert', 'general'
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    DateTime parsedDate;
    if (rawCreatedAt is Timestamp) {
      parsedDate = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedDate = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is DateTime) {
      parsedDate = rawCreatedAt;
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      notificationId: json['notificationId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: parsedDate,
      relatedId: json['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (relatedId != null) 'relatedId': relatedId,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
