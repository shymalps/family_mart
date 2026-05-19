// Models/profile_model.dart
class ProfileUpdateRequest {
  final int id;
  final String name;
  final String phone;
  final String place;
  final String address;

  ProfileUpdateRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.place,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'place': place,
      'address': address,
    };
  }
}

class ProfileUpdateResponse {
  final String status;
  final String msg;
  final String data;

  ProfileUpdateResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      status: json['status']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'data': data,
    };
  }

  bool get isSuccess => status == 'success';
}

// Generic API Response wrapper (if not already defined)
enum ApiError {
  network,
  timeout,
  server,
  parsing,
  invalidResponse,
  unexpected,
  validation,
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