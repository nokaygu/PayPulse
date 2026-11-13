import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'widgets/approved_expenses_list_card.dart';
import 'widgets/batch_success_card.dart';
import 'widgets/erp_integration_card.dart';

/// Toplu masraf onayı sonrası ERP dekontu ekranına aktarılan gerçek onay verileri.
class BulkExpenseReceiptArgs {
  final List<ExpenseEntity> approvedExpenses;
  final String approverName;
  final DateTime approvedAt;
  final String batchId;

  const BulkExpenseReceiptArgs({
    required this.approvedExpenses,
    required this.approverName,
    required this.approvedAt,
    required this.batchId,
  });

  int get totalAmountKurus =>
      approvedExpenses.fold<int>(0, (sum, e) => sum + e.amount);

  int get totalVatKurus =>
      approvedExpenses.fold<int>(0, (sum, e) => sum + e.vatAmount);
}

/// Toplu Onay Protokolü & ERP Muhasebe Dekontu Ekranı (`StatelessWidget`).
class BulkExpenseErpReceiptScreen extends StatelessWidget {
  final BulkExpenseReceiptArgs? args;

  const BulkExpenseErpReceiptScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final data = args;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const RoleSwitchAppBar(isBusinessMode: true),
      body: FourStateView(
        status: (data == null || data.approvedExpenses.isEmpty)
            ? ViewStatus.empty
            : ViewStatus.success,
        emptyMessage:
            'Henüz tamamlanmış bir toplu masraf onayı bulunmuyor. Masraf Onay Merkezi üzerinden bekleyen fişleri topluca onaylayabilirsiniz.',
        onRetry: () => context.go(AppRoutes.businessExpenses),
        child: data == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProtocolTopBar(
                      onClose: () => context.go(AppRoutes.businessExpenses),
                    ),
                    const SizedBox(height: 14),
                    BatchSuccessCard(data: data),
                    const SizedBox(height: 16),
                    ErpIntegrationCard(batchId: data.batchId),
                    const SizedBox(height: 16),
                    ApprovedExpensesListCard(
                      data: data,
                      onDownloadPdf: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${data.batchId} ERP Muhasebe Dekontu (PDF) hazırlandı.',
                            ),
                          ),
                        );
                      },
                      onBackToApprovalCenter: () =>
                          context.go(AppRoutes.businessExpenses),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProtocolTopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _ProtocolTopBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 18,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 6),
            Text(
              'Toplu Onay Protokolü',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}
