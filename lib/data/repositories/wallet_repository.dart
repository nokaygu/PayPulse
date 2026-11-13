import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/wallet_model.dart';

/// Clean Architecture Data Katmanı: Cüzdan Veri Deposu ([WalletRepository])
class WalletRepository implements IWalletRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  WalletRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<WalletEntity>> getAllWallets() async {
    final wallets = await _firestoreDatasource.getAllWallets();
    return wallets.map((w) => w.toEntity()).toList();
  }

  @override
  Future<WalletEntity?> getWalletById(String walletId) async {
    final model = await _firestoreDatasource.getWallet(walletId);
    return model?.toEntity();
  }

  @override
  Future<WalletEntity?> getUserWallet(String userId) async {
    final model = await _firestoreDatasource.getUserWallet(userId);
    return model?.toEntity();
  }

  @override
  Stream<WalletEntity?> watchWallet(String walletId) {
    return _firestoreDatasource
        .watchWallet(walletId)
        .map((model) => model?.toEntity());
  }

  @override
  Stream<WalletEntity?> watchUserWallet(String userId) {
    return _firestoreDatasource
        .watchUserWallet(userId)
        .map((model) => model?.toEntity());
  }

  @override
  Future<void> createWallet(WalletEntity wallet) {
    return _firestoreDatasource.createWallet(WalletModel.fromEntity(wallet));
  }

  @override
  Future<void> updateWallet(WalletEntity wallet) {
    return _firestoreDatasource.updateWallet(WalletModel.fromEntity(wallet));
  }
}
