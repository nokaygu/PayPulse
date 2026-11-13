import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'business_quick_action_box.dart';

class BusinessQuickActionsGrid extends StatelessWidget {
  final int pendingExpenseCount;

  const BusinessQuickActionsGrid({
    super.key,
    required this.pendingExpenseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Hızlı İşlemler',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Kurumsal Kısa Yollar',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: BusinessQuickActionBox(
                icon: Icons.point_of_sale_rounded,
                badgeText: 'ÖNE ÇIKAN',
                badgeBg: const Color(0xFF065F46),
                badgeFg: Colors.white,
                title: 'POS ile Tahsilat',
                subtitle: 'Sanal ve Temassız POS',
                isHighlighted: true,
                onTap: () => context.go(AppRoutes.businessPos),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BusinessQuickActionBox(
                icon: Icons.document_scanner_outlined,
                badgeText: 'Akıllı OCR',
                badgeBg: const Color(0xFFE0F2FE),
                badgeFg: AppColors.darkNavy,
                title: 'Fatura Tara',
                subtitle: 'Gider fişini anında işle',
                isHighlighted: false,
                onTap: () => context.push(AppRoutes.businessOcrScan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: BusinessQuickActionBox(
                icon: Icons.fact_check_outlined,
                badgeText: '● $pendingExpenseCount Bekleyen',
                badgeBg: const Color(0xFFFEE2E2),
                badgeFg: const Color(0xFFDC2626),
                title: 'Masraf Onayları',
                subtitle: 'Personel harcamaları',
                isHighlighted: false,
                onTap: () => context.go(AppRoutes.businessExpenses),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BusinessQuickActionBox(
                icon: Icons.link_rounded,
                badgeText: '→',
                badgeBg: const Color(0xFFF1F5F9),
                badgeFg: AppColors.darkNavy,
                title: 'Ödeme Linki',
                subtitle: 'WhatsApp & SMS Paylaş',
                isHighlighted: false,
                onTap: () => context.push('/pay/LNK-4402'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

