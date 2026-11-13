import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../../domain/repositories/i_user_repository.dart';
import '../../../../domain/repositories/i_wallet_repository.dart';
import '../../../widgets/four_state_view.dart';

/// Bireysel ana sayfa (HomeScreen) cüzdan ve son hareketler durumu.
class HomeWalletState extends Equatable {
  final ViewStatus status;
  final WalletEntity? wallet;
  final List<TransactionEntity> transactions;
  final String selectedCurrency;
  final bool hideBalance;
  final bool isSeeding;
  final String? activeUserId;
  final String? errorMessage;
  final String? actionMessage;
  final bool isErrorAction;

  const HomeWalletState({
    this.status = ViewStatus.loading,
    this.wallet,
    this.transactions = const [],
    this.selectedCurrency = 'TRY',
    this.hideBalance = false,
    this.isSeeding = false,
    this.activeUserId,
    this.errorMessage,
    this.actionMessage,
    this.isErrorAction = false,
  });

  int get activeCurrencyKurus {
    final w = wallet;
    if (w == null) return 0;
    switch (selectedCurrency) {
      case 'USD':
        return w.balanceUsd;
      case 'EUR':
        return w.balanceEur;
      case 'TRY':
      default:
        return w.balanceTl;
    }
  }

  String get formattedActiveBalance {
    if (hideBalance) {
      switch (selectedCurrency) {
        case 'USD':
          return r'$ ••••••';
        case 'EUR':
          return '€ ••••••';
        case 'TRY':
        default:
          return '₺ ••••••';
      }
    }

    final formattedTl = FinancialAmount.format(activeCurrencyKurus);
    if (selectedCurrency == 'USD') {
      return formattedTl.replaceFirst('₺', r'$');
    }
    if (selectedCurrency == 'EUR') {
      return formattedTl.replaceFirst('₺', '€');
    }
    return formattedTl;
  }

  ViewStatus get transactionsViewStatus {
    if (status == ViewStatus.loading) return ViewStatus.loading;
    if (status == ViewStatus.error) return ViewStatus.error;
    if (transactions.isEmpty) return ViewStatus.empty;
    return ViewStatus.success;
  }

  HomeWalletState copyWith({
    ViewStatus? status,
    WalletEntity? wallet,
    List<TransactionEntity>? transactions,
    String? selectedCurrency,
    bool? hideBalance,
    bool? isSeeding,
    String? activeUserId,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isErrorAction,
  }) {
    return HomeWalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      hideBalance: hideBalance ?? this.hideBalance,
      isSeeding: isSeeding ?? this.isSeeding,
      activeUserId: activeUserId ?? this.activeUserId,
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
    wallet,
    transactions,
    selectedCurrency,
    hideBalance,
    isSeeding,
    activeUserId,
    errorMessage,
    actionMessage,
    isErrorAction,
  ];
}

class HomeWalletCubit extends Cubit<HomeWalletState> {
  final IWalletRepository _walletRepo;
  final ITransactionRepository _txRepo;
  final IUserRepository _userRepo;

  StreamSubscription<WalletEntity?>? _walletSub;
  StreamSubscription<List<TransactionEntity>>? _txSub;

  HomeWalletCubit({
    required IWalletRepository walletRepository,
    required ITransactionRepository transactionRepository,
    required IUserRepository userRepository,
  }) : _walletRepo = walletRepository,
       _txRepo = transactionRepository,
       _userRepo = userRepository,
       super(const HomeWalletState());

  Future<void> watchUser(String userId) async {
    if (userId.isEmpty) return;
    if (userId == state.activeUserId && _walletSub != null) return;

    await _cancelSubscriptions();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        activeUserId: userId,
        clearError: true,
      ),
    );

    _walletSub = _walletRepo
        .watchUserWallet(userId)
        .listen(
          (wallet) {
            emit(
              state.copyWith(
                status: ViewStatus.success,
                wallet: wallet,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                status: ViewStatus.error,
                errorMessage: 'Cüzdan bilgisi alınamadı.',
              ),
            );
          },
        );

    _txSub = _txRepo
        .watchUserTransactions(userId)
        .listen(
          (txs) {
            emit(
              state.copyWith(
                status: ViewStatus.success,
                transactions: txs,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                status: ViewStatus.error,
                errorMessage: 'Cüzdan hareketleri yüklenemedi.',
              ),
            );
          },
        );
  }

  Future<void> refresh() async {
    final userId = state.activeUserId;
    if (userId == null) return;
    await _cancelSubscriptions();
    await watchUser(userId);
  }

  void selectCurrency(String currency) {
    emit(state.copyWith(selectedCurrency: currency));
  }

  void toggleHideBalance() {
    emit(state.copyWith(hideBalance: !state.hideBalance));
  }

  Future<void> seedDemoData() async {
    emit(state.copyWith(isSeeding: true, clearActionMessage: true));
    try {
      await _userRepo.seedDemoData();
      emit(
        state.copyWith(
          isSeeding: false,
          actionMessage:
              'Kasım 2026 Seed verileri Cloud Firestore\'a başarıyla basıldı!',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSeeding: false,
          actionMessage: 'Seed işlemi atlandı ($e)',
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
    await _txSub?.cancel();
    _walletSub = null;
    _txSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
