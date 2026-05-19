class CustomerModel {
  final int id;
  final int userId;
  final String name;
  final String? phone;
  final String? email;
  final String place;
  final String address;
  final String creditValue;
  final String availCredit;
  final double lendAmount;
  final String? fileName;
  final String? map;
  final String? lati;
  final String? longi;
  final String? direction;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    required this.place,
    required this.address,
    required this.creditValue,
    required this.availCredit,
    required this.lendAmount,
    this.fileName,
    this.map,
    this.lati,
    this.longi,
    this.direction,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      place: json['place'] as String,
      address: json['address'] as String,
      creditValue: json['credit_value'] as String,
      availCredit: json['avail_credit'] as String,
      lendAmount: (json['lend_amount'] as num).toDouble(),
      fileName: json['file_name'] as String?,
      map: json['map'] as String?,
      lati: json['lati'] as String?,
      longi: json['longi'] as String?,
      direction: json['direction'] as String?,
      balance: double.parse(json['balance'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}