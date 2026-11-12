import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../../domain/entities/wallet_entity.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  String? _currentOwnerId;
  StreamSubscription? _balanceSubscription;

  WalletBloc({
    FirebaseFirestoreDatasource? firestoreDatasource,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        super(const WalletState()) {
    on<WalletSubscriptionRequested>(_onSubscriptionRequested);
    on<WalletLoadRequested>(_onLoadRequested);
    on<WalletBalanceVisibilityToggled>(_onBalanceVisibilityToggled);
    on<WalletDepositRequested>(_onDepositRequested);
    on<WalletTransferRequested>(_onTransferRequested);
    on<WalletRefreshRequested>(_onRefreshRequested);
  }

  /// logic.md: Reaktif Firestore Stream dinleyicisi
  Future<void> _onSubscriptionRequested(
    WalletSubscriptionRequested event,
    Emitter<WalletState> emit,
  ) async {
    _currentOwnerId = event.ownerId;
    emit(state.copyWith(status: WalletStatus.loading));

    await _balanceSubscription?.cancel();
    _balanceSubscription = _firestoreDatasource
        .userProfileStream(event.ownerId)
        .listen((user) {
      if (user != null && !isClosed) {
        final kurus = ((user.balance) * 100).round();
        final current = state.wallet;
        final updated = (current ??
                WalletEntity(
                  walletId: 'wallet_${event.ownerId}',
                  ownerId: event.ownerId,
                  balanceTl: kurus,
                  balanceUsd: 154000,
                  balanceEur: 82000,
                  iban: 'TR32 0006 1005 1234 5678 9012 34',
                ))
            .copyWith(balanceTl: kurus);

        emit(state.copyWith(
          status: WalletStatus.success,
          wallet: updated,
        ));
      }
    });
  }

  Future<void> _onLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    _currentOwnerId = event.ownerId;
    emit(state.copyWith(status: WalletStatus.loading, clearError: true));

    try {
      final user = await _firestoreDatasource.getUserProfile(event.ownerId);
      final currentBalance = user?.balance ?? 24500.0;
      final balanceInKurus = (currentBalance * 100).round();

      final wallet = WalletEntity(
        walletId: 'wallet_${event.ownerId}',
        ownerId: event.ownerId,
        balanceTl: balanceInKurus,
        balanceUsd: 154000,
        balanceEur: 82000,
        iban: 'TR32 0006 1005 1234 5678 9012 34',
      );

      emit(state.copyWith(
        status: WalletStatus.success,
        wallet: wallet,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.failure,
        errorMessage: 'Cüzdan bilgileri yüklenemedi: $e',
      ));
    }
  }

  /// logic.md: Bakiye gizleme/gösterme (Göz ikonu)
  void _onBalanceVisibilityToggled(
    WalletBalanceVisibilityToggled event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(isBalanceHidden: !state.isBalanceHidden));
  }

  Future<void> _onDepositRequested(
    WalletDepositRequested event,
    Emitter<WalletState> emit,
  ) async {
    final currentWallet = state.wallet;
    if (currentWallet == null) return;

    if (event.amountInKurus <= 0) {
      emit(state.copyWith(
        errorMessage: 'Yüklenecek tutar 0\'dan büyük olmalıdır.',
      ));
      return;
    }

    emit(state.copyWith(isTransferring: true, clearError: true));

    try {
      final updatedWallet = currentWallet.copyWith(
        balanceTl: currentWallet.balanceTl + event.amountInKurus,
      );

      if (_currentOwnerId != null) {
        await _firestoreDatasource.updateBalance(
          _currentOwnerId!,
          updatedWallet.balanceTlInLira,
        );
      }

      emit(state.copyWith(
        status: WalletStatus.success,
        wallet: updatedWallet,
        isTransferring: false,
        successMessage: 'Bakiye başarıyla yüklendi.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isTransferring: false,
        errorMessage: 'Bakiye yüklenirken hata oluştu: $e',
      ));
    }
  }

  Future<void> _onTransferRequested(
    WalletTransferRequested event,
    Emitter<WalletState> emit,
  ) async {
    final currentWallet = state.wallet;
    if (currentWallet == null) return;

    if (!currentWallet.canAffordTl(event.amountInKurus)) {
      emit(state.copyWith(
        errorMessage: 'Yetersiz bakiye! İşlem gerçekleştirilemedi.',
      ));
      return;
    }

    emit(state.copyWith(isTransferring: true, clearError: true));

    try {
      final updatedWallet = currentWallet.deductTl(event.amountInKurus);

      if (_currentOwnerId != null) {
        await _firestoreDatasource.updateBalance(
          _currentOwnerId!,
          updatedWallet.balanceTlInLira,
        );
      }

      emit(state.copyWith(
        status: WalletStatus.success,
        wallet: updatedWallet,
        isTransferring: false,
        successMessage: 'Para transferi başarıyla gerçekleşti.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isTransferring: false,
        errorMessage: 'Transfer başarısız: $e',
      ));
    }
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (_currentOwnerId != null) {
      add(WalletLoadRequested(_currentOwnerId!));
    }
  }

  @override
  Future<void> close() {
    _balanceSubscription?.cancel();
    return super.close();
  }
}
