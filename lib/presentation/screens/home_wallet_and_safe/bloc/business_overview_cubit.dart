import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/company_entity.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/pos_transaction_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../../domain/repositories/i_company_repository.dart';
import '../../../../domain/repositories/i_expense_repository.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../../domain/repositories/i_user_repository.dart';
import '../../../../domain/repositories/i_wallet_repository.dart';
import '../../../../domain/use_cases/approve_or_reject_expense_use_case.dart';
import '../../../widgets/four_state_view.dart';
import '../../../widgets/weekly_bar_chart.dart';

/// Kurumsal kasa özeti (BusinessSafeOverviewScreen) değişmez durumu.
class BusinessOverviewState extends Equatable {
  final ViewStatus status;
  final CompanyEntity? company;
  final WalletEntity? companyWallet;
  final List<ExpenseEntity> expenses;
  final List<TransactionEntity> recentTransactions;
  final List<PosTransactionEntity> posTransactions;
  final int periodIndex;
  final int selectedBarIndex;
  final int topUpAmountKurus;
  final String selectedTopUpMethod;
  final bool isSubmitting;
  final String? activeCompanyId;
  final String? errorMessage;
  final String? actionMessage;
  final bool isErrorAction;

  const BusinessOverviewState({
    this.status = ViewStatus.loading,
    this.company,
    this.companyWallet,
    this.expenses = const [],
    this.recentTransactions = const [],
    this.posTransactions = const [],
    this.periodIndex = 0,
    this.selectedBarIndex = 2,
    this.topUpAmountKurus = 5000000,
    this.selectedTopUpMethod = 'Banka Havalesi / FAST',
    this.isSubmitting = false,
    this.activeCompanyId,
    this.errorMessage,
    this.actionMessage,
    this.isErrorAction = false,
  });

  int get balanceKurus => companyWallet?.balanceTl ?? 0;

  int get pendingExpenseCount => expenses.where((e) => e.isPending).length;

  ExpenseEntity? get featuredExpense =>
      expenses.where((e) => e.isPending).firstOrNull ?? expenses.firstOrNull;

  int get posTotalKurus =>
      posTransactions.fold<int>(0, (s, p) => s + (p.grossAmount * 100).round());

  int get totalCommissionKurus {
    final fromPos = posTransactions.fold<int>(
      0,
      (s, p) => s + (p.commissionAmount * 100).round(),
    );
    if (fromPos > 0) return fromPos;
    return (posTotalKurus * AppLimits.posCommissionBps) ~/ 10000;
  }

  int get todayTransactionsKurus {
    final posSum = posTotalKurus;
    final incomeTx = recentTransactions
        .where((t) => !t.isExpense)
        .fold<int>(0, (s, t) => s + t.amount);
    return posSum + incomeTx;
  }

  List<BarChartPoint> get chartPoints {
    if (periodIndex == 0) {
      const items = [
        ('Pzt', 18.0),
        ('Sal', 24.0),
        ('Çar', 38.0),
        ('Per', 26.0),
        ('Cum', 45.0),
      ];
      return [
        for (int i = 0; i < items.length; i++)
          BarChartPoint(
            label: items[i].$1,
            value: items[i].$2,
            isHighlighted: selectedBarIndex == i,
          ),
      ];
    }
    if (periodIndex == 1) {
      const items = [
        ('1. Hf', 260.0),
        ('2. Hf', 288.0),
        ('3. Hf', 340.0),
        ('4. Hf', 300.0),
      ];
      return [
        for (int i = 0; i < items.length; i++)
          BarChartPoint(
            label: items[i].$1,
            value: items[i].$2,
            isHighlighted: selectedBarIndex == i,
          ),
      ];
    }
    const items = [
      ('Eyl', 980.0),
      ('Eki', 1120.0),
      ('Kas', 1240.0),
      ('Ara', 850.0),
    ];
    return [
      for (int i = 0; i < items.length; i++)
        BarChartPoint(
          label: items[i].$1,
          value: items[i].$2,
          isHighlighted: selectedBarIndex == i,
        ),
    ];
  }

