import '../models/wallet_model.dart';
abstract class IWalletRepository {
  Future<List<WalletModel?>> getAllWallets();
  Future<WalletModel?> getWalletById(String walletId);
}