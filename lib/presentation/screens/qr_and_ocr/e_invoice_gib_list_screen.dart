import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/e_invoice_cubit.dart';

/// E-Fatura & E-Arşiv (GİB Canlı Entegrasyonu) Ekranı (Stateless + EInvoiceCubit)
class EInvoiceGibListScreen extends StatelessWidget {
  const EInvoiceGibListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EInvoiceCubit>(
      create: (ctx) {
        final companyId =
            ctx.read<AuthBloc>().state.user?.companyId ??
            AppStrings.defaultCompanyId;
        return EInvoiceCubit(
          invoiceRepository: ctx.read<IInvoiceRepository>(),
          transactionRepository: ctx.read<ITransactionRepository>(),
        )..loadInvoices(companyId: companyId);
      },
      child: const _EInvoiceGibListBody(),
    );
  }
}

class _EInvoiceGibListBody extends StatelessWidget {
  const _EInvoiceGibListBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EInvoiceCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.user?.companyId != curr.user?.companyId,
          listener: (ctx, authState) {
            ctx.read<EInvoiceCubit>().loadInvoices(
              companyId:
                  authState.user?.companyId ?? AppStrings.defaultCompanyId,
            );
          },
        ),
        BlocListener<EInvoiceCubit, EInvoiceState>(
          listenWhen: (prev, curr) =>
              prev.actionMessage != curr.actionMessage &&
              curr.actionMessage != null,
          listener: (ctx, state) {
            final msg = state.actionMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isErrorAction
                    ? AppColors.expenseRed
                    : AppColors.primaryTeal,
              ),
            );
            ctx.read<EInvoiceCubit>().clearActionMessage();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: true),
        body: BlocBuilder<EInvoiceCubit, EInvoiceState>(
          builder: (context, state) {
            final payerUserId = context.select<AuthBloc, String>(
              (b) => b.state.user?.uid ?? '',
            );

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
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'E-Fatura & E-Arşiv',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'GİB Canlı',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: const Color(0xFF065F46),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: cubit.refresh,
                          icon: const Icon(
                            Icons.sync_rounded,
                            size: 20,
                            color: AppColors.primaryTeal,
                          ),
                          tooltip: 'GİB Senkronize Et',
                        ),
                      ],
                    ),
                    Text(
                      'Gelir İdaresi Başkanlığı resmi e-Fatura entegrasyonu',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1. E-Fatura Hacmi Hero Kartı
                    _InvoiceVolumeHeroCard(
                      state: state,
                      onXmlExport: () => cubit.notifyMessage(
                        '${state.activeTabInvoices.length} fatura için Toplu GİB XML paketi oluşturuldu.',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Gelen (Alış) | Giden (Satış) Sekmeleri
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _TabButton(
                            icon: Icons.arrow_downward_rounded,
                            label:
                                'Gelen (Alış)  ${state.incomingInvoices.length}',
                            isSelected: state.isIncomingTab,
                            onTap: () => cubit.setTab(isIncoming: true),
                          ),
                          _TabButton(
                            icon: Icons.arrow_upward_rounded,
                            label:
                                'Giden (Satış)  ${state.outgoingInvoices.length}',
                            isSelected: !state.isIncomingTab,
                            onTap: () => cubit.setTab(isIncoming: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Arama Kutusu + Belge Türü Filtresi
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: cubit.searchController,
                              onChanged: cubit.setSearchQuery,
                              decoration: InputDecoration(
                                hintText:
                                    'Unvan, GİB No veya tutar ara...',
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                suffixIcon: state.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: Color(0xFF64748B),
                                        ),
                                        onPressed: cubit.resetFilters,
                                      )
                                    : null,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showDocTypeFilterSheet(context, state),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: state.selectedDocType != 'Tümü'
                                  ? const Color(0xFFD1FAE5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: state.selectedDocType != 'Tümü'
                                    ? AppColors.primaryTeal
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: state.selectedDocType != 'Tümü'
                                  ? const Color(0xFF0F766E)
                                  : AppColors.darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. Durum Filtre Çipleri
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: InvoiceStatusFilter.values.map((filter) {
                          final selected = state.statusFilter == filter;
                          final isWarning =
                              filter == InvoiceStatusFilter.pending;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => cubit.setStatusFilter(filter),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.darkNavy
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.darkNavy
                                        : isWarning
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  isWarning ? '● ${filter.label}' : filter.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : isWarning
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFF475569),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Fatura Kayıtları Başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.isIncomingTab
                              ? 'Gelen Fatura Kayıtları'
                              : 'Giden Fatura Kayıtları',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        Text(
                          '${state.filteredInvoices.length} Kayıt',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6. 4-State Yönetimli Gerçek Fatura Kartları
                    FourStateView(
                      status: state.listStatus,
                      errorMessage:
                          state.errorMessage ?? 'Fatura kayıtları yüklenemedi.',
                      emptyMessage: state.searchQuery.isNotEmpty ||
                              state.selectedDocType != 'Tümü' ||
                              state.statusFilter != InvoiceStatusFilter.all
                          ? 'Filtre kriterlerine uygun fatura kaydı bulunamadı.'
                          : 'Bu sekmede görüntülenecek e-Fatura bulunmuyor.',
                      onRetry: cubit.refresh,
                      child: Column(
                        children: state.filteredInvoices.map((inv) {
                          final isPayingThis =
                              state.isPaying &&
                              state.payingInvoiceId == inv.invoiceId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _InvoiceCard(
                              invoice: inv,
                              isPaying: isPayingThis,
                              onPdfDownload: () => cubit.notifyMessage(
                                '${inv.gibInvoiceNo} resmi PDF / XML kopyası indirildi.',
                              ),
                              onFastPay: inv.canPayWithFast && !inv.isPaid
                                  ? () => _showFastPaymentDialog(
                                      context: context,
                                      cubit: cubit,
                                      invoice: inv,
                                      payerUserId: payerUserId,
                                      defaultIban: state.defaultFastTargetIban,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 7. GİB Portal Senkronizasyon Butonu
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
                        onPressed: cubit.refresh,
                        icon: const Icon(Icons.sync_rounded, size: 18),
                        label: const Text(
                          'GİB Portal ile Şimdi Senkronize Et',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDocTypeFilterSheet(BuildContext context, EInvoiceState state) {
    final cubit = context.read<EInvoiceCubit>();
    const options = <MapEntry<String, String>>[
      MapEntry('Tümü', 'Tüm Belge Türleri'),
      MapEntry('e_fatura', 'E-Fatura'),
      MapEntry('e_arsiv', 'E-Arşiv'),
      MapEntry('e_smm', 'E-SMM (Serbest Meslek Makbuzu)'),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belge Türüne Göre Filtrele',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final selected = state.selectedDocType == opt.key;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected
                          ? AppColors.primaryTeal
                          : const Color(0xFF94A3B8),
                    ),
                    title: Text(opt.value),
                    onTap: () {
                      cubit.setDocTypeFilter(opt.key);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFastPaymentDialog({
    required BuildContext context,
    required EInvoiceCubit cubit,
    required InvoiceEntity invoice,
    required String payerUserId,
    required String defaultIban,
  }) {
    final ibanController = TextEditingController(text: defaultIban);
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TCMB FAST Fatura Ödemesi',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    invoice.counterpartyName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ÖDENECEK TUTAR (${invoice.gibInvoiceNo})',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FinancialAmount.format(invoice.totalAmount),
                      style: AppTextStyles.numericBalance.copyWith(
                        color: AppColors.darkNavy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ibanController,
                decoration: const InputDecoration(
                  labelText: 'Tedarikçi IBAN Numarası',
                  hintText: 'TR...',
                ),
                validator: FinancialValidators.iban,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final iban = ibanController.text.trim();
              Navigator.pop(ctx);
              cubit.payInvoiceFast(
                invoice: invoice,
                payerUserId: payerUserId,
                targetIban: iban,
              );
            },
            child: const Text('Onayla ve Öde'),
          ),
        ],
      ),
    ).then((_) => ibanController.dispose());
  }
}

class _InvoiceVolumeHeroCard extends StatelessWidget {
  final EInvoiceState state;
  final VoidCallback onXmlExport;

  const _InvoiceVolumeHeroCard({
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
          Row(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
          ),
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

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.primaryTeal
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.darkNavy
                        : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final bool isPaying;
  final VoidCallback onPdfDownload;
  final VoidCallback? onFastPay;

  const _InvoiceCard({
    required this.invoice,
    required this.isPaying,
    required this.onPdfDownload,
    required this.onFastPay,
  });

  @override
  Widget build(BuildContext context) {
    final docLabel = _docTypeLabel(invoice.documentType);
    final issueText =
        '${invoice.issueDate.day.toString().padLeft(2, '0')}.${invoice.issueDate.month.toString().padLeft(2, '0')}.${invoice.issueDate.year}';
    final isActionable = !invoice.isPaid && invoice.canPayWithFast;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActionable
              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: invoice.isIncoming
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    invoice.isIncoming
                        ? Icons.receipt_long_rounded
                        : Icons.outbox_rounded,
                    color: invoice.isIncoming
                        ? const Color(0xFFD97706)
                        : AppColors.primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.counterpartyName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invoice.gibInvoiceNo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          docLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF1D4ED8),
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FinancialAmount.format(invoice.totalAmount),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'KDV: ${FinancialAmount.format(invoice.vatAmount)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: invoice.isPaid
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          invoice.isPaid ? 'Ödendi / Kapandı' : 'Ödeme Bekliyor',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: invoice.isPaid
                                ? const Color(0xFF065F46)
                                : const Color(0xFF92400E),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (invoice.badgeText != null &&
                          invoice.badgeText!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            invoice.badgeText!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF475569),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  issueText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onPdfDownload,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PDF İndir',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onFastPay != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isPaying ? null : onFastPay,
                    icon: isPaying
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.bolt_rounded, size: 15),
                    label: Text(
                      isPaying ? 'Ödeniyor...' : 'Anında Öde (FAST)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Text(
                    invoice.isPaid ? 'ERP Defterine İşlendi' : 'GİB Onaylı',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _docTypeLabel(String type) {
    switch (type) {
      case 'e_smm':
        return 'E-SMM Makbuzu';
      case 'e_arsiv':
        return 'E-Arşiv Fatura';
      case 'e_fatura':
      default:
        return 'E-Fatura';
    }
  }
}

typedef EInvoiceArchiveScreen = EInvoiceGibListScreen;
