import '../../core/utils/equatable.dart';
import '../entities/expense_entity.dart';
import '../entities/invoice_entity.dart';

class VatSummaryEntity extends Equatable {
  final int calculatedOutputVatKurus;
  final int deductibleInvoiceVatKurus;
  final int deductibleExpenseVatKurus;
  final int salesBaseKurus;
  final int purchaseBaseKurus;
  final int approvedExpenseCount;

  const VatSummaryEntity({
    required this.calculatedOutputVatKurus,
    required this.deductibleInvoiceVatKurus,
    required this.deductibleExpenseVatKurus,
    required this.salesBaseKurus,
    required this.purchaseBaseKurus,
    required this.approvedExpenseCount,
  });

  int get totalDeductibleVatKurus =>
      deductibleInvoiceVatKurus + deductibleExpenseVatKurus;

  /// Ödenecek (veya devreden) net KDV (Kuruş)
  int get netVatKurus => calculatedOutputVatKurus - totalDeductibleVatKurus;

  bool get hasDeferredVat => netVatKurus < 0;

  @override
  List<Object?> get props => [
    calculatedOutputVatKurus,
    deductibleInvoiceVatKurus,
    deductibleExpenseVatKurus,
    salesBaseKurus,
    purchaseBaseKurus,
    approvedExpenseCount,
  ];
}

/// E-Fatura ve onaylı şirket masraflarından KDV-1 vergi/matrah analizini hesaplar.
class CalculateVatSummaryUseCase {
  const CalculateVatSummaryUseCase();

  VatSummaryEntity call({
    required List<InvoiceEntity> invoices,
    required List<ExpenseEntity> expenses,
  }) {
    var outputVat = 0;
    var invoiceInputVat = 0;
    var salesBase = 0;
    var purchaseBase = 0;

    for (final inv in invoices) {
      if (inv.isOutgoingSale) {
        outputVat += inv.vatAmount;
        salesBase += inv.netTaxableBaseInKurus;
      } else {
        invoiceInputVat += inv.vatAmount;
        purchaseBase += inv.netTaxableBaseInKurus;
      }
    }

    var expenseInputVat = 0;
    var approvedCount = 0;
    for (final exp in expenses) {
      if (exp.isApproved) {
        expenseInputVat += exp.vatAmount;
        purchaseBase += exp.netAmountInKurus;
        approvedCount++;
      }
    }

    return VatSummaryEntity(
      calculatedOutputVatKurus: outputVat,
      deductibleInvoiceVatKurus: invoiceInputVat,
      deductibleExpenseVatKurus: expenseInputVat,
      salesBaseKurus: salesBase,
      purchaseBaseKurus: purchaseBase,
      approvedExpenseCount: approvedCount,
    );
  }
}

