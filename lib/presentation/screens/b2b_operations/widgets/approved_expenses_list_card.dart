import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bulk_expense_erp_receipt_screen.dart';
import 'approved_expense_line_item.dart';

/// Onaylanan masraf kalemleri listesi ve PDF / Geri dönüş aksiyon butonları.
class ApprovedExpensesListCard extends StatelessWidget {
  final BulkExpenseReceiptArgs data;
  final VoidCallback onDownloadPdf;
  final VoidCallback onBackToApprovalCenter;

  const ApprovedExpensesListCard({
    super.key,
    required this.data,
    required this.onDownloadPdf,
    required this.onBackToApprovalCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Onaylanan Kalemler (${data.approvedExpenses.length})',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              'ERP Defter Kayıtları',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...data.approvedExpenses.map(
          (exp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ApprovedExpenseLineItem(expense: exp),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onDownloadPdf,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text(
              'ERP Muhasebe Dekontunu İndir (PDF)',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkNavy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onBackToApprovalCenter,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'Masraf Onay Merkezine Dön',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

