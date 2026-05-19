import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/profile_model.dart';
import 'product_service.dart';

class ProfileService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  ProfileService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// reset password
  /// reset password
  Future<ApiResponse<String>> resetPassword(String password) async {
    final url = Uri.parse('${Constants.baseURL}${Constants.passwordReset}');
    final int userId = _prefsService.userId;

    if (userId <= 0) {
      return ApiResponse.failure(
        error: ApiError.invalidResponse,
        message: 'User ID not found in preferences',
      );
    }

    final body = {'id': userId, 'password': password};

    try {
      final response = await httpClient
          .post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      )
          .timeout(timeout);

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded['status'] == 'success' &&
          decoded['data'] != null) {
        return ApiResponse.success(
          data: decoded['data'].toString(),
          rawResponse: decoded,
        );
      } else {
        return ApiResponse.failure(
          error: ApiError.unexpected,
          message: decoded['message'] ?? 'Password reset failed',
        );
      }
    } on TimeoutException catch (e) {
      _logError('Timeout Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.timeout,
        message: 'Request timed out',
      );
    } on http.ClientException catch (e) {
      _logError('Network Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.network,
        message: 'Network error occurred',
      );
    } catch (e, stackTrace) {
      _logError('Unexpected Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get user data from the users table
  Future<ApiResponse<User>> getUserData() async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.getTableCondition}';
      final Map<String, dynamic> payload = {
        'name': 'users',
        'where': 'id',
        'value': userId.toString(),
      };

      _logRequest(url, payload);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(payload),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleUserResponse(response);
    } on TimeoutException catch (e) {
      _logError('Timeout Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.timeout,
        message: 'Request timed out',
      );
    } on http.ClientException catch (e) {
      _logError('Network Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.network,
        message: 'Network error occurred',
      );
    } catch (e, stackTrace) {
      _logError('Unexpected Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get customer data from the customer table
  Future<ApiResponse<Customer>> getCustomerData() async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}get_table_condition';
      final Map<String, dynamic> payload = {
        'name': 'customer',
        'where': 'user_id',
        'value': userId.toString(),
      };

      _logRequest(url, payload);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(payload),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleCustomerResponse(response);
    } on TimeoutException catch (e) {
      _logError('Timeout Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.timeout,
        message: 'Request timed out',
      );
    } on http.ClientException catch (e) {
      _logError('Network Error', e.toString());
      return ApiResponse.failure(
        error: ApiError.network,
        message: 'Network error occurred',
      );
    } catch (e, stackTrace) {
      _logError('Unexpected Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get complete profile data (both user and customer)
  Future<ApiResponse<ProfileData>> getCompleteProfileData() async {
    try {
      // Execute both API calls concurrently
      final results = await Future.wait([
        getUserData(),
        getCustomerData(),
      ]);

      final userResponse = results[0] as ApiResponse<User>;
      final customerResponse = results[1] as ApiResponse<Customer>;

      // Check if both requests were successful
      if (!userResponse.success) {
        return ApiResponse.failure(
          error: userResponse.error!,
          message: 'Failed to get user data: ${userResponse.message}',
        );
      }

      if (!customerResponse.success) {
        return ApiResponse.failure(
          error: customerResponse.error!,
          message: 'Failed to get customer data: ${customerResponse.message}',
        );
      }

      // Create ProfileData object
      final profileData = ProfileData(
        user: userResponse.data!,
        customer: customerResponse.data!,
      );

      return ApiResponse.success(

        data: profileData,
        rawResponse: userResponse.rawResponse,
      );
    } catch (e, stackTrace) {
      _logError('Complete Profile Data Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'Failed to get complete profile data: ${e.toString()}',
      );
    }
  }

  /// Handle user response
  ApiResponse<User> _handleUserResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'User Data');

      // Type checking for the response structure
      if (responseBody is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid response format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Status code check
      if (response.statusCode != 200) {
        return ApiResponse.failure(
          error: ApiError.server,
          message: responseBody['message']?.toString() ?? 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Response validation
      if (responseBody['status'] != 'success' || responseBody['msg'] != 'get data') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Invalid response status or message',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Data parsing with proper type checking
      final responseData = responseBody['data'];
      if (responseData is! List || responseData.isEmpty) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'User data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Get first user from the list
      final userData = responseData.first;
      if (userData is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid user data format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final user = User.fromJson(userData);

      return ApiResponse.success(
        data: user,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('User Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse user response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('User Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle user response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  /// Handle customer response
  ApiResponse<Customer> _handleCustomerResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Customer Data');

      // Type checking for the response structure
      if (responseBody is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid response format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Status code check
      if (response.statusCode != 200) {
        return ApiResponse.failure(
          error: ApiError.server,
          message: responseBody['message']?.toString() ?? 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Response validation
      if (responseBody['status'] != 'success' || responseBody['msg'] != 'get data') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Invalid response status or message',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Data parsing with proper type checking
      final responseData = responseBody['data'];
      if (responseData is! List || responseData.isEmpty) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Customer data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Get first customer from the list
      final customerData = responseData.first;
      if (customerData is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid customer data format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final customer = Customer.fromJson(customerData);

      return ApiResponse.success(
        data: customer,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Customer Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse customer response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Customer Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle customer response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  // Logging methods
  void _logRequest(String url, Map<String, dynamic> payload) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ API Request: $url');
      debugPrint('│ Headers: $_headers');
      debugPrint('│ Payload: ${jsonEncode(payload)}');
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  void _logResponse(int statusCode, dynamic responseBody, String dataType) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ API Response: $statusCode');
      debugPrint('│ Type: $dataType');
      debugPrint('│ Body: $dataType retrieved successfully');
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  void _logError(String type, String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ ERROR: $type');
      debugPrint('│ Message: $message');
      if (stackTrace != null) {
        debugPrint('│ StackTrace: $stackTrace');
      }
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  @override
  void onClose() {
    httpClient.close();
    super.onClose();
  }
}