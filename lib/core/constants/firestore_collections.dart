/// Firestore veritabanı koleksiyon ve alt koleksiyon adlarının merkezi sabitleri.
class FirestoreCollections {
  FirestoreCollections._();

  /// Kullanıcı profilleri
  static const String users = 'users';

  /// Cüzdanlar
  static const String wallets = 'wallets';

  /// Finansal işlemler (FAST, Transfer, Cüzdan yükleme)
  static const String transactions = 'transactions';

  /// Bütçe harcama kategorileri
  static const String budgetCategories = 'budget_categories';

  /// Birikim hedefleri
  static const String savingsGoals = 'savings_goals';

  /// Personel masraf fişleri ve onay masası
  static const String expenses = 'expenses';

  /// E-Fatura & E-Arşiv kayıtları
  static const String invoices = 'invoices';

  /// Sanal POS işlem kayıtları ve Z-Raporu verileri
  static const String posTransactions = 'pos_transactions';

  /// Şirket ve üye işyeri tanımları
  static const String companies = 'companies';

  /// Bildirimler
  static const String notifications = 'notifications';
}

