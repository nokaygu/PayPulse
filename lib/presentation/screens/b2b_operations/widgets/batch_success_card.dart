import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bulk_expense_erp_receipt_screen.dart';
import 'erp_integration_card.dart';

/// Toplu masraf onayı başarı özet kartı (`StatelessWidget`).
class BatchSuccessCard extends StatelessWidget {
  final BulkExpenseReceiptArgs data;

  const BatchSuccessCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dt = data.approvedAt;
    final formattedDate =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.darkNavy,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF5EEAD4),
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${data.approvedExpenses.length} Masraf Başarıyla\nOnaylandı!',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gider fişleri kurum içi politikalarla denetlendi\nve muhasebe defterine aktarıldı.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          _BatchTotalSummaryBox(data: data),
          const SizedBox(height: 16),
          ErpDetailRow(label: 'Onay Zamanı', value: formattedDate),
          const SizedBox(height: 8),
          ErpDetailRow(label: 'Onay Yetkilisi', value: data.approverName),
          const SizedBox(height: 8),
          ErpDetailRow(label: 'Toplu İşlem No', value: data.batchId),
        ],
      ),
    );
  }
}

class _BatchTotalSummaryBox extends StatelessWidget {
  final BulkExpenseReceiptArgs data;

  const _BatchTotalSummaryBox({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'ONAYLANAN TOPLAM TUTAR',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF64748B),
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FinancialAmount.format(data.totalAmountKurus),
            style: AppTextStyles.numericBalance.copyWith(
              color: AppColors.darkNavy,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+${FinancialAmount.format(data.totalVatKurus)} KDV İndirimi Şirket Hesabına Yansıtıldı',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF065F46),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

