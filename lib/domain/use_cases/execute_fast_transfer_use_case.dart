import '../../core/constants/app_limits.dart';
import '../../core/constants/app_strings.dart';
import '../../core/validators/financial_validators.dart';
import '../entities/transaction_entity.dart';
import '../entities/wallet_entity.dart';
import '../repositories/i_transaction_repository.dart';

/// 7/24 FAST para transferini iş kurallarıyla doğrulayarak gerçekleştiren UseCase.
class ExecuteFastTransferUseCase {
  final ITransactionRepository _transactionRepository;

  const ExecuteFastTransferUseCase(this._transactionRepository);

  Future<TransactionEntity> call({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    WalletEntity? senderWallet,
    bool fraudConfirmed = false,
    String currency = 'TRY',
    String? title,
    String? category,
  }) async {
    final ibanError = FinancialValidators.iban(targetIban);
    if (ibanError != null) {
      throw ArgumentError(ibanError);
    }

    if (amountKurus <= 0) {
      throw ArgumentError(AppStrings.invalidAmountError);
    }

    if (senderWallet != null && !senderWallet.canAffordTl(amountKurus)) {
      throw StateError('Yetersiz TL bakiyesi: bakiye negatife düşemez.');
    }

    if (amountKurus >= AppLimits.fraudLimitInKurus && !fraudConfirmed) {
      throw StateError(AppStrings.fraudWarningMessage);
    }

    return _transactionRepository.executeFastTransferByIban(
      senderUserId: senderUserId,
      targetIban: targetIban,
      amountKurus: amountKurus,
      currency: currency,
      title: title,
      category: category,
    );
  }
}

