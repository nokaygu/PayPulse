import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository implements INotificationRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  NotificationRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<void> sendNotification(NotificationEntity notification) {
    return _firestoreDatasource.createNotification(
      NotificationModel.fromEntity(notification),
    );
  }

  @override
  Stream<List<NotificationEntity>> getUserNotifications(String userId) {
    return _firestoreDatasource
        .watchUserNotifications(userId)
        .map((list) => list.map((n) => n.toEntity()).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _firestoreDatasource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return _firestoreDatasource.markAllNotificationsAsRead(userId);
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firestoreDatasource.watchUnreadNotificationCount(userId);
  }
}
