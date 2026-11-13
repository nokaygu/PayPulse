import '../entities/payment_request_entity.dart';
import '../entities/transaction_entity.dart';
import '../entities/wallet_entity.dart';
import '../repositories/i_payment_request_repository.dart';

/// Ödeme linki veya QR tahsilat talebini tek seferlik ödeme kuralıyla tamamlar.
class PayPaymentRequestUseCase {
  final IPaymentRequestRepository _paymentRequestRepository;

  const PayPaymentRequestUseCase(this._paymentRequestRepository);

  Future<TransactionEntity> call({
    required String requestId,
    required String payerUserId,
    WalletEntity? payerWallet,
  }) async {
    final PaymentRequestEntity? request =
        await _paymentRequestRepository.getPaymentRequestById(requestId);
    if (request == null) {
      throw Exception('Ödeme talebi bulunamadı.');
    }
    if (!request.isPending) {
      throw StateError('Bu ödeme talebi daha önce tamamlanmış veya iptal edilmiş.');
    }
    if (payerWallet != null && !payerWallet.canAffordTl(request.amount)) {
      throw StateError('Yetersiz TL bakiyesi: ödeme talebi karşılanamıyor.');
    }

    return _paymentRequestRepository.completePaymentRequestWithWallet(
      requestId: requestId,
      payerUserId: payerUserId,
    );
  }
}

