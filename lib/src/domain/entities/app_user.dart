class AppUser {
  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String nationalId;
  final String password;
  final String role;
  final DateTime createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        nationalId: json['nationalId'] as String,
        password: json['password'] as String? ?? '',
        role: json['role'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'nationalId': nationalId,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toStorageJson() => {
        ...toJson(),
        'password': password,
      };
}
