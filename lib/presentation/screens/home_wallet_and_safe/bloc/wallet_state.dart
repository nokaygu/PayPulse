import '../../../../domain/entities/wallet_entity.dart';

enum WalletStatus { initial, loading, success, failure }

class WalletState {
  final WalletStatus status;
  final WalletEntity? wallet;
  final bool isBalanceHidden; // logic.md: Bakiye gizleme/gösterme
  final String? errorMessage;
  final String? successMessage;
  final bool isTransferring;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.isBalanceHidden = false,
    this.errorMessage,
    this.successMessage,
    this.isTransferring = false,
  });

  bool get isLoading => status == WalletStatus.loading;
  bool get isSuccess => status == WalletStatus.success;
  bool get hasWallet => wallet != null;

  /// Görsel bakiye metni (Bakiye gizliyse '•••••• TL' gösterir)
  String get displayBalanceTl {
    if (isBalanceHidden) return '•••••• ₺';
    if (wallet == null) return '₺0,00';
    return '₺${wallet!.balanceTlInLira.toStringAsFixed(2)}';
  }

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    bool? isBalanceHidden,
    String? errorMessage,
    String? successMessage,
    bool? isTransferring,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isTransferring: isTransferring ?? this.isTransferring,
    );
  }
}
