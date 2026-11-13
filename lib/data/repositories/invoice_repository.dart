import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/i_invoice_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';

class InvoiceRepository implements IInvoiceRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  InvoiceRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<InvoiceEntity>> getInvoices({required String companyId}) async {
    final list = await _firestoreDatasource.getInvoices(companyId: companyId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> payInvoiceWithFast({
    required String companyId,
    required String invoiceId,
    required String payerUserId,
    required String targetIban,
  }) async {
    final invoices = await _firestoreDatasource.getInvoices(companyId: companyId);
    final invoice = invoices.firstWhere(
      (i) => i.invoiceId == invoiceId,
      orElse: () => throw Exception('Fatura bulunamadı.'),
    );
    if (invoice.isPaid) {
      throw StateError('Bu fatura daha önce ödenmiş.');
    }

    await _firestoreDatasource.executeFastTransferByIban(
      senderUserId: payerUserId,
      targetIban: targetIban,
      amountKurus: invoice.totalAmount,
    );
    await _firestoreDatasource.markInvoicePaid(invoiceId);
  }
}

