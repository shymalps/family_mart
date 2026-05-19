import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Extras/urls.dart';
import 'product_service.dart';

class OtpService {
  final http.Client _client = http.Client();
  String? _lastSentOtp;

  /// Generate OTP
  Future<ApiResponse<int>> sendOtp(String phone) async {
    final url = Uri.parse('${Constants.baseURL}${Constants.otp}');
    final body = {'phone': phone};

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'api-key': Constants.apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded['status'] == 'success' &&
          decoded['data'] != null) {
        _lastSentOtp = decoded['data'].toString();
        print('OTP sent: $_lastSentOtp');
        return ApiResponse.success(
          data: decoded['data'], // OTP (int)
          rawResponse: decoded,
        );
      } else {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: decoded['msg'] ?? 'Failed to generate OTP',
          statusCode: response.statusCode,
          rawResponse: decoded,
        );
      }
    } catch (e) {
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: e.toString(),
      );
    }
  }

  /// Verify OTP
  Future<ApiResponse<bool>> verifyOtp(String phone, String otp) async {
    try {
      // Check if we have a stored OTP to compare against
      if (_lastSentOtp == null) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'No OTP was generated for this session',
          statusCode: 400,
        );
      }

      // Compare the entered OTP with the stored OTP
      if (_lastSentOtp == otp) {
        // Clear the stored OTP after successful verification
        _lastSentOtp = null;

        return ApiResponse.success(
          data: true, // Return boolean instead of null
          rawResponse: {'status': 'success', 'message': 'OTP verified'},
        );
      } else {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Invalid OTP',
          statusCode: 401,
        );
      }
    } catch (e) {
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: e.toString(),
      );
    }
  }
}
