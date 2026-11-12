import '../../core/utils/equatable.dart';

/// Kullanıcıların rolünü ve kurumsal yetkilerini yöneten saf Domain Entity sınıfı.
class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'b2c', 'employee', 'admin'
  final String? companyId;
  final String customerNo; // örn: 'PP-849201'
  final int verificationLevel; // örn: 2 (Seviye 2)
  final String iban;
  final double monthlyLimit;
  final double spentThisMonth;
  final bool hasB2BAccess;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.companyId,
    this.customerNo = 'PP-849201',
    this.verificationLevel = 2,
    this.iban = 'TR42 0006 2000 8492 0100 0000 01',
    this.monthlyLimit = 25000.0,
    this.spentThisMonth = 18420.0,
    this.hasB2BAccess = true,
  });

  bool get isB2C => role == 'b2c';
  bool get isEmployee => role == 'employee';
  bool get isAdmin => role == 'admin';

  /// İşletme paneline sadece 'admin' ve 'employee' rolleri veya B2B yetkisi olanlar erişebilir.
  bool get canAccessBusinessPanel => isAdmin || isEmployee || hasB2BAccess;

  /// Masraf onaylama ve KDV/matrah raporlarını görüntüleme yetkisi.
  bool get canApproveExpenses => isAdmin;

  /// Kullanıcının bir şirkete bağlı olup olmadığını kontrol eder.
  bool get hasCompany => companyId != null && companyId!.trim().isNotEmpty;

  /// Kalan harcama limiti
  double get remainingLimit => (monthlyLimit - spentThisMonth).clamp(0.0, monthlyLimit);

  /// Limit kullanım yüzdesi (0.0 - 1.0)
  double get limitUsageRatio => monthlyLimit > 0 ? (spentThisMonth / monthlyLimit).clamp(0.0, 1.0) : 0.0;

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? companyId,
    String? customerNo,
    int? verificationLevel,
    String? iban,
    double? monthlyLimit,
    double? spentThisMonth,
    bool? hasB2BAccess,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      customerNo: customerNo ?? this.customerNo,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      iban: iban ?? this.iban,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentThisMonth: spentThisMonth ?? this.spentThisMonth,
      hasB2BAccess: hasB2BAccess ?? this.hasB2BAccess,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        role,
        companyId,
        customerNo,
        verificationLevel,
        iban,
        monthlyLimit,
        spentThisMonth,
        hasB2BAccess,
      ];
}