  String get chartSummaryText {
    if (periodIndex == 0) {
      const notes = [
        'Pazartesi • ₺18.000 tahsilat',
        'Salı • ₺24.000 tahsilat',
        'Çarşamba • ₺38.000 (Haftanın zirvesi)',
        'Perşembe • ₺26.000 tahsilat',
        'Cuma • ₺45.000 tahsilat trendi',
      ];
      return '↗ ${notes[selectedBarIndex.clamp(0, notes.length - 1)]}';
    }
    if (periodIndex == 1) {
      const notes = [
        '1. Hafta • ₺260.000 E-Ticaret & POS',
        '2. Hafta • ₺288.000 B2B Müşteri Ödemeleri',
        '3. Hafta • ₺340.000 Kurumsal Proje Ödemeleri',
        '4. Hafta • ₺300.000 Rutin B2B Tahsilatları',
      ];
      return '↗ ${notes[selectedBarIndex.clamp(0, notes.length - 1)]}';
    }
    const notes = [
      'Eylül: ₺980.000 Net Hasılat',
      'Ekim: ₺1.120.000 Kurumsal Büyüme',
      'Kasım: ₺1.240.500 (Aktif Dönem)',
      'Aralık Hedef: ₺1.500.000',
    ];
    return '↗ ${notes[selectedBarIndex.clamp(0, notes.length - 1)]}';
  }

  BusinessOverviewState copyWith({
    ViewStatus? status,
    CompanyEntity? company,
    WalletEntity? companyWallet,
    List<ExpenseEntity>? expenses,
    List<TransactionEntity>? recentTransactions,
    List<PosTransactionEntity>? posTransactions,
    int? periodIndex,
    int? selectedBarIndex,
    int? topUpAmountKurus,
    String? selectedTopUpMethod,
    bool? isSubmitting,
    String? activeCompanyId,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isErrorAction,
  }) {
    return BusinessOverviewState(
      status: status ?? this.status,
      company: company ?? this.company,
      companyWallet: companyWallet ?? this.companyWallet,
      expenses: expenses ?? this.expenses,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      posTransactions: posTransactions ?? this.posTransactions,
      periodIndex: periodIndex ?? this.periodIndex,
      selectedBarIndex: selectedBarIndex ?? this.selectedBarIndex,
      topUpAmountKurus: topUpAmountKurus ?? this.topUpAmountKurus,
      selectedTopUpMethod: selectedTopUpMethod ?? this.selectedTopUpMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeCompanyId: activeCompanyId ?? this.activeCompanyId,
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
    company,
    companyWallet,
    expenses,
    recentTransactions,
    posTransactions,
    periodIndex,
    selectedBarIndex,
    topUpAmountKurus,
    selectedTopUpMethod,
    isSubmitting,
    activeCompanyId,
    errorMessage,
    actionMessage,
    isErrorAction,
  ];
}

class BusinessOverviewCubit extends Cubit<BusinessOverviewState> {
  final IWalletRepository _walletRepo;
  final ICompanyRepository _companyRepo;
  final IExpenseRepository _expenseRepo;
  final ITransactionRepository _txRepo;
  final IUserRepository _userRepo;
  final ApproveOrRejectExpenseUseCase _approveOrRejectUseCase;

  final TextEditingController transferAmountController = TextEditingController(
    text: FinancialAmount.input(500000),
  );

  StreamSubscription<WalletEntity?>? _walletSub;
  StreamSubscription<List<ExpenseEntity>>? _expenseSub;
  StreamSubscription<List<TransactionEntity>>? _txSub;

  BusinessOverviewCubit({
    required IWalletRepository walletRepository,
    required ICompanyRepository companyRepository,
    required IExpenseRepository expenseRepository,
    required ITransactionRepository transactionRepository,
    required IUserRepository userRepository,
  }) : _walletRepo = walletRepository,
       _companyRepo = companyRepository,
       _expenseRepo = expenseRepository,
       _txRepo = transactionRepository,
       _userRepo = userRepository,
       _approveOrRejectUseCase = ApproveOrRejectExpenseUseCase(
         expenseRepository,
       ),
       super(const BusinessOverviewState());

  Future<void> loadCompany(String companyId) async {
    if (companyId.isEmpty) return;
    if (companyId == state.activeCompanyId && _walletSub != null) return;

    await _cancelSubscriptions();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        activeCompanyId: companyId,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait([
        _companyRepo.getCompanyById(companyId),
        _walletRepo.getUserWallet(companyId),
        _txRepo.getPosTransactions(companyId),
      ]);
      final company = results[0] as CompanyEntity?;
      final initialWallet = results[1] as WalletEntity?;
      final posTxs = results[2] as List<PosTransactionEntity>;

      emit(
        state.copyWith(
          status: ViewStatus.success,
          company: company,
          companyWallet: initialWallet,
          posTransactions: posTxs,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'Şirket kasa verileri yüklenemedi.',
        ),
      );
    }

    _walletSub = _walletRepo.watchUserWallet(companyId).listen((wallet) {
      if (wallet != null) {
        emit(state.copyWith(status: ViewStatus.success, companyWallet: wallet));
      }
    });

