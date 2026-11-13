import '../../core/constants/app_strings.dart';
import '../../core/utils/financial_amount.dart';
import '../entities/transaction_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/i_transaction_repository.dart';

/// Sanal POS (Kart / QR) tahsilat işlemlerini yetki ve komisyon kurallarıyla yürütür.
class ExecutePosPaymentUseCase {
  final ITransactionRepository _transactionRepository;

  const ExecutePosPaymentUseCase(this._transactionRepository);

  Future<TransactionEntity> executeCard({
    required UserEntity actor,
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (!actor.canAccessBusinessPanel) {
      throw StateError(AppStrings.unauthorizedOperationError);
    }
    if (amountKurus <= 0) {
      throw ArgumentError(AppStrings.invalidAmountError);
    }
    // Komisyon hesabının geçerli sınırlarda olduğunu doğrula
    FinancialAmount.posCommission(amountKurus);

    return _transactionRepository.executeCardPosPayment(
      companyId: companyId,
      maskedCardNumber: maskedCardNumber,
      amountKurus: amountKurus,
      currency: currency,
    );
  }

  Future<TransactionEntity> executeQrWallet({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (amountKurus <= 0) {
      throw ArgumentError(AppStrings.invalidAmountError);
    }

    return _transactionRepository.executeQrWalletPayment(
      companyId: companyId,
      payerUserId: payerUserId,
      amountKurus: amountKurus,
      currency: currency,
    );
  }
}

