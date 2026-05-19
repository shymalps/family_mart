import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../Extras/urls.dart';

enum ApiError {
  timeout,
  network,
  server,
  client,
  parsing,
  unexpected,
  invalidResponse,
  authentication,
  authorization
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String? message;
  final int? statusCode;
  final dynamic rawResponse;

  ApiResponse.success({
    required this.data,
    this.rawResponse,
  })  : success = true,
        error = null,
        message = null,
        statusCode = null;

  ApiResponse.failure({
    required this.error,
    this.message,
    this.statusCode,
    this.rawResponse,
  })  : success = false,
        data = null;
}

class ProductService extends GetxService {
  final String baseURL;
  final http.Client httpClient;
  final Duration timeout;

  ProductService({
    required this.baseURL,
    http.Client? client,
    this.timeout = const Duration(seconds: 30), // Increased timeout
  }) : httpClient = client ?? http.Client();

  // Common headers
  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // Constants for success messages
  static const String _fetchSuccessMsg = 'get data';
  static const String _searchSuccessMsg = 'Product Search Successfully';

  /// Common method to handle POST requests
  Future<ApiResponse<Map<String, dynamic>>> _postRequest({
    required String endpoint,
    required Map<String, dynamic> payload,
    String? successMessage,
    bool checkSuccessMessage = true,
  }) async {
    try {
      final String url = '$baseURL$endpoint';

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

      return _handleResponse(
        response: response,
        successMessage: successMessage,
        checkSuccessMessage: checkSuccessMessage,
      );
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

  /// Handles the API response
  ApiResponse<Map<String, dynamic>> _handleResponse({
    required http.Response response,
    String? successMessage,
    bool checkSuccessMessage = true,
  }) {
    try {
      final dynamic responseBody = jsonDecode(response.body);

      _logResponse(response.statusCode, responseBody);

      // Validate basic response structure
      if (responseBody is! Map<String, dynamic>) {
        throw const FormatException('Invalid response format - expected JSON object');
      }

      // Check status code first
      if (response.statusCode == 401) {
        return ApiResponse.failure(
          error: ApiError.authentication,
          message: 'Authentication required',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (response.statusCode == 403) {
        return ApiResponse.failure(
          error: ApiError.authorization,
          message: 'Unauthorized access',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResponse.failure(
          error: ApiError.server,
          message: responseBody['message'] ?? 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Check success message if required
      if (checkSuccessMessage && successMessage != null) {
        final responseMsg = responseBody['msg']?.toString().toLowerCase().trim();
        final expectedMsg = successMessage.toLowerCase().trim();

        if (responseMsg != expectedMsg) {
          return ApiResponse.failure(
            error: ApiError.invalidResponse,
            message: 'Unexpected response message. Expected: "$expectedMsg", got: "$responseMsg"',
            statusCode: response.statusCode,
            rawResponse: responseBody,
          );
        }
      }

      // Validate data structure
      if (!responseBody.containsKey('data')) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Response missing required "data" field',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Prepare success response
      return ApiResponse.success(
        data: {
          'data': responseBody['data'],
          'total': responseBody['total'] ?? 0,
          'limit': responseBody['limit'] ?? 10,
          'status': responseBody['status'],
          'msg': responseBody['msg'],
        },
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }
///




  /// Fetches products with pagination and optional shop filtering
  Future<ApiResponse<Map<String, dynamic>>> fetchProducts({
    required String userId,
    int offset = 0,
    String? shopId,
    int limit = 10,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (shopId != null && shopId != '0') 'shop_id': shopId,
    };

    return await _postRequest(
      endpoint: Constants.productListLoader,
      payload: body,
      successMessage: _fetchSuccessMsg,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchCategoryProducts({
    required String userId,
    required String categoryId,
    int offset = 0,
    int limit = 10,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'category_id': categoryId,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };

    return await _postRequest(
      endpoint: Constants.productListLoader,
      payload: body,
      successMessage: _fetchSuccessMsg,
    );
  }

  /// Searches products with pagination
  Future<ApiResponse<Map<String, dynamic>>> searchProducts({
    required String query,
    required String userId,
    int offset = 0,
    int limit = 10,
  }) async {
    final body = {
      'name': query,
      'user_id': userId,
    };

    return await _postRequest(
      endpoint: 'product_search_by_name',
      payload: body,
      successMessage: _searchSuccessMsg,
    );
  }

  // Improved logging methods
  void _logRequest(String url, Map<String, dynamic> payload) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ API Request: $url');
      debugPrint('│ Headers: $_headers');
      debugPrint('│ Payload: ${jsonEncode(payload)}');
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  void _logResponse(int statusCode, dynamic responseBody) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ API Response: $statusCode');
      debugPrint('│ Body: Body is printing here');
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