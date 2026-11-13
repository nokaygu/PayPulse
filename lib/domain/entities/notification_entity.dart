import '../../core/utils/equatable.dart';

/// Uygulama içi bildirimleri temsil eden saf Domain Entity sınıfı.
class NotificationEntity extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  NotificationEntity copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) {
    return NotificationEntity(
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

  @override
  List<Object?> get props => [
    notificationId,
    userId,
    title,
    body,
    type,
    isRead,
    createdAt,
    relatedId,
  ];
}

