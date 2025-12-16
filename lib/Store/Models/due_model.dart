// Models/bill_dues_model.dart

class BillDuesHistoryRequest {
  final int userId;
  final int offset;

  const BillDuesHistoryRequest({
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

class BillDuesHistoryResponse {
  final String status;
  final String message;
  final List<BillDue> data;
  final int total;
  final int limit;

  const BillDuesHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.total,
    required this.limit,
  });

  factory BillDuesHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BillDuesHistoryResponse(
      status: json['status'] as String? ?? '',
      message: json['msg'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => BillDue.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': message,
      'data': data.map((item) => item.toJson()).toList(),
      'total': total,
      'limit': limit,
    };
  }
}

class BillDue {
  final int id;
  final String billNo;
  final String total;
  final String paymentType;
  final String date;
  final bool due;

  const BillDue({
    required this.id,
    required this.billNo,
    required this.total,
    required this.paymentType,
    required this.date,
    required this.due,
  });

  factory BillDue.fromJson(Map<String, dynamic> json) {
    return BillDue(
      id: json['id'] as int? ?? 0,
      billNo: json['bill_no'] as String? ?? '',
      total: json['total'] as String? ?? '0',
      paymentType: json['payment_type'] as String? ?? '',
      date: json['date'] as String? ?? '',
      due: json['due'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_no': billNo,
      'total': total,
      'payment_type': paymentType,
      'date': date,
      'due': due,
    };
  }

  @override
  String toString() {
    return 'BillDue(id: $id, billNo: $billNo, total: $total, paymentType: $paymentType, date: $date, due: $due)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillDue &&
        other.id == id &&
        other.billNo == billNo &&
        other.total == total &&
        other.paymentType == paymentType &&
        other.date == date &&
        other.due == due;
  }

  @override
  int get hashCode {
    return Object.hash(id, billNo, total, paymentType, date, due);
  }
}

// API Response wrapper classes (assuming these exist in your project)
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final ApiError? error;
  final String? message;
  final int? statusCode;
  final dynamic rawResponse;

  const ApiResponse._({
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
    String? message,
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
