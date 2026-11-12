/// B2B KOBİ işletme panelinin kurumsal kimlik ve yetki kurallarını tutan Domain Entity sınıfı.
class CompanyEntity {
  final String companyId;
  final String name;
  final String taxNumber; // VKN (10 haneli)
  final String corporateIban;
  final List<String> adminIds;

  const CompanyEntity({
    required this.companyId,
    required this.name,
    required this.taxNumber,
    required this.corporateIban,
    required this.adminIds,
  });

  /// Kullanıcının UID'si şirketin yetkili yöneticileri arasında mı?
  bool isUserAdmin(String uid) => adminIds.contains(uid);

  /// Türkiye Vergi Kimlik Numarası (VKN) 10 haneli rakam kontrolü.
  bool get hasValidTaxNumber => RegExp(r'^\d{10}$').hasMatch(taxNumber.trim());

  /// Görseldeki gibi ticari IBAN özet/maskeli gösterimi (örn: TR89 0006 **** 8901).
  String get maskedCorporateIban {
    final cleaned = corporateIban.replaceAll(' ', '').trim();
    if (cleaned.length <= 12) return corporateIban;
    return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} **** ${cleaned.substring(cleaned.length - 4)}';
  }

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
}
