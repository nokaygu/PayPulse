import '../../domain/entities/payment_request_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_payment_request_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/payment_request_model.dart';

class PaymentRequestRepository implements IPaymentRequestRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  PaymentRequestRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<PaymentRequestEntity>> getAllPaymentRequests() async {
    final list = await _firestoreDatasource.getAllPaymentRequests();
    return list.map((r) => r.toEntity()).toList();
  }

  @override
  Future<PaymentRequestEntity?> getPaymentRequestById(String requestId) async {
    final model = await _firestoreDatasource.getPaymentRequest(requestId);
    return model?.toEntity();
  }

  @override
  Future<void> createPaymentRequest(PaymentRequestEntity request) {
    return _firestoreDatasource.createPaymentRequest(
      PaymentRequestModel.fromEntity(request),
    );
  }

  @override
  Future<TransactionEntity> completePaymentRequestWithWallet({
    required String requestId,
    required String payerUserId,
  }) async {
    final tx = await _firestoreDatasource.completePaymentRequestWithWallet(
      requestId: requestId,
      payerUserId: payerUserId,
    );
    return tx.toEntity();
  }
}
