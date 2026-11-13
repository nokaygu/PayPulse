import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';

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

/// Toplu Onay Protokolü & ERP Muhasebe Dekontu Ekranı (Stateless + Real Args)
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
                    // Üst Satır
                    Row(
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
                          onTap: () => context.go(AppRoutes.businessExpenses),
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
                    ),
                    const SizedBox(height: 14),

                    // 1. Ana Onay Başarı Kartı
                    _BatchSuccessCard(data: data),
                    const SizedBox(height: 16),

                    // 2. ERP & Muhasebe Entegrasyonu Kartı
                    _ErpIntegrationCard(batchId: data.batchId),
                    const SizedBox(height: 16),

                    // 3. Onaylanan Gerçek Kalemler Listesi
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
                        child: _ApprovedLineItem(expense: exp),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. Aksiyon Butonları
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${data.batchId} ERP Muhasebe Dekontu (PDF) hazırlandı.',
                              ),
                            ),
                          );
                        },
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
                        onPressed: () => context.go(AppRoutes.businessExpenses),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Masraf Onay Merkezine Dön',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BatchSuccessCard extends StatelessWidget {
  final BulkExpenseReceiptArgs data;

  const _BatchSuccessCard({required this.data});

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
          Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Onay Zamanı', value: formattedDate),
          const SizedBox(height: 8),
          _DetailRow(label: 'Onay Yetkilisi', value: data.approverName),
          const SizedBox(height: 8),
          _DetailRow(label: 'Toplu İşlem No', value: data.batchId),
        ],
      ),
    );
  }
}

class _ErpIntegrationCard extends StatelessWidget {
  final String batchId;

  const _ErpIntegrationCard({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.computer_rounded,
                  color: Color(0xFF5EEAD4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ERP & Muhasebe Entegrasyonu',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '● Canlı Senkronizasyon Başarılı',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✓ Logo &\nParaşüt',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF065F46),
                    fontSize: 9.5,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Muhasebe Fiş No:', value: batchId),
                const SizedBox(height: 6),
                const _DetailRow(
                  label: 'Yevmiye Kaydı:',
                  value: '770.01 - Genel Yönetim Giderleri',
                ),
                const SizedBox(height: 6),
                const _DetailRow(
                  label: 'KDV Mahsubu:',
                  value: '191 İndirilecek KDV',
                ),
                const SizedBox(height: 6),
                const _DetailRow(
                  label: 'GİB E-Arşiv Durumu:',
                  value: 'İletildi & Arşivlendi',
                  valueColor: AppColors.primaryTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ApprovedLineItem extends StatelessWidget {
  final ExpenseEntity expense;

  const _ApprovedLineItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  '${expense.merchantTitle} • ${expense.category} • ${expense.accountingCode}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FinancialAmount.format(expense.amount),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                'KDV: ${FinancialAmount.format(expense.vatAmount)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
