enum CardsStatus { initial, loading, success, failure }

class PaymentCardItem {
  final String cardId;
  final String cardTitle;
  final String cardNumber; // Maskeli örn: **** **** **** 4819
  final String expiryDate;
  final String cardType; // 'virtual', 'physical'
  final int limitInKurus;
  final int spentInKurus;
  final bool isFrozen;

  const PaymentCardItem({
    required this.cardId,
    required this.cardTitle,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    required this.limitInKurus,
    required this.spentInKurus,
    this.isFrozen = false,
  });

  double get limitInLira => limitInKurus / 100.0;
  double get spentInLira => spentInKurus / 100.0;

  PaymentCardItem copyWith({
    String? cardId,
    String? cardTitle,
    String? cardNumber,
    String? expiryDate,
    String? cardType,
    int? limitInKurus,
    int? spentInKurus,
    bool? isFrozen,
  }) {
    return PaymentCardItem(
      cardId: cardId ?? this.cardId,
      cardTitle: cardTitle ?? this.cardTitle,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      limitInKurus: limitInKurus ?? this.limitInKurus,
      spentInKurus: spentInKurus ?? this.spentInKurus,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}

class CardsState {
  final CardsStatus status;
  final List<PaymentCardItem> cards;
  final String? selectedCardId;
  final String? errorMessage;
  final String? successMessage;
  final bool isProcessing;

  const CardsState({
    this.status = CardsStatus.initial,
    this.cards = const [],
    this.selectedCardId,
    this.errorMessage,
    this.successMessage,
    this.isProcessing = false,
  });

  bool get isLoading => status == CardsStatus.loading;
  bool get isSuccess => status == CardsStatus.success;

  PaymentCardItem? get selectedCard {
    if (cards.isEmpty) return null;
    if (selectedCardId == null) return cards.first;
    try {
      return cards.firstWhere((c) => c.cardId == selectedCardId);
    } catch (_) {
      return cards.first;
    }
  }

  CardsState copyWith({
    CardsStatus? status,
    List<PaymentCardItem>? cards,
    String? selectedCardId,
    String? errorMessage,
    String? successMessage,
    bool? isProcessing,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CardsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

