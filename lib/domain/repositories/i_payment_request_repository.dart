import '../../data/models/payment_request_model.dart';

abstract class IPaymentRequestRepository {
  Future<List<PaymentRequestModel>> getAllPaymentRequests();
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId);
  Future<void> createPaymentRequest(PaymentRequestModel request);
}
