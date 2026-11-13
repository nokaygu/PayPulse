import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/e_invoice_cubit.dart';
import 'widgets/invoice_direction_tab_bar.dart';
import 'widgets/invoice_doc_type_filter_sheet.dart';
import 'widgets/invoice_fast_payment_dialog.dart';
import 'widgets/invoice_filter_header.dart';
import 'widgets/invoice_list_card.dart';
import 'widgets/invoice_volume_hero_card.dart';

/// E-Fatura & E-Arşiv (GİB Canlı Entegrasyonu) Ekranı (Stateless + EInvoiceCubit).
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
                    InvoiceScreenTopBar(onSync: cubit.refresh),
                    const SizedBox(height: 14),
                    InvoiceVolumeHeroCard(
                      state: state,
                      onXmlExport: () => cubit.notifyMessage(
                        '${state.activeTabInvoices.length} fatura için Toplu GİB XML paketi oluşturuldu.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    InvoiceDirectionTabBar(
                      incomingCount: state.incomingInvoices.length,
                      outgoingCount: state.outgoingInvoices.length,
                      isIncomingTab: state.isIncomingTab,
                      onSelectTab: (incoming) =>
                          cubit.setTab(isIncoming: incoming),
                    ),
                    const SizedBox(height: 12),
                    InvoiceFilterHeader(
                      cubit: cubit,
                      state: state,
                      onOpenDocTypeSheet: () => InvoiceDocTypeFilterSheet.show(
                        context,
                        cubit: cubit,
                        selectedDocType: state.selectedDocType,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InvoiceListSection(
                      cubit: cubit,
                      state: state,
                      payerUserId: payerUserId,
                    ),
                    const SizedBox(height: 8),
                    _GibPortalSyncButton(onRefresh: cubit.refresh),
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
}

class _InvoiceListSection extends StatelessWidget {
  final EInvoiceCubit cubit;
  final EInvoiceState state;
  final String payerUserId;

  const _InvoiceListSection({
    required this.cubit,
    required this.state,
    required this.payerUserId,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        state.searchQuery.isNotEmpty ||
        state.selectedDocType != 'Tümü' ||
        state.statusFilter != InvoiceStatusFilter.all;

    return FourStateView(
      status: state.listStatus,
      errorMessage: state.errorMessage ?? 'Fatura kayıtları yüklenemedi.',
      emptyMessage: hasFilters
          ? 'Filtre kriterlerine uygun fatura kaydı bulunamadı.'
          : 'Bu sekmede görüntülenecek e-Fatura bulunmuyor.',
      onRetry: cubit.refresh,
      child: Column(
        children: state.filteredInvoices.map((inv) {
          final isPayingThis =
              state.isPaying && state.payingInvoiceId == inv.invoiceId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InvoiceListCard(
              invoice: inv,
              isPaying: isPayingThis,
              onPdfDownload: () => cubit.notifyMessage(
                '${inv.gibInvoiceNo} resmi PDF / XML kopyası indirildi.',
              ),
              onFastPay: inv.canPayWithFast && !inv.isPaid
                  ? () => InvoiceFastPaymentDialog.show(
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
    );
  }
}

class _GibPortalSyncButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const _GibPortalSyncButton({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkNavy,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onRefresh,
        icon: const Icon(Icons.sync_rounded, size: 18),
        label: const Text(
          'GİB Portal ile Şimdi Senkronize Et',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

typedef EInvoiceArchiveScreen = EInvoiceGibListScreen;
