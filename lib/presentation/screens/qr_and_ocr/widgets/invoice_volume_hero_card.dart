import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/e_invoice_cubit.dart';

/// GİB E-Fatura hacmi ve toplam KDV özet hero kartı.
class InvoiceVolumeHeroCard extends StatelessWidget {
  final EInvoiceState state;
  final VoidCallback onXmlExport;

  const InvoiceVolumeHeroCard({
    super.key,
    required this.state,
    required this.onXmlExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroHeaderRow(),
          const SizedBox(height: 14),
          Text(
            state.isIncomingTab
                ? 'Toplam Gelen (Alış) Fatura Tutarı'
                : 'Toplam Giden (Satış) Fatura Tutarı',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                state.formattedActiveTabTotal,
                style: AppTextStyles.numericBalance.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              Text(
                state.formattedActiveTabVat,
                style: AppTextStyles.labelMedium.copyWith(
                  color: const Color(0xFF5EEAD4),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onXmlExport,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Toplu GİB XML İndir',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeaderRow extends StatelessWidget {
  const _HeroHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF5EEAD4),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'E-Fatura Hacmi\nGİB Entegrasyon Özeti',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF94A3B8),
                height: 1.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '%100 GİB\nUyumlu',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF5EEAD4),
              fontSize: 10,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

