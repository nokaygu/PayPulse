import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/repositories/i_expense_repository.dart';
import '../../../../domain/use_cases/approve_or_reject_expense_use_case.dart';
import '../../../widgets/four_state_view.dart';

enum ExpenseTabFilter { pending, approved, rejected }

enum ExpenseSortOrder { newest, oldest, highestAmount }

extension ExpenseSortOrderLabel on ExpenseSortOrder {
  String get label {
    switch (this) {
      case ExpenseSortOrder.newest:
        return 'Tarih (En Yeni)';
      case ExpenseSortOrder.oldest:
        return 'Tarih (En Eski)';
      case ExpenseSortOrder.highestAmount:
        return 'Tutar (Yüksekten Düşüğe)';
    }
  }
}

class ExpenseApprovalState extends Equatable {
  static const List<String> availableCategories = [
    'Tümü',
    'Ulaşım',
    'Yemek & Temsil',
    'Donanım & Ofis',
    'Yazılım & SaaS',
  ];

  final ViewStatus status;
  final String companyId;
  final List<ExpenseEntity> allExpenses;
  final ExpenseTabFilter selectedTab;
  final String searchQuery;
  final String selectedCategory;
  final ExpenseSortOrder sortOrder;
  final bool isSubmitting;
  final String? processingExpenseId;
  final String? errorMessage;
  final String? actionMessage;
  final bool isErrorAction;

  const ExpenseApprovalState({
    this.status = ViewStatus.loading,
    this.companyId = '',
    this.allExpenses = const [],
    this.selectedTab = ExpenseTabFilter.pending,
    this.searchQuery = '',
    this.selectedCategory = 'Tümü',
    this.sortOrder = ExpenseSortOrder.newest,
    this.isSubmitting = false,
    this.processingExpenseId,
    this.errorMessage,
    this.actionMessage,
    this.isErrorAction = false,
  });

  List<ExpenseEntity> get pendingExpenses =>
      allExpenses.where((e) => e.isPending).toList();

  List<ExpenseEntity> get approvedExpenses =>
      allExpenses.where((e) => e.isApproved).toList();

  List<ExpenseEntity> get rejectedExpenses =>
      allExpenses.where((e) => e.isRejected).toList();

  int get pendingTotalKurus =>
      pendingExpenses.fold<int>(0, (sum, e) => sum + e.amount);

  int get pendingVatKurus =>
      pendingExpenses.fold<int>(0, (sum, e) => sum + e.vatAmount);

  String get formattedPendingTotal => FinancialAmount.format(pendingTotalKurus);

  String get formattedPendingVat => '+${FinancialAmount.format(pendingVatKurus)}';

