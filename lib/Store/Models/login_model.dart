class LoginModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? userType;
  final String? createdAt;
  final String? updatedAt;

  LoginModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.userType,
    this.createdAt,
    this.updatedAt,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
