import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../../domain/repositories/i_expense_repository.dart';
import '../../../../domain/repositories/i_invoice_repository.dart';
import '../../../../domain/use_cases/calculate_vat_summary_use_case.dart';
import '../../../widgets/four_state_view.dart';

enum TaxPeriodFilter { november2026, q3_2026, year2026 }

extension TaxPeriodFilterLabel on TaxPeriodFilter {
  String get label {
    switch (this) {
      case TaxPeriodFilter.november2026:
        return 'Kasım 2026';
      case TaxPeriodFilter.q3_2026:
        return 'Q3 (3. Çeyrek)';
      case TaxPeriodFilter.year2026:
        return '2026 Yıllık';
    }
  }
}

class ExpenseCategoryVatBreakdown {
  final String category;
  final int totalAmountKurus;
  final int totalVatKurus;
  final int itemCount;

  const ExpenseCategoryVatBreakdown({
    required this.category,
    required this.totalAmountKurus,
    required this.totalVatKurus,
    required this.itemCount,
  });
}

class TaxReportState extends Equatable {
  final ViewStatus status;
  final String companyId;
  final TaxPeriodFilter selectedPeriod;
  final List<InvoiceEntity> allInvoices;
  final List<ExpenseEntity> allExpenses;
  final VatSummaryEntity summary;
  final String? errorMessage;

  const TaxReportState({
    this.status = ViewStatus.loading,
    this.companyId = '',
    this.selectedPeriod = TaxPeriodFilter.november2026,
    this.allInvoices = const [],
    this.allExpenses = const [],
    this.summary = const VatSummaryEntity(
      calculatedOutputVatKurus: 0,
      deductibleInvoiceVatKurus: 0,
      deductibleExpenseVatKurus: 0,
      salesBaseKurus: 0,
      purchaseBaseKurus: 0,
      approvedExpenseCount: 0,
    ),
    this.errorMessage,
  });

  List<InvoiceEntity> get periodInvoices {
    return allInvoices.where((inv) {
      return _matchesPeriod(inv.issueDate);
    }).toList();
  }

  List<ExpenseEntity> get periodApprovedExpenses {
    return allExpenses
        .where((exp) => exp.isApproved && _matchesPeriod(exp.date))
        .toList();
  }

  bool _matchesPeriod(DateTime date) {
    switch (selectedPeriod) {
      case TaxPeriodFilter.november2026:
        return date.year == 2026 && date.month == 11;
      case TaxPeriodFilter.q3_2026:
        return date.year == 2026 && date.month >= 7 && date.month <= 9;
      case TaxPeriodFilter.year2026:
        return date.year == 2026;
    }
  }

  int get netPayableOrDeferredKurus => summary.netVatKurus.abs();

  String get formattedNetVat =>
      FinancialAmount.format(netPayableOrDeferredKurus);

  String get formattedOutputVat =>
      FinancialAmount.format(summary.calculatedOutputVatKurus);

  String get formattedDeductibleVat =>
      FinancialAmount.format(summary.totalDeductibleVatKurus);

  int get offsetRatioPercent {
    if (summary.calculatedOutputVatKurus <= 0) {
      return summary.totalDeductibleVatKurus > 0 ? 100 : 0;
    }
    return ((summary.totalDeductibleVatKurus /
                summary.calculatedOutputVatKurus) *
            100)
        .round()
        .clamp(0, 100);
  }

  List<ExpenseCategoryVatBreakdown> get categoryBreakdowns {
    final Map<String, List<ExpenseEntity>> grouped = {};
    for (final exp in periodApprovedExpenses) {
      grouped.putIfAbsent(exp.category, () => []).add(exp);
    }
    return grouped.entries.map((entry) {
      final totalAmount = entry.value.fold<int>(0, (s, e) => s + e.amount);
      final totalVat = entry.value.fold<int>(0, (s, e) => s + e.vatAmount);
      return ExpenseCategoryVatBreakdown(
        category: entry.key,
        totalAmountKurus: totalAmount,
        totalVatKurus: totalVat,
        itemCount: entry.value.length,
      );
    }).toList();
  }

  int get invoiceDeductibleShareFlex {
    final total = summary.totalDeductibleVatKurus;
    if (total <= 0) return 50;
    return ((summary.deductibleInvoiceVatKurus / total) * 100).round().clamp(
      1,
      99,
    );
  }

  int get expenseDeductibleShareFlex {
    final total = summary.totalDeductibleVatKurus;
    if (total <= 0) return 50;
    return (100 - invoiceDeductibleShareFlex).clamp(1, 99);
  }

  TaxReportState copyWith({
    ViewStatus? status,
    String? companyId,
    TaxPeriodFilter? selectedPeriod,
    List<InvoiceEntity>? allInvoices,
    List<ExpenseEntity>? allExpenses,
    VatSummaryEntity? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaxReportState(
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      allInvoices: allInvoices ?? this.allInvoices,
      allExpenses: allExpenses ?? this.allExpenses,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    companyId,
    selectedPeriod,
    allInvoices,
    allExpenses,
    summary,
    errorMessage,
  ];
}

class TaxReportCubit extends Cubit<TaxReportState> {
  final IInvoiceRepository _invoiceRepo;
  final IExpenseRepository _expenseRepo;
  final CalculateVatSummaryUseCase _calculateVatUseCase;
  StreamSubscription<List<ExpenseEntity>>? _expenseSub;

  TaxReportCubit({
    required IInvoiceRepository invoiceRepository,
    required IExpenseRepository expenseRepository,
    CalculateVatSummaryUseCase? calculateVatUseCase,
  }) : _invoiceRepo = invoiceRepository,
       _expenseRepo = expenseRepository,
       _calculateVatUseCase =
           calculateVatUseCase ?? const CalculateVatSummaryUseCase(),
       super(const TaxReportState());

  Future<void> watchCompany(String companyId) async {
    if (companyId.isEmpty) return;

    await _expenseSub?.cancel();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        companyId: companyId,
        clearError: true,
      ),
    );

    try {
      final invoices = await _invoiceRepo.getInvoices(companyId: companyId);
      final updatedBase = state.copyWith(allInvoices: invoices);
      emit(_recalculate(updatedBase, status: ViewStatus.success));

      _expenseSub = _expenseRepo
          .watchCompanyExpenses(companyId)
          .listen(
            (expenses) {
              final next = state.copyWith(
                allInvoices: invoices,
                allExpenses: expenses,
                clearError: true,
              );
              emit(_recalculate(next, status: ViewStatus.success));
            },
            onError: (_) {
              emit(
                state.copyWith(
                  status: ViewStatus.error,
                  errorMessage: 'Kurumsal masraf kayıtları dinlenemedi.',
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'KDV & vergi raporu yüklenemedi.',
        ),
      );
    }
  }

  void selectPeriod(TaxPeriodFilter period) {
    if (period == state.selectedPeriod) return;
    emit(_recalculate(state.copyWith(selectedPeriod: period)));
  }

  TaxReportState _recalculate(TaxReportState base, {ViewStatus? status}) {
    final summary = _calculateVatUseCase.call(
      invoices: base.periodInvoices,
      expenses: base.periodApprovedExpenses,
    );
    final isEmptyData =
        base.periodInvoices.isEmpty && base.periodApprovedExpenses.isEmpty;
    return base.copyWith(
      status: status ?? (isEmptyData ? ViewStatus.empty : ViewStatus.success),
      summary: summary,
    );
  }

  Future<void> refresh() async {
    await watchCompany(state.companyId);
  }

  @override
  Future<void> close() async {
    await _expenseSub?.cancel();
    return super.close();
  }
}