    _expenseSub = _expenseRepo.watchCompanyExpenses(companyId).listen((
      list,
    ) {
      emit(state.copyWith(expenses: list));
    });

    _txSub = _txRepo.watchUserTransactions(companyId).listen((
      list,
    ) {
      emit(state.copyWith(recentTransactions: list));
    });
  }

  void setPeriod(int index) {
    emit(state.copyWith(periodIndex: index, selectedBarIndex: 2));
  }

  void selectBar(int index) {
    emit(state.copyWith(selectedBarIndex: index));
  }

  void setTransferPresetKurus(int kurus) {
    transferAmountController.text = FinancialAmount.input(kurus);
  }

  void setTopUpAmountKurus(int kurus) {
    emit(state.copyWith(topUpAmountKurus: kurus));
  }

  void setTopUpMethod(String method) {
    emit(state.copyWith(selectedTopUpMethod: method));
  }

  Future<bool> transferToBankAccount() async {
    final wallet = state.companyWallet;
    final amountKurus = FinancialAmount.parse(transferAmountController.text);
    if (wallet == null || amountKurus == null || amountKurus <= 0) {
      emit(
        state.copyWith(
          actionMessage: 'Lütfen geçerli bir aktarım tutarı girin.',
          isErrorAction: true,
        ),
      );
      return false;
    }

    if (amountKurus > wallet.balanceTl) {
      emit(
        state.copyWith(
          actionMessage: 'Yetersiz şirket kasası bakiyesi!',
          isErrorAction: true,
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    try {
      final updated = wallet.copyWith(
        balanceTl: wallet.balanceTl - amountKurus,
      );
      await _walletRepo.updateWallet(updated);
      emit(
        state.copyWith(
          isSubmitting: false,
          companyWallet: updated,
          actionMessage:
              '${FinancialAmount.format(amountKurus)} ticari banka hesabına aktarıldı!',
          isErrorAction: false,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: 'Aktarım işlemi başarısız oldu.',
          isErrorAction: true,
        ),
      );
      return false;
    }
  }

  Future<bool> topUpBalance() async {
    final wallet = state.companyWallet;
    final amountKurus = state.topUpAmountKurus;
    if (wallet == null || amountKurus <= 0) {
      emit(
        state.copyWith(
          actionMessage: 'Geçerli bir yükleme tutarı seçin.',
          isErrorAction: true,
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    try {
      final updated = wallet.copyWith(
        balanceTl: wallet.balanceTl + amountKurus,
      );
      await _walletRepo.updateWallet(updated);
      emit(
        state.copyWith(
          isSubmitting: false,
          companyWallet: updated,
          actionMessage:
              '${FinancialAmount.format(amountKurus)} şirket kasasına yüklendi!',
          isErrorAction: false,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: 'Bakiye yükleme işlemi başarısız oldu.',
          isErrorAction: true,
        ),
      );
      return false;
    }
  }

  Future<void> approveExpense({
    required ExpenseEntity expense,
    required String actorRole,
    String? actorId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    try {
      await _approveOrRejectUseCase.approve(
        expense: expense,
        actorRole: actorRole,
        actorId: actorId,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage:
              '${expense.employeeName} masrafı (${FinancialAmount.format(expense.amount)}) onaylandı!',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: e.toString(),
          isErrorAction: true,
        ),
      );
    }
  }

  Future<void> rejectExpense({
    required ExpenseEntity expense,
    required String actorRole,
    String rejectReason = 'Politika dışı harcama',
    String? actorId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    try {
      await _approveOrRejectUseCase.reject(
        expense: expense,
        actorRole: actorRole,
        rejectReason: rejectReason,
        actorId: actorId,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: '${expense.employeeName} masraf fişi reddedildi.',
          isErrorAction: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: e.toString(),
          isErrorAction: true,
        ),
      );
    }
  }

  Future<void> seedDemoData() async {
    emit(state.copyWith(isSubmitting: true, clearActionMessage: true));
    try {
      await _userRepo.seedDemoData();
      final companyId = state.activeCompanyId;
      if (companyId != null) {
        await _cancelSubscriptions();
        await loadCompany(companyId);
      }
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: 'Kasım 2026 Seed verileri başarıyla yenilendi!',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionMessage: 'Seed işlemi başarısız ($e)',
          isErrorAction: true,
        ),
      );
    }
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true, isErrorAction: false));
  }

  Future<void> _cancelSubscriptions() async {
    await _walletSub?.cancel();
    await _expenseSub?.cancel();
    await _txSub?.cancel();
    _walletSub = null;
    _expenseSub = null;
    _txSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    transferAmountController.dispose();
    return super.close();
  }
}
