/// E-Fatura, E-Arşiv ve KDV-1 vergi/matrah analizini temsil eden saf Domain Entity sınıfı.
class InvoiceEntity {
  final String invoiceId;
  final String companyId;
  final String gibInvoiceNo; // Örn: GIB2026000004812
  final String counterpartyName;
  final bool isIncoming; // true: Gelen (Alış), false: Giden (Satış)
  final String documentType; // 'e_fatura', 'e_arsiv', 'e_smm'
  final int totalAmount; // Kuruş
  final int vatAmount; // Kuruş
  final double? withholdingRate; // Tevkifat / Stopaj oranı (örn: 0.20)
  final bool isPaid;

  const InvoiceEntity({
    required this.invoiceId,
    required this.companyId,
    required this.gibInvoiceNo,
    required this.counterpartyName,
    required this.isIncoming,
    required this.documentType,
    required this.totalAmount,
    required this.vatAmount,
    this.withholdingRate,
    this.isPaid = false,
  });

  /// KDV hariç net matrah tutarı (Kuruş).
  int get netTaxableBaseInKurus =>
      totalAmount > vatAmount ? totalAmount - vatAmount : 0;

  double get totalAmountInLira => totalAmount / 100.0;

  double get vatAmountInLira => vatAmount / 100.0;

  /// Gelen (alış) faturaları İndirilecek KDV olarak mahsup edilebilir;
  /// giden (satış) faturaları Hesaplanan KDV kalemine girer.
  bool get isDeductibleExpense => isIncoming;

  bool get isOutgoingSale => !isIncoming;

  bool get hasWithholding => withholdingRate != null && withholdingRate! > 0;

  InvoiceEntity copyWith({
    String? invoiceId,
    String? companyId,
    String? gibInvoiceNo,
    String? counterpartyName,
    bool? isIncoming,
    String? documentType,
    int? totalAmount,
    int? vatAmount,
    double? withholdingRate,
    bool? isPaid,
  }) {
    return InvoiceEntity(
      invoiceId: invoiceId ?? this.invoiceId,
      companyId: companyId ?? this.companyId,
      gibInvoiceNo: gibInvoiceNo ?? this.gibInvoiceNo,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      isIncoming: isIncoming ?? this.isIncoming,
      documentType: documentType ?? this.documentType,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      withholdingRate: withholdingRate ?? this.withholdingRate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

