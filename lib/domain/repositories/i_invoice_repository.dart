import '../entities/invoice_entity.dart';

/// Clean Architecture Domain Katmanı: E-Fatura, E-Arşiv ve E-SMM Sözleşmesi
abstract class IInvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({required String companyId});
  Future<void> payInvoiceWithFast({
    required String companyId,
    required String invoiceId,
    required String payerUserId,
    required String targetIban,
  });
}

