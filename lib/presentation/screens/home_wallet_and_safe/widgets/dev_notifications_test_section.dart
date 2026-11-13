import 'package:flutter/material.dart';

import '../../../../data/models/notification_model.dart';
import '../bloc/dev_console_cubit.dart';
import 'dev_section_card.dart';

class DevNotificationsTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final String userId;

  const DevNotificationsTestSection({
    super.key,
    required this.cubit,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '3. Canlı Uygulama İçi Bildirimler (macOS / Cross-Platform)',
      crossAxisAlignment: CrossAxisAlignment.start,
      child: SizedBox(
        height: 160,
        child: StreamBuilder<List<NotificationModel>>(
          stream: cubit.watchUserNotifications(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Henüz bir bildirim yok.'));
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final notif = list[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    notif.type == 'transfer_received'
                        ? Icons.arrow_downward_rounded
                        : (notif.type == 'expense_approved'
                            ? Icons.check_circle_outline
                            : Icons.notifications),
                    color: notif.isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif.body),
                  trailing: notif.isRead
                      ? const Text(
                          'Okundu',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      : IconButton(
                          icon: const Icon(Icons.done, size: 16),
                          onPressed: () => cubit.markNotificationAsRead(
                            notif.notificationId,
                          ),
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