  List<ExpenseEntity> get filteredExpenses {
    final Iterable<ExpenseEntity> base;
    switch (selectedTab) {
      case ExpenseTabFilter.pending:
        base = pendingExpenses;
      case ExpenseTabFilter.approved:
        base = approvedExpenses;
      case ExpenseTabFilter.rejected:
        base = rejectedExpenses;
    }

    final q = searchQuery.trim().toLowerCase();
    final filtered = base.where((exp) {
      if (selectedCategory != 'Tümü' &&
          !exp.category.toLowerCase().contains(selectedCategory.toLowerCase())) {
        return false;
      }

      if (q.isEmpty) return true;

      return exp.employeeName.toLowerCase().contains(q) ||
          exp.merchantTitle.toLowerCase().contains(q) ||
          exp.category.toLowerCase().contains(q) ||
          exp.accountingCode.toLowerCase().contains(q) ||
          FinancialAmount.format(exp.amount).toLowerCase().contains(q);
    }).toList();

    switch (sortOrder) {
      case ExpenseSortOrder.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortOrder.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortOrder.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return filtered;
  }

  ViewStatus get listStatus {
    if (status == ViewStatus.loading) return ViewStatus.loading;
    if (status == ViewStatus.error) return ViewStatus.error;
    if (filteredExpenses.isEmpty) return ViewStatus.empty;
    return ViewStatus.success;
  }

  ExpenseApprovalState copyWith({
    ViewStatus? status,
    String? companyId,
    List<ExpenseEntity>? allExpenses,
    ExpenseTabFilter? selectedTab,
    String? searchQuery,
    String? selectedCategory,
    ExpenseSortOrder? sortOrder,
    bool? isSubmitting,
    String? processingExpenseId,
    bool clearProcessingExpense = false,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isErrorAction,
  }) {
    return ExpenseApprovalState(
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      allExpenses: allExpenses ?? this.allExpenses,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      processingExpenseId: clearProcessingExpense
          ? null
          : (processingExpenseId ?? this.processingExpenseId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isErrorAction: isErrorAction ?? this.isErrorAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    companyId,
    allExpenses,
    selectedTab,
    searchQuery,
    selectedCategory,
    sortOrder,
    isSubmitting,
    processingExpenseId,
    errorMessage,
    actionMessage,
    isErrorAction,
  ];
}

class ExpenseApprovalCubit extends Cubit<ExpenseApprovalState> {
  final IExpenseRepository _expenseRepo;
  final ApproveOrRejectExpenseUseCase _approveOrRejectUseCase;
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<ExpenseEntity>>? _sub;

  ExpenseApprovalCubit({
    required IExpenseRepository expenseRepository,
    ApproveOrRejectExpenseUseCase? approveOrRejectUseCase,
  }) : _expenseRepo = expenseRepository,
       _approveOrRejectUseCase =
           approveOrRejectUseCase ??
           ApproveOrRejectExpenseUseCase(expenseRepository),
       super(const ExpenseApprovalState());

  Future<void> watchCompany(String companyId) async {
    if (companyId.isEmpty) return;
    if (companyId == state.companyId && _sub != null) return;

    await _sub?.cancel();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        companyId: companyId,
        clearError: true,
      ),
    );

    _sub = _expenseRepo
        .watchCompanyExpenses(companyId)
        .listen(
          (expenses) {
            emit(
              state.copyWith(
                status: expenses.isEmpty
                    ? ViewStatus.empty
                    : ViewStatus.success,
                allExpenses: expenses,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                status: ViewStatus.error,
                errorMessage: 'Masraf kayıtları Firestore akışından alınamadı.',
              ),
            );
          },
        );
  }

  void setTab(ExpenseTabFilter tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void setSortOrder(ExpenseSortOrder sort) {
    emit(state.copyWith(sortOrder: sort));
  }

  void resetFilters() {
    searchController.clear();
    emit(state.copyWith(searchQuery: '', selectedCategory: 'Tümü'));
  }

  Future<void> approveSingle({
    required ExpenseEntity expense,
    required String actorRole,
    required String actorId,
  }) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        processingExpenseId: expense.expenseId,
        clearActionMessage: true,
      ),
    );
    try {
      await _approveOrRejectUseCase.approve(
        expense: expense,
        actorRole: actorRole,
        actorId: actorId,
        accountingCode: expense.accountingCode,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          clearProcessingExpense: true,
          actionMessage:
              '${expense.employeeName} (${FinancialAmount.format(expense.amount)}) masrafı onaylandı ve muhasebeleştirildi.',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearProcessingExpense: true,
          actionMessage: 'Onay başarısız: ${e.toString()}',
          isErrorAction: true,
        ),
      );
    }
  }

  Future<void> rejectSingle({
    required ExpenseEntity expense,
    required String actorRole,
    required String actorId,
    required String reason,
  }) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        processingExpenseId: expense.expenseId,
        clearActionMessage: true,
      ),
    );
    try {
      await _approveOrRejectUseCase.reject(
        expense: expense,
        actorRole: actorRole,
        actorId: actorId,
        rejectReason: reason,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          clearProcessingExpense: true,
          actionMessage: '${expense.employeeName} masraf talebi reddedildi.',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearProcessingExpense: true,
          actionMessage: 'Reddetme başarısız: ${e.toString()}',
          isErrorAction: true,
        ),
      );
    }
  }

  Future<List<ExpenseEntity>?> approveAllPending({
    required String actorRole,
    required String actorId,
  }) async {
    final pending = state.pendingExpenses;
    if (pending.isEmpty || state.isSubmitting) return null;

    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    final List<ExpenseEntity> approved = [];

    try {
      for (final exp in pending) {
        await _approveOrRejectUseCase.approve(
          expense: exp,
          actorRole: actorRole,
          actorId: actorId,
          accountingCode: exp.accountingCode,
        );
        approved.add(
          exp.copyWith(status: 'approved'),
        );
      }
      emit(state.copyWith(isSubmitting: false));
      return approved;
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: 'Toplu onay tamamlanamadı: ${e.toString()}',
          isErrorAction: true,
        ),
      );
      return null;
    }
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true));
  }

  Future<void> refresh() async {
    final companyId = state.companyId;
    await _sub?.cancel();
    _sub = null;
    await watchCompany(companyId);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    searchController.dispose();
    return super.close();
  }
}

