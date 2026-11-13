import '../entities/notification_entity.dart';

/// Clean Architecture Domain Katmanı: Uygulama İçi Bildirim Sözleşmesi
abstract class INotificationRepository {
  Future<void> sendNotification(NotificationEntity notification);
  Stream<List<NotificationEntity>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Stream<int> getUnreadCount(String userId);
}
