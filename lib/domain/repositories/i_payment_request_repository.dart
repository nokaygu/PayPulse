import '../entities/payment_request_entity.dart';
import '../entities/transaction_entity.dart';

/// Clean Architecture Domain Katmanı: Tahsilat Talebi / Deep Link Ödeme Sözleşmesi
abstract class IPaymentRequestRepository {
  Future<List<PaymentRequestEntity>> getAllPaymentRequests();
  Future<PaymentRequestEntity?> getPaymentRequestById(String requestId);
  Future<void> createPaymentRequest(PaymentRequestEntity request);
  Future<TransactionEntity> completePaymentRequestWithWallet({
    required String requestId,
    required String payerUserId,
  });
}
