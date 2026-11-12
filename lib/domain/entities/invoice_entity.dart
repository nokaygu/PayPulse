import '../../core/utils/equatable.dart';

/// E-Fatura, E-Arşiv ve KDV-1 vergi/matrah analizini temsil eden saf Domain Entity sınıfı.
class InvoiceEntity extends Equatable {
  final String invoiceId;
  final String companyId;
  final String gibInvoiceNo; // Örn: GIB2026000004812
  final String counterpartyName; // AWS, Apple, Aydın Hukuk, Google Ireland
  final bool isIncoming; // true: Gelen (Alış), false: Giden (Satış)
  final String documentType; // 'e_fatura', 'e_arsiv', 'e_smm'
  final int totalAmount; // Kuruş bazında (örn: 3482000 = 34.820,00 TL)
  final int vatAmount; // Kuruş bazında
  final double? withholdingRate; // Tevkifat / Stopaj oranı (örn: 0.50 -> Tevkifat 5/10)
  final String? badgeText; // 'Tevkifat 5/10', 'Demirbaş', 'KDV Muaf'
  final bool isPaid;
  final bool canPayWithFast; // Aydın Hukuk gibi faturalarda "Anında Öde (FAST)" aksiyonu
  final DateTime issueDate;
  final DateTime? dueDate;

  InvoiceEntity({
    required this.invoiceId,
    required this.companyId,
    required this.gibInvoiceNo,
    required this.counterpartyName,
    required this.isIncoming,
    required this.documentType,
    required this.totalAmount,
    required this.vatAmount,
    this.withholdingRate,
    this.badgeText,
    this.isPaid = false,
    this.canPayWithFast = false,
    DateTime? issueDate,
    this.dueDate,
  }) : issueDate = issueDate ?? DateTime.now();

  /// KDV hariç net matrah tutarı (Kuruş).
  int get netTaxableBaseInKurus =>
      totalAmount > vatAmount ? totalAmount - vatAmount : 0;

  double get totalAmountInLira => totalAmount / 100.0;
  double get vatAmountInLira => vatAmount / 100.0;
  double get netTaxableBaseInLira => netTaxableBaseInKurus / 100.0;

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
    String? badgeText,
    bool? isPaid,
    bool? canPayWithFast,
    DateTime? issueDate,
    DateTime? dueDate,
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
      badgeText: badgeText ?? this.badgeText,
      isPaid: isPaid ?? this.isPaid,
      canPayWithFast: canPayWithFast ?? this.canPayWithFast,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [
        invoiceId,
        companyId,
        gibInvoiceNo,
        counterpartyName,
        isIncoming,
        documentType,
        totalAmount,
        vatAmount,
        withholdingRate,
        badgeText,
        isPaid,
        canPayWithFast,
        issueDate,
        dueDate,
      ];
}

typedef EInvoiceEntity = InvoiceEntity;
