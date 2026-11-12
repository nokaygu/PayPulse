/// KVKK / Veri minimizasyonu prensibi uyarınca, FAST transferi öncesinde
/// karşı tarafın hassas bilgilerini (bakiye, e-posta, telefon vb.) ifşa etmeden
/// yalnızca teyit amaçlı maskelenmiş isim ve IBAN döndüren güvenli alıcı modeli.
class SafeRecipientModel {
  final String userId;
  final String maskedName;
  final String iban;

  const SafeRecipientModel({
    required this.userId,
    required this.maskedName,
    required this.iban,
  });

  factory SafeRecipientModel.fromJson(Map<String, dynamic> json) {
    return SafeRecipientModel(
      userId: json['userId'] as String? ?? '',
      maskedName: json['maskedName'] as String? ?? '',
      iban: json['iban'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'maskedName': maskedName, 'iban': iban};
  }
}
