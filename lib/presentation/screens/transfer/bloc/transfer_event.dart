sealed class TransferEvent {
  const TransferEvent();
}

/// Alıcı adı / unvanı değiştiğinde tetiklenir.
final class TransferRecipientChanged extends TransferEvent {
  final String recipientName;

  const TransferRecipientChanged(this.recipientName);
}

/// Alıcı IBAN numarası değiştiğinde tetiklenir.
final class TransferIbanChanged extends TransferEvent {
  final String iban;

  const TransferIbanChanged(this.iban);
}

/// Transfer tutarı metin olarak değiştiğinde tetiklenir.
final class TransferAmountChanged extends TransferEvent {
  final String amount;

  const TransferAmountChanged(this.amount);
}

/// Hızlı tutar çiplerinden biri seçildiğinde tetiklenir (Kuruş cinsinden).
final class TransferQuickAmountSelected extends TransferEvent {
  final int amountKurus;

  const TransferQuickAmountSelected(this.amountKurus);
}

/// İşlem açıklaması değiştiğinde tetiklenir.
final class TransferDescriptionChanged extends TransferEvent {
  final String description;

  const TransferDescriptionChanged(this.description);
}

/// FAST Para Transferi formunu onaylayıp gönderir.
final class TransferSubmitted extends TransferEvent {
  final int currentBalanceKurus;

  const TransferSubmitted({required this.currentBalanceKurus});
}

/// Formu sıfırlar.
final class TransferReset extends TransferEvent {
  const TransferReset();
}

