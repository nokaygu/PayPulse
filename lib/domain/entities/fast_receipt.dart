enum ReceiptShareAction {
  pdf,
  image,
  whatsapp,
  sms,
}

class FastReceipt {
  const FastReceipt({
    required this.transactionId,
    required this.recipientName,
    required this.recipientIban,
    required this.amountKurus,
    required this.remainingBalanceKurus,
    required this.completedAt,
    required this.description,
  });

  final String transactionId;
  final String recipientName;
  final String recipientIban;
  final int amountKurus;
  final int remainingBalanceKurus;
  final DateTime completedAt;
  final String description;
}