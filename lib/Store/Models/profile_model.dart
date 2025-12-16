import '../Extras/urls.dart';

class User {
  final int id;
  final int? shopId;
  final String? roles;
  final String name;
  final String email;
  final String phone;
  final String? emailVerifiedAt;
  final String? password;
  final String? showPassword;
  final String? rememberToken;
  final String userType;
  final String? counter;
  final String? sessionId;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    this.shopId,
    this.roles,
    required this.name,
    required this.email,
    required this.phone,
    this.emailVerifiedAt,
    this.password,
    this.showPassword,
    this.rememberToken,
    required this.userType,
    this.counter,
    this.sessionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      shopId: json['shop_id'],
      roles: json['roles'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      password: json['password'],
      showPassword: json['show_password'],
      rememberToken: json['remember_token'],
      userType: json['user_type'] ?? '',
      counter: json['counter'],
      sessionId: json['session_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'roles': roles,
      'name': name,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'password': password,
      'show_password': showPassword,
      'remember_token': rememberToken,
      'user_type': userType,
      'counter': counter,
      'session_id': sessionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, userType: $userType)';
  }
}

class Customer {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String? email;
  final String place;
  final String address;
  final String creditValue;
  final String availCredit;
  final double lendAmount;
  final String fileName;
  final String map;
  final String lati;
  final String longi;
  final String? direction;
  final String balance;
  final String createdAt;
  final String updatedAt;

  Customer({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    required this.place,
    required this.address,
    required this.creditValue,
    required this.availCredit,
    required this.lendAmount,
    required this.fileName,
    required this.map,
    required this.lati,
    required this.longi,
    this.direction,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      place: json['place'] ?? '',
      address: json['address'] ?? '',
      creditValue: json['credit_value']?.toString() ?? '0',
      availCredit: json['avail_credit']?.toString() ?? '0',
      lendAmount: (json['lend_amount'] ?? 0).toDouble(),
      fileName: json['file_name'] ?? '',
      map: json['map'] ?? '',
      lati: json['lati']?.toString() ?? '',
      longi: json['longi']?.toString() ?? '',
      direction: json['direction'],
      balance: json['balance']?.toString() ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
  String get imageUrl {
    // Replace with your actual image base URL
    return '${Constants.imageBaseURL}$fileName';
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'place': place,
      'address': address,
      'credit_value': creditValue,
      'avail_credit': availCredit,
      'lend_amount': lendAmount,
      'file_name': fileName,
      'map': map,
      'lati': lati,
      'longi': longi,
      'direction': direction,
      'balance': balance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Customer(id: $id, userId: $userId, name: $name, phone: $phone, place: $place)';
  }
}

class ProfileData {
  final User user;
  final Customer customer;

  ProfileData({
    required this.user,
    required this.customer,
  });

  factory ProfileData.fromJson(Map<String, dynamic> userData, Map<String, dynamic> customerData) {
    return ProfileData(
      user: User.fromJson(userData),
      customer: Customer.fromJson(customerData),
    );
  }

  @override
  String toString() {
    return 'ProfileData(user: $user, customer: $customer)';
  }



}