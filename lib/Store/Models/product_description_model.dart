class ProductDescriptionModel {
  final int id;
  final int userId;
  final int categoryId;
  final String name;
  final String subName;
  final String? description;
  final String fileName;
  final String? amount;
  final String mrp;
  final String barcode;
  final String company;
  final String? saleRate;
  final String? cgst;
  final String? sgst;
  final String? igst;
  final String? saleMargin;
  final String measurement;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductDescriptionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.subName,
    required this.description,
    required this.fileName,
    this.amount,
    required this.mrp,
    required this.barcode,
    required this.company,
    this.saleRate,
    this.cgst,
    this.sgst,
    this.igst,
    this.saleMargin,
    required this.measurement,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ProductDescriptionModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      name: json['name'],
      subName: json['sub_name'],
      description: json['description'],
      fileName: json['file_name'],
      amount: json['amount'],
      mrp: json['mrp'],
      barcode: json['barcode'],
      company: json['company'],
      saleRate: json['sale_rate'],
      cgst: json['cgst'],
      sgst: json['sgst'],
      igst: json['igst'],
      saleMargin: json['sale_margin'],
      measurement: json['measurement'],
      value: json['value'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
