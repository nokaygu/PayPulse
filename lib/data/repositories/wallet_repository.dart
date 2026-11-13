import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/wallet_model.dart';

/// Clean Architecture Data Katmanı: Cüzdan Veri Deposu (WalletRepository)
/// UI ve Domain katmanlarının Firestore detaylarına doğrudan bağımlı olmadan
/// cüzdan bakiyelerini ve durumlarını sorgulamasını sağlar.
class WalletRepository implements IWalletRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  WalletRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Sistemdeki tüm cüzdanları listeler (Admin / Audit amaçlı)
  @override
  Future<List<WalletEntity>> getAllWallets() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance
          .getAllWallets()
          .map((m) => m.toEntity())
          .toList();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.wallets)
        .get();
    return snapshot.docs
        .map((doc) => WalletModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Belirtilen cüzdan ID'sine ait bakiyeleri ve IBAN bilgisini getirir
  @override
  Future<WalletEntity?> getWalletById(String walletId) async {
    try {
      final model = await _firestoreDatasource.getWallet(walletId);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
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
}
