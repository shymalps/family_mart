// Models/cart_model.dart
class CartItem {
  final int id;
  final String count;
  final String name;
  final String subName;
  final String? amount;
  final String mrp;
  final String? saleRate;
  final String fileName;

  CartItem({
    required this.id,
    required this.count,
    required this.name,
    required this.subName,
    this.amount,
    required this.mrp,
    this.saleRate,
    required this.fileName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      count: json['count']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      subName: json['sub_name']?.toString() ?? '',
      amount: json['amount']?.toString(),
      mrp: json['mrp']?.toString() ?? '0',
      saleRate: json['sale_rate']?.toString(),
      fileName: json['file_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'name': name,
      'sub_name': subName,
      'amount': amount,
      'mrp': mrp,
      'sale_rate': saleRate,
      'file_name': fileName,
    };
  }

  // Helper methods
  double get mrpDouble => double.tryParse(mrp) ?? 0.0;
  double get amountDouble => double.tryParse(amount ?? '0') ?? 0.0;
  double get saleRateDouble => double.tryParse(saleRate ?? '0') ?? 0.0;
  int get countInt => int.tryParse(count) ?? 0;

  // Get effective price (amount if available, otherwise sale_rate, otherwise mrp)
  double get effectivePrice {
    if (amount != null && amountDouble > 0) return amountDouble;
    if (saleRate != null && saleRateDouble > 0) return saleRateDouble;
    return mrpDouble;
  }

  // Calculate total price for this item
  double get totalPrice => effectivePrice * countInt;
}

class CartResponse {
  final String status;
  final String message;
  final List<CartItem> data;

  CartResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    return CartResponse(
      status: json['status']?.toString() ?? '',
      message: json['msg']?.toString() ?? '',
      data: dataList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  bool get isSuccess => status.toLowerCase() == 'success';
  int get itemCount => data.length;
  int get totalQuantity => data.fold(0, (sum, item) => sum + item.countInt);
  double get totalAmount => data.fold(0.0, (sum, item) => sum + item.totalPrice);
}

// Request model (if needed for API calls)
class CartRequest {
  final int userId;

  CartRequest({
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}

// Generic API Response wrapper (similar to your credit history service)
enum ApiError {
  network,
  timeout,
  server,
  parsing,
  invalidResponse,
  unexpected,
}

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final ApiError? error;
  final String? message;
  final int? statusCode;
  final dynamic rawResponse;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    this.message,
    this.statusCode,
    this.rawResponse,
  });

  factory ApiResponse.success({
    required T data,
    dynamic rawResponse,
  }) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      rawResponse: rawResponse,
    );
  }

  factory ApiResponse.failure({
    required ApiError error,
    required String message,
    int? statusCode,
    dynamic rawResponse,
  }) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      message: message,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }
}