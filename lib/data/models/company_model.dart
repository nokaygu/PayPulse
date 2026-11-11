
//B2B KOBİ panelinin temel modeli.

class CompanyModel {
  final String companyId;
  final String name;
  final String taxNumber;
  final String corporateIban;
  final List<String> adminIds; // Şirketi yönetecek kişilerin UID'leri

  CompanyModel({
    required this.companyId,
    required this.name,
    required this.taxNumber,
    required this.adminIds,
    required this.corporateIban,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      taxNumber: json['taxNumber'] as String,
      adminIds: List<String>.from(json['adminIds'] ?? []),
      corporateIban: json['corporateIban'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'name': name,
      'taxNumber': taxNumber,
      'adminIds': adminIds,
      'corporateIban': corporateIban,
    };
  }
}