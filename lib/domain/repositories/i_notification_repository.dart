import '../../data/models/notification_model.dart';

abstract class INotificationRepository {
  Future<void> sendNotification(NotificationModel notification);
  Stream<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Stream<int> getUnreadCount(String userId);
}
