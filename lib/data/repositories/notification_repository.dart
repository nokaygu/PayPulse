import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository implements INotificationRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  NotificationRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<void> sendNotification(NotificationModel notification) {
    return _firestoreDatasource.createNotification(notification);
  }

  @override
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestoreDatasource.watchUserNotifications(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _firestoreDatasource.markNotificationAsRead(notificationId);
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firestoreDatasource.watchUnreadNotificationCount(userId);
  }
}
