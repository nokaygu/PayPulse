sealed class WalletEvent {
  const WalletEvent();
}

/// Kullanıcının cüzdan verilerini yükler veya dinler.
final class WalletLoadRequested extends WalletEvent {
  final String ownerId;

  const WalletLoadRequested(this.ownerId);
}

/// Cüzdana bakiye yükleme işlemi (kuruş cinsinden).
final class WalletDepositRequested extends WalletEvent {
  final int amountInKurus;

  const WalletDepositRequested(this.amountInKurus);
}

/// FAST / Havale ile para transferi işlemi.
final class WalletTransferRequested extends WalletEvent {
  final String targetIban;
  final int amountInKurus;
  final String? description;

  const WalletTransferRequested({
    required this.targetIban,
    required this.amountInKurus,
    this.description,
  });
}

/// Cüzdan bakiyesini ve hareketlerini manuel yenileme.
final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}

