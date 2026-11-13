import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../../domain/repositories/i_invoice_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/tax_report_cubit.dart';
import 'widgets/accountant_export_card.dart';
import 'widgets/net_vat_hero_card.dart';
import 'widgets/vat_declaration_draft_card.dart';
import 'widgets/vat_distribution_card.dart';
import 'widgets/vat_expense_matrah_card.dart';
import 'widgets/vat_period_header.dart';

/// Kurumsal Vergi & KDV Raporu Ekranı (`StatelessWidget` + `TaxReportCubit`).
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
                    VatPeriodHeader(
                      selectedPeriod: state.selectedPeriod,
                      onSelectPeriod: cubit.selectPeriod,
                    ),
                    const SizedBox(height: 16),
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
                          NetVatHeroCard(state: state),
                          const SizedBox(height: 16),
                          VatDeclarationDraftCard(
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
                          VatDistributionCard(state: state),
                          const SizedBox(height: 16),
                          VatExpenseMatrahCard(state: state),
                          const SizedBox(height: 16),
                          AccountantExportCard(
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
