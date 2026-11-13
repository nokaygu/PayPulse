import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../screens/auth/bloc/auth_bloc.dart';
import '../screens/auth/bloc/auth_event.dart';
import 'bloc/notification_cubit.dart';

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
    final String currentUserId = authUser?.uid ?? AppStrings.demoB2CUid;
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
                                      color: primaryTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: primaryTextColor,
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
                        color: primaryTextColor,
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

            if (extraActions != null) ...?extraActions,

            // BLoC Bildirim İkonu & Rozeti
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, notifState) {
                final unreadCount = notifState.unreadCount;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showNotificationsSheet(context, currentUserId),
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: primaryTextColor,
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
                backgroundColor:
                    isDark ? const Color(0xFF334155) : AppColors.darkNavy,
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
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final currentRole = authState.role;
    final isDemo = AppMode.isDemoMode;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final handleColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final titleColor = isDark ? Colors.white : AppColors.darkNavy;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final logoutBg = isDark
        ? const Color(0xFF450A0A).withValues(alpha: 0.55)
        : const Color(0xFFFEE2E2).withValues(alpha: 0.5);
    final logoutBorder =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
    final logoutIconBg =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
    final logoutAccent =
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
    final logoutSubColor =
        isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: handleColor,
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
                              isDemo
                                  ? 'Mod ve Rol Değiştir (Dual-Role)'
                                  : 'Hesap ve Görünüm Modu',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDemo
                                  ? 'Bireysel Cüzdan ile İşletme Paneli arasında anında geçiş yapın.'
                                  : 'Yetkili hesabınızın panel görünümünü ve oturumunu yönetin.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: subtitleColor,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isDemo) ...[
                    // 1. Deniz Aksoy — B2C
                    _buildRoleCard(
                      context: context,
                      ctx: ctx,
                      isDark: isDark,
                      role: AppStrings.roleB2C,
                      isActive: currentRole == AppStrings.roleB2C,
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
                      isDark: isDark,
                      role: AppStrings.roleEmployee,
                      isActive: currentRole == AppStrings.roleEmployee,
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
                      isDark: isDark,
                      role: AppStrings.roleAdmin,
                      isActive: currentRole == AppStrings.roleAdmin,
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
                  ] else if (authState.canAccessBusinessPanel) ...[
                    _buildRoleCard(
                      context: context,
                      ctx: ctx,
                      isDark: isDark,
                      role: AppStrings.roleB2C,
                      isActive: !authState.isBusinessMode,
                      icon: Icons.account_balance_wallet_rounded,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: AppColors.primaryGreen,
                      title: authState.user?.name ?? 'Kullanıcı',
                      roleBadge: 'Bireysel Görünüm',
                      badgeBg: const Color(0xFFD1FAE5),
                      badgeColor: const Color(0xFF065F46),
                      subtitle: 'Kişisel cüzdan ve FAST transfer görünümü',
                      targetRoute: AppRoutes.home,
                      onTapOverride: () {
                        authBloc.add(
                          const AuthPanelModeToggled(isBusinessMode: false),
                        );
                        context.go(AppRoutes.home);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildRoleCard(
                      context: context,
                      ctx: ctx,
                      isDark: isDark,
                      role: currentRole,
                      isActive: authState.isBusinessMode,
                      icon: Icons.business_center_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.darkNavy,
                      title: AppStrings.defaultCompanyName,
                      roleBadge: authState.isAdmin ? 'Yönetici' : 'Personel',
                      badgeBg: const Color(0xFFE0F2FE),
                      badgeColor: const Color(0xFF0369A1),
                      subtitle: 'Kurumsal kasa, masraf ve tahsilat görünümü',
                      targetRoute: AppRoutes.businessOverview,
                      onTapOverride: () {
                        authBloc.add(
                          const AuthPanelModeToggled(isBusinessMode: true),
                        );
                        context.go(AppRoutes.businessOverview);
                      },
                    ),
                  ] else ...[
                    _buildRoleCard(
                      context: context,
                      ctx: ctx,
                      isDark: isDark,
                      role: currentRole,
                      isActive: true,
                      icon: Icons.verified_user_rounded,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: AppColors.primaryGreen,
                      title: authState.user?.name ?? 'Kullanıcı',
                      roleBadge: 'Bireysel Hesap',
                      badgeBg: const Color(0xFFD1FAE5),
                      badgeColor: const Color(0xFF065F46),
                      subtitle: authState.user?.email ?? '',
                      targetRoute: AppRoutes.home,
                      onTapOverride: () {},
                    ),
                  ],
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
                        color: logoutBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: logoutBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: logoutIconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: logoutAccent,
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
                                    color: logoutAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Oturumu sonlandırıp giriş ekranına dön',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: logoutSubColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: logoutAccent,
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
    required bool isDark,
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
    VoidCallback? onTapOverride,
  }) {
    final cardBg = isActive
        ? (isDark
            ? AppColors.primaryGreen.withValues(alpha: 0.16)
            : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC));
    final cardBorder = isActive
        ? AppColors.primaryGreen
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final primaryText = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final trailingArrowColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        if (onTapOverride != null) {
          onTapOverride();
        } else if (AppMode.isDemoMode) {
          context.read<AuthBloc>().add(AuthRoleChanged(role));
          context.go(targetRoute);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cardBorder,
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
                            color: primaryText,
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
                      color: secondaryText,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: trailingArrowColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, String userId) {
    final notificationCubit = context.read<NotificationCubit>();
    notificationCubit.watchForUser(userId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final emptyIconColor =
        isDark ? const Color(0xFF475569) : Colors.grey.shade400;
    final readAvatarBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final unreadAvatarBg = isDark
        ? AppColors.primaryTeal.withValues(alpha: 0.22)
        : const Color(0xFFE0F2FE);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider<NotificationCubit>.value(
          value: notificationCubit,
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, notifState) {
                final notifications = notifState.notifications;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bildirimler',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (notifState.unreadCount > 0)
                              TextButton(
                                onPressed: () => notificationCubit.markAllAsRead(),
                                child: const Text('Tümünü Oku'),
                              ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: secondaryColor),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 1, color: dividerColor),
                    Expanded(
                      child: notifState.isLoading && notifications.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryTeal,
                              ),
                            )
                          : notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 40,
                                    color: emptyIconColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Yeni bildirim bulunmuyor.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: notifications.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1, color: dividerColor),
                              itemBuilder: (context, i) {
                                final n = notifications[i];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        n.isRead ? readAvatarBg : unreadAvatarBg,
                                    child: Icon(
                                      Icons.notifications_active_outlined,
                                      size: 20,
                                      color: n.isRead
                                          ? secondaryColor
                                          : AppColors.primaryTeal,
                                    ),
                                  ),
                                  title: Text(
                                    n.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: n.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    n.body,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: secondaryColor,
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
                                          onPressed: () => notificationCubit
                                              .markAsRead(n.notificationId),
                                        ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
