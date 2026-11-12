sealed class CardsEvent {
  const CardsEvent();
}

/// Kullanıcının kayıtlı ve sanal kartlarını yükler.
final class CardsLoadRequested extends CardsEvent {
  final String userId;

  const CardsLoadRequested(this.userId);
}

/// Yeni sanal veya fiziksel kart oluşturma/ekleme.
final class CardAdded extends CardsEvent {
  final String cardTitle;
  final String cardNumber;
  final String expiryDate;
  final String cardType; // 'virtual', 'physical'
  final int limitInKurus;

  const CardAdded({
    required this.cardTitle,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    required this.limitInKurus,
  });
}

/// Kartı geçici olarak dondurma veya tekrar açma (Freeze/Unfreeze).
final class CardStatusToggled extends CardsEvent {
  final String cardId;

  const CardStatusToggled(this.cardId);
}

/// Kart limitini güncelleme.
final class CardLimitUpdated extends CardsEvent {
  final String cardId;
  final int newLimitInKurus;

  const CardLimitUpdated({
    required this.cardId,
    required this.newLimitInKurus,
  });
}

/// Kartı silme / iptal etme.
final class CardDeleted extends CardsEvent {
  final String cardId;

  const CardDeleted(this.cardId);
}

