import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/equatable.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/i_notification_repository.dart';

/// Bildirim listesi ve okunmamış sayaç durumu.
class NotificationState extends Equatable {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? activeUserId;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.activeUserId,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? activeUserId,
    bool clearActiveUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      activeUserId: clearActiveUser
          ? null
          : (activeUserId ?? this.activeUserId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    isLoading,
    activeUserId,
    errorMessage,
  ];
}

/// Uygulama içi bildirim akışını Domain [INotificationRepository] üzerinden yönetir.
class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationEntity>>? _notificationsSub;
  StreamSubscription<int>? _unreadCountSub;

  NotificationCubit({required INotificationRepository repository})
    : _notificationRepository = repository,
      super(const NotificationState());

  Future<void> watchForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      await _cancelSubscriptions();
      emit(const NotificationState());
      return;
    }

    if (userId == state.activeUserId && _notificationsSub != null) {
      return;
    }

    await _cancelSubscriptions();
    emit(
      state.copyWith(
        isLoading: true,
        activeUserId: userId,
        clearError: true,
      ),
    );

    _notificationsSub = _notificationRepository
        .getUserNotifications(userId)
        .listen(
          (items) {
            emit(
              state.copyWith(
                notifications: items,
                unreadCount: items.where((n) => !n.isRead).length,
                isLoading: false,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: 'Bildirimler yüklenemedi.',
              ),
            );
          },
        );

    _unreadCountSub = _notificationRepository
        .getUnreadCount(userId)
        .listen((count) {
          emit(state.copyWith(unreadCount: count));
        });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Bildirim güncellenemedi.'));
    }
  }

  Future<void> markAllAsRead() async {
    final userId = state.activeUserId;
    if (userId == null || userId.isEmpty) return;
    try {
      await _notificationRepository.markAllAsRead(userId);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Bildirimler okundu işaretlenemedi.'));
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _notificationsSub?.cancel();
    await _unreadCountSub?.cancel();
    _notificationsSub = null;
    _unreadCountSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
