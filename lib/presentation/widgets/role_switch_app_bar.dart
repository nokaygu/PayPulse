import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_mode.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../data/models/notification_model.dart';
import '../screens/auth/bloc/auth_bloc.dart';
import '../screens/auth/bloc/auth_event.dart';

/// Görsellerin en üstünde yer alan PayPulse (B2C) veya Nova Tasarım Ltd. İşletme Paneli (B2B) üst barı.
class RoleSwitchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBusinessMode;
  final String? customTitle;
  final String? customSubtitle;
  final bool showBackButton;
  final List<Widget>? extraActions;

  const RoleSwitchAppBar({
    super.key,
    this.isBusinessMode = false,
    this.customTitle,
    this.customSubtitle,
    this.showBackButton = false,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final firebaseUser =
        AppMode.isDemoMode ? null : FirebaseAuth.instance.currentUser;
    final String currentUserId =
        authUser?.uid ?? firebaseUser?.uid ?? 'user_deniz_aksoy';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final appBarBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: appBarBg,
          border: Border(
            bottom: BorderSide(color: appBarBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (showBackButton) ...[
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(
                      isBusinessMode
                          ? AppRoutes.businessOverview
                          : AppRoutes.home,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Sol Başlık veya Marka Logosu
            if (customTitle != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customTitle!,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customSubtitle != null)
                      Text(
                        customSubtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              )
            else if (isBusinessMode)
              Expanded(
                child: InkWell(
                  onTap: () => _showRoleSwitchSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'NT',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Nova Tasarım Ltd.',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.darkNavy,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.darkNavy,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'İşletme Paneli',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryTeal,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: InkWell(
                  onTap: () => _showRoleSwitchSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryGreen.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            'assets/images/paypulse_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PayPulse',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      if (AppMode.isDemoMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Text(
                            'Demo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            if (extraActions != null) ...extraActions!,

            // Canlı Firestore Bildirim İkonu & Rozeti
            StreamBuilder<int>(
              stream: FirebaseFirestoreDatasource()
                  .watchUnreadNotificationCount(currentUserId),
              builder: (context, notifSnapshot) {
                final unreadCount = notifSnapshot.data ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showNotificationsSheet(context, currentUserId),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isBusinessMode
                                ? AppColors.expenseRed
                                : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 4),

            // Profil / Rol Değiştirme Avatarı
            GestureDetector(
              onTap: () => _showRoleSwitchSheet(context),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.darkNavy,
                child: Icon(
                  isBusinessMode ? Icons.person_outline_rounded : Icons.person,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Mod ve Rol Değiştir (Dual-Role)',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bireysel Cüzdan (B2C) ile İşletme Paneli (B2B) arasında anında geçiş yapın.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD1FAE5),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  title: Text(
                    'Deniz Aksoy — Bireysel Cüzdan (B2C)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Bakiye: ₺12.500,00 • FAST Transfer & Cüzdan',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(
                      const AuthRoleChanged('b2c'),
                    );
                    context.go(AppRoutes.home);
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.badge_outlined, color: Color(0xFFD97706)),
                  ),
                  title: Text(
                    'Ahmet Yılmaz — Şirket Çalışanı (Employee)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'PayPulse Teknoloji • Bakiye: ₺5.000,00 • Masraf Bildirimi',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(
                      const AuthRoleChanged('employee'),
                    );
                    context.go(AppRoutes.home);
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child:
                        Icon(Icons.business_center, color: AppColors.darkNavy),
                  ),
                  title: Text(
                    'Ali Yılmaz — Şirket Yöneticisi (Admin)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'PayPulse Teknoloji • Kasa: ₺50.000,00 • POS & Masraf Onay',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(const AuthRoleChanged('admin'));
                    context.go(AppRoutes.businessOverview);
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.logout_rounded, color: Color(0xFFB91C1C)),
                  ),
                  title: const Text(
                    'Güvenli Çıkış Yap',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Oturumu sonlandırıp giriş ekranına dön',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final datasource = FirebaseFirestoreDatasource();
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 450),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bildirimler',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: datasource.watchUserNotifications(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      );
                    }
                    final notifications = snapshot.data ?? [];
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni bildirim bulunmuyor.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, i) {
                        final n = notifications[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: n.isRead
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFFE0F2FE),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              size: 20,
                              color: n.isRead
                                  ? const Color(0xFF64748B)
                                  : AppColors.primaryTeal,
                            ),
                          ),
                          title: Text(
                            n.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: n.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          subtitle: Text(
                            n.body,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                          trailing: n.isRead
                              ? null
                              : IconButton(
                                  tooltip: 'Okundu İşaretle',
                                  icon: const Icon(
                                    Icons.done_all_rounded,
                                    size: 18,
                                    color: AppColors.primaryGreen,
                                  ),
                                  onPressed: () =>
                                      datasource.markNotificationAsRead(n.notificationId),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
