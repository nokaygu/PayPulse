
//Kullanıcıların rolünü ve varsa bağlı oldukları şirketi tutan model.

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'b2c', 'employee', 'admin'
  final String? companyId; // Sadece employee veya admin ise dolu 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.companyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      companyId: json['companyId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (companyId != null) 'companyId': companyId,
    };
  }
}