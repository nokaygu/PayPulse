/// Kullanıcıların rolünü ve kurumsal yetkilerini yöneten saf Domain Entity sınıfı.
class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String role; // 'b2c', 'employee', 'admin'
  final String? companyId;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.companyId,
  });

  bool get isB2C => role == 'b2c';

  bool get isEmployee => role == 'employee';

  bool get isAdmin => role == 'admin';

  /// İşletme paneline sadece 'admin' ve 'employee' rolleri erişebilir.
  bool get canAccessBusinessPanel => isAdmin || isEmployee;

  /// Masraf onaylama ve KDV/matrah raporlarını görüntüleme yetkisi.
  bool get canApproveExpenses => isAdmin;

  /// Kullanıcının bir şirkete bağlı olup olmadığını kontrol eder.
  bool get hasCompany => companyId != null && companyId!.trim().isNotEmpty;

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? companyId,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
    );
  }
}

