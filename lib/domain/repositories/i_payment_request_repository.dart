import '../../data/models/payment_request_model.dart';

abstract class IPaymentRequestRepository {
  Future<List<PaymentRequestModel?>> getAllPaymentRequest();
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId);
}
