// Models/credit_model.dart
class CreditHistoryRequest {
  final int userId;
  final int offset;

  CreditHistoryRequest({
    required this.userId,
    required this.offset,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'offset': offset,
    };
  }
}

class CreditHistoryResponse {
  final String status;
  final String msg;
  final List<Credit> data;
  final int total;
  final int limit;

  CreditHistoryResponse({
    required this.status,
    required this.msg,
    required this.data,
    required this.total,
    required this.limit,
  });

  factory CreditHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CreditHistoryResponse(
      status: json['status']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Credit.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'data': data.map((credit) => credit.toJson()).toList(),
      'total': total,
      'limit': limit,
    };
  }
}

class Credit {
  final int id;
  final double amount;
  final int customerId;
  final String root;
  final int date; // Unix timestamp
  final String createdAt;
  final String updatedAt;

  Credit({
    required this.id,
    required this.amount,
    required this.customerId,
    required this.root,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      customerId: json['customer_id'] as int? ?? 0,
      root: json['root']?.toString() ?? '',
      date: json['date'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'customer_id': customerId,
      'root': root,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert Unix timestamp to DateTime
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date * 1000);

  /// Get formatted date string (dd-MM-yyyy)
  String get formattedDate {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
  }

  /// Get amount as string
  String get amountString => amount.toString();

  @override
  String toString() {
    return 'Credit{id: $id, amount: $amount, customerId: $customerId, root: $root, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Credit &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// API Response wrapper classes (assuming these exist in your project)
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final ApiError? error;
  final int? statusCode;
  final dynamic rawResponse;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
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

enum ApiError {
  network,
  timeout,
  server,
  parsing,
  invalidResponse,
  unexpected,
}