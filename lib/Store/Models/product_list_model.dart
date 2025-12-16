import '../Extras/urls.dart';

class ProductListResponse {
  final String status;
  final String message;
  final List<Product> data;
  final int total;
  final int limit;

  ProductListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.total,
    required this.limit,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      status: json['status'] ?? '',
      message: json['msg'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Product.fromJson(item))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'msg': message,
    'data': data.map((product) => product.toJson()).toList(),
    'total': total,
    'limit': limit,
  };
}

class Product {
  final int id;
  final String name;
  final String subName;
  final double? amount;
  final double mrp;
  final double saleRate;
  final String fileName;
  final String measurement;
  final String value;
  final int cartCount;

  Product({
    required this.id,
    required this.name,
    required this.subName,
    this.amount,
    required this.mrp,
    required this.saleRate,
    required this.fileName,
    required this.measurement,
    required this.value,
    required this.cartCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subName: json['sub_name'] ?? '',
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0.0,
      saleRate: double.tryParse(json['sale_rate']?.toString() ?? '0') ?? 0.0,
      fileName: json['file_name'] ?? '',
      measurement: json['measurement'] ?? '',
      value: json['value'] ?? '',
      cartCount: int.tryParse(json['cart_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sub_name': subName,
    'amount': amount,
    'mrp': mrp,
    'sale_rate': saleRate,
    'file_name': fileName,
    'measurement': measurement,
    'value': value,
    'cart_count': cartCount,
  };

  // Helper method to get image URL
  String get imageUrl {
    // Replace with your actual image base URL
    return '${Constants.thumbnailBaseUrl}$fileName';
  }

  // Helper method to display price with currency
  String get formattedPrice {
    return '₹$saleRate';
  }

  // Helper method to show original price with strike-through
  String get formattedMrp {
    return saleRate < mrp ? '₹$mrp' : '';
  }

  // Helper method to check if product is on sale
  bool get isOnSale {
    return saleRate < mrp;
  }
}