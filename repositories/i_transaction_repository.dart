import '../models/transaction_model.dart';
abstract class ITransActionRepository {
  Future<List<TransactionModel?>> getAllTransactions();
  Future<TransactionModelModel?> getTransactionById(String txId);
}