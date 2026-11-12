import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
                    context.go(isBusinessMode
                        ? AppRoutes.businessOverview
                        : AppRoutes.home);
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
                child: InkWell(
                  onTap: () => _showRoleSwitchSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primaryGreen,
                          size: 22,
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
                    ],
                  ),
                ),
              ),

            if (extraActions != null) ...extraActions!,

            // Bildirim İkonu
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('3 yeni bildirim: FAST ve GİB E-Fatura senkronize edildi.'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.darkNavy,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isBusinessMode
                          ? AppColors.expenseRed
                          : AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mod ve Rol Değiştir (Dual-Role)',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bireysel Cüzdan (B2C) ile İşletme Paneli (B2B) arasında anında geçiş yapın.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD1FAE5),
                  child: Icon(Icons.account_balance_wallet, color: AppColors.primaryGreen),
                ),
                title: const Text('Deniz Aksoy — Bireysel Cüzdan (B2C)'),
                subtitle: const Text('Müşteri No: PP-849201 • Kişisel Hesap'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(const AuthRoleChanged('employee'));
                  context.go(AppRoutes.home);
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.business_center, color: AppColors.darkNavy),
                ),
                title: const Text('Nova Tasarım Ltd. — İşletme Paneli (B2B)'),
                subtitle: const Text('Finans Yöneticisi (Admin) • POS, Masraf, KDV'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(const AuthRoleChanged('admin'));
                  context.go(AppRoutes.businessOverview);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

