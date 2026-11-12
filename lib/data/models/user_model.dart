
//Kullanıcıların rolünü ve varsa bağlı oldukları şirketi tutan model.

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'b2c', 'employee', 'admin'
  final String? companyId; // Sadece employee veya admin ise dolu 
  final double balance;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.companyId,
    this.balance = 24500.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      companyId: json['companyId'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 24500.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'balance': balance,
      if (companyId != null) 'companyId': companyId,
    };
  }
}