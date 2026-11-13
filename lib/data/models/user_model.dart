import '../../core/utils/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Kullanıcıların rolünü ve kurumsal yetkilerini tutan DTO model sınıfı.
class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'b2c', 'employee', 'admin'
  final String? companyId;
  final String customerNo;
  final int verificationLevel;
  final String iban;
  final double monthlyLimit;
  final double spentThisMonth;
  final bool hasB2BAccess;

  const UserModel({
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
    this.hasB2BAccess = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'b2c',
      companyId: json['companyId'] as String?,
      customerNo: json['customerNo'] as String? ?? 'PP-849201',
      verificationLevel: (json['verificationLevel'] as num?)?.toInt() ?? 2,
      iban: json['iban'] as String? ?? 'TR42 0006 2000 8492 0100 0000 01',
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 25000.0,
      spentThisMonth: (json['spentThisMonth'] as num?)?.toDouble() ?? 18420.0,
      hasB2BAccess: json['hasB2BAccess'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (companyId != null) 'companyId': companyId,
      'customerNo': customerNo,
      'verificationLevel': verificationLevel,
      'iban': iban,
      'monthlyLimit': monthlyLimit,
      'spentThisMonth': spentThisMonth,
      'hasB2BAccess': hasB2BAccess,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      role: role,
      companyId: companyId,
      customerNo: customerNo,
      verificationLevel: verificationLevel,
      iban: iban,
      monthlyLimit: monthlyLimit,
      spentThisMonth: spentThisMonth,
      hasB2BAccess: hasB2BAccess,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      companyId: entity.companyId,
      customerNo: entity.customerNo,
      verificationLevel: entity.verificationLevel,
      iban: entity.iban,
      monthlyLimit: entity.monthlyLimit,
      spentThisMonth: entity.spentThisMonth,
      hasB2BAccess: entity.hasB2BAccess,
    );
  }

  UserModel copyWith({
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
    return UserModel(
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
