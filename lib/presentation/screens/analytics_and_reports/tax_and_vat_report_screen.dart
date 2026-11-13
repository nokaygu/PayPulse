import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/tax_report_cubit.dart';

/// Kurumsal Vergi & KDV Raporu Ekranı (Stateless + TaxReportCubit + CalculateVatSummaryUseCase)
class TaxAndVatReportScreen extends StatelessWidget {
  const TaxAndVatReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaxReportCubit>(
      create: (ctx) {
        final companyId =
            ctx.read<AuthBloc>().state.user?.companyId ??
            AppStrings.defaultCompanyId;
        return TaxReportCubit(
          invoiceRepository: ctx.read<IInvoiceRepository>(),
          expenseRepository: ctx.read<IExpenseRepository>(),
        )..watchCompany(companyId);
      },
      child: const _TaxAndVatReportBody(),
    );
  }
}

class _TaxAndVatReportBody extends StatelessWidget {
  const _TaxAndVatReportBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaxReportCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.companyId != curr.user?.companyId,
      listener: (ctx, authState) {
        ctx.read<TaxReportCubit>().watchCompany(
          authState.user?.companyId ?? AppStrings.defaultCompanyId,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: true),
        body: BlocBuilder<TaxReportCubit, TaxReportState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık Satırı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KURUMSAL FİNANS',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vergi & KDV Raporu',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const StatusBadgeWidget(
                          label: 'GİB Canlı Veri',
                          type: BadgeType.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dönem Seçici (Kasım 2026 | Q3 | 2026 Yıllık)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: TaxPeriodFilter.values.map((period) {
                          final selected = state.selectedPeriod == period;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => cubit.selectPeriod(period),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  period.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: selected
                                        ? AppColors.darkNavy
                                        : const Color(0xFF64748B),
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4-State KDV Özeti ve Analiz İçeriği
                    FourStateView(
                      status: state.status,
                      errorMessage:
                          state.errorMessage ?? 'Vergi verileri yüklenemedi.',
                      emptyMessage:
                          '${state.selectedPeriod.label} dönemi için kayıtlı GİB faturası veya onaylı şirket masrafı bulunamadı.',
                      onRetry: cubit.refresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Ödenecek / Devreden KDV Hero Kartı
                          _NetVatHeroCard(state: state),
                          const SizedBox(height: 16),

                          // 2. Yaklaşan Beyanname: KDV-1 Kartı
                          _DeclarationDraftCard(
                            periodLabel: state.selectedPeriod.label,
                            onSubmitDraft: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${state.selectedPeriod.label} KDV-1 Beyanname Ön Taslağı GİB sistemine iletildi.',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. KDV Mahsup Dağılımı Kartı
                          _VatDistributionCard(state: state),
                          const SizedBox(height: 16),

                          // 4. Onaylı Masraf & Matrah Analizi
                          _ExpenseMatrahCard(state: state),
                          const SizedBox(height: 16),

                          // 5. Mali Müşavir & Muhasebe Entegrasyonu
                          _AccountantExportCard(
                            periodLabel: state.selectedPeriod.label,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NetVatHeroCard extends StatelessWidget {
  final TaxReportState state;

  const _NetVatHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDeferred = state.summary.hasDeferredVat;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDeferred
                    ? 'SONRAKİ DÖNEME DEVREDEN KDV'
                    : 'TAHMİNİ ÖDENECEK NET KDV',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              StatusBadgeWidget(
                label: isDeferred ? 'Devreden KDV' : 'Ödenecek Vergi',
                type: isDeferred ? BadgeType.success : BadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            state.formattedNetVat,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDeferred
                ? 'İndirilecek KDV toplamı hesaplanan satış KDV tutarını aştı.'
                : 'Matrah mahsubu sonrası devlete ödenecek net vergi bakiyesi',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),

          // Hesaplanan KDV vs İndirilecek KDV
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hesaplanan KDV\n(Satış)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.formattedOutputVat,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Matrah: ${FinancialAmount.format(state.summary.salesBaseKurus)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İndirilecek KDV\n(Gider & Fatura)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '-${state.formattedDeductibleVat}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '%${state.offsetRatioPercent} Mahsup Oranı',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: Color(0xFF5EEAD4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${state.formattedDeductibleVat} fatura ve ${state.summary.approvedExpenseCount} onaylı masraf fişinden düşüldü.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclarationDraftCard extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onSubmitDraft;

  const _DeclarationDraftCard({
    required this.periodLabel,
    required this.onSubmitDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yaklaşan Beyanname: KDV-1',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      '$periodLabel Dönemi Yasal Bildirimi',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '15 Gün\nKaldı',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.laptop_chromebook_rounded,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ön Taslak Hazır',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ERP & GİB Fatura Defteri Senkronize',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onSubmitDraft,
                  child: const Text(
                    'GİB Bildir →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VatDistributionCard extends StatelessWidget {
  final TaxReportState state;

  const _VatDistributionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final invShare = state.invoiceDeductibleShareFlex;
    final expShare = state.expenseDeductibleShareFlex;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İndirilecek KDV Kaynak Dağılımı',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    '${state.selectedPeriod.label} gelen fatura & onaylı fiş kırılımı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.donut_large_rounded, color: AppColors.darkNavy),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: invShare,
                    child: Container(color: AppColors.darkNavy),
                  ),
                  Expanded(
                    flex: expShare,
                    child: Container(color: const Color(0xFF0F766E)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _VatColumn(
                dotColor: AppColors.darkNavy,
                label: 'Gelen E-Faturalar',
                amount: FinancialAmount.format(
                  state.summary.deductibleInvoiceVatKurus,
                ),
                share: '%$invShare pay (${state.periodInvoices.length} belge)',
              ),
              _VatColumn(
                dotColor: const Color(0xFF0F766E),
                label: 'Onaylı Personel Masrafı',
                amount: FinancialAmount.format(
                  state.summary.deductibleExpenseVatKurus,
                ),
                share: '%$expShare pay (${state.summary.approvedExpenseCount} fiş)',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VatColumn extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String amount;
  final String share;

  const _VatColumn({
    required this.dotColor,
    required this.label,
    required this.amount,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          Text(
            share,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseMatrahCard extends StatelessWidget {
  final TaxReportState state;

  const _ExpenseMatrahCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final breakdowns = state.categoryBreakdowns;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Onaylı Masraf & Matrah Analizi',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    'Alış Matrahı: ${FinancialAmount.format(state.summary.purchaseBaseKurus)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${breakdowns.length} Kategori',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (breakdowns.isEmpty)
            Text(
              'Bu dönem için onaylanmış personel masraf kalemi bulunmuyor; yalnızca GİB faturaları hesaplamaya dahil edildi.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            )
          else
            ...breakdowns.map((b) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
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
                              b.category,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            Text(
                              '${b.itemCount} onaylı belge • KDV: ${FinancialAmount.format(b.totalVatKurus)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        FinancialAmount.format(b.totalAmountKurus),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AccountantExportCard extends StatelessWidget {
  final String periodLabel;

  const _AccountantExportCard({required this.periodLabel});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open_rounded, color: AppColors.darkNavy),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mali Müşavir ve Muhasebe Entegrasyonu',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      'Resmi defter ve beyan formatlarında anında dışa aktarım',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                      '$periodLabel E-Defter & KDV-1 Ön Beyannamesi (XML / PDF) indirildi.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text(
                'E-Defter & KDV-1 Ön Beyannamesi (XML / PDF)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.balance_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tüm hesaplamalar 213 sayılı VUK ve 3065 sayılı KDV Kanunu mevzuatına uygun olarak onaylı şirket masrafları ve e-Faturalar üzerinden üretilmektedir.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
