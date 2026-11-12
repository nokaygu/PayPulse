sealed class WalletEvent {
  const WalletEvent();
}

/// Firebase / Firestore anlık bakiye ve cüzdan dinlemesini başlatır.
final class WalletSubscriptionRequested extends WalletEvent {
  final String ownerId;

  const WalletSubscriptionRequested(this.ownerId);
}

/// Kullanıcının cüzdan verilerini tek seferlik yükler.
final class WalletLoadRequested extends WalletEvent {
  final String ownerId;

  const WalletLoadRequested(this.ownerId);
}

/// Bakiye gizleme / gösterme durumunu değiştirir (Göz ikonu).
final class WalletBalanceVisibilityToggled extends WalletEvent {
  const WalletBalanceVisibilityToggled();
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

/// Cüzdan bakiyesini manuel yenileme.
final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}
