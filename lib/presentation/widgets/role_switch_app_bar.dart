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

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.darkNavy,
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
                        color: AppColors.darkNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customSubtitle != null)
                      Text(
                        customSubtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
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
    final currentRole = context.read<AuthBloc>().state.role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sürüklenebilir Tutamaç (Handle Bar)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Başlık Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mod ve Rol Değiştir (Dual-Role)',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bireysel Cüzdan ile İşletme Paneli arasında anında geçiş yapın.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Deniz Aksoy — B2C
                  _buildRoleCard(
                    context: context,
                    ctx: ctx,
                    role: 'b2c',
                    isActive: currentRole == 'b2c',
                    icon: Icons.account_balance_wallet_rounded,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: AppColors.primaryGreen,
                    title: 'Deniz Aksoy',
                    roleBadge: 'Bireysel (B2C)',
                    badgeBg: const Color(0xFFD1FAE5),
                    badgeColor: const Color(0xFF065F46),
                    subtitle: 'Bakiye: ₺12.500,00 • FAST Transfer & Cüzdan',
                    targetRoute: AppRoutes.home,
                  ),
                  const SizedBox(height: 10),

                  // 2. Ahmet Yılmaz — Employee
                  _buildRoleCard(
                    context: context,
                    ctx: ctx,
                    role: 'employee',
                    isActive: currentRole == 'employee',
                    icon: Icons.badge_outlined,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Ahmet Yılmaz',
                    roleBadge: 'Şirket Çalışanı',
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeColor: const Color(0xFF92400E),
                    subtitle: 'PayPulse Teknoloji • ₺5.000,00 • Masraf Bildirimi',
                    targetRoute: AppRoutes.home,
                  ),
                  const SizedBox(height: 10),

                  // 3. Ali Yılmaz — Admin
                  _buildRoleCard(
                    context: context,
                    ctx: ctx,
                    role: 'admin',
                    isActive: currentRole == 'admin',
                    icon: Icons.business_center_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: AppColors.darkNavy,
                    title: 'Ali Yılmaz',
                    roleBadge: 'Şirket Yöneticisi',
                    badgeBg: const Color(0xFFE0F2FE),
                    badgeColor: const Color(0xFF0369A1),
                    subtitle: 'PayPulse Teknoloji • Kasa: ₺50.000,00 • POS & Onay',
                    targetRoute: AppRoutes.businessOverview,
                  ),
                  const SizedBox(height: 16),

                  // 4. Güvenli Çıkış Butonu
                  InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                      context.go(AppRoutes.login);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Güvenli Çıkış Yap',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: const Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Oturumu sonlandırıp giriş ekranına dön',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF991B1B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFFB91C1C),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required BuildContext ctx,
    required String role,
    required bool isActive,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String roleBadge,
    required Color badgeBg,
    required Color badgeColor,
    required String subtitle,
    required String targetRoute,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        context.read<AuthBloc>().add(AuthRoleChanged(role));
        context.go(targetRoute);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleBadge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final datasource = FirebaseFirestoreDatasource();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
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
