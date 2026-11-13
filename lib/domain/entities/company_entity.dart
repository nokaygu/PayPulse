import '../../core/utils/equatable.dart';

/// B2B kurumsal işletme hesabını temsil eden saf Domain Entity sınıfı.
class CompanyEntity extends Equatable {
  final String companyId;
  final String name;
  final String taxNumber;
  final String corporateIban;
  final List<String> adminIds;

  const CompanyEntity({
    required this.companyId,
    required this.name,
    required this.taxNumber,
    required this.corporateIban,
    required this.adminIds,
  });

  bool isAdmin(String uid) => adminIds.contains(uid);

  CompanyEntity copyWith({
    String? companyId,
    String? name,
    String? taxNumber,
    String? corporateIban,
    List<String>? adminIds,
  }) {
    return CompanyEntity(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      corporateIban: corporateIban ?? this.corporateIban,
      adminIds: adminIds ?? this.adminIds,
    );
  }

  @override
  List<Object?> get props => [
    companyId,
    name,
    taxNumber,
    corporateIban,
    adminIds,
  ];
}

