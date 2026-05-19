import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../Extras/urls.dart';
import 'product_service.dart';



class ProductDescriptionService extends GetxService {
  final String baseURL;
  final http.Client httpClient;
  final Duration timeout;

  ProductDescriptionService({
    required this.baseURL,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  // Common headers
  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // Constants for success messages
  static const String _fetchSuccessMsg = 'get data';

  /// Fetches product description by ID
  Future<ApiResponse<Map<String, dynamic>>> fetchProductDescription({
    required int productId,
  }) async {
    try {
      final String url = '$baseURL${Constants.getTableCondition}';

      final Map<String, dynamic> payload = {
        'name': 'product',
        'where': 'id',
        'value': productId.toString(),
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

      return _handleResponse(
        response: response,
        successMessage: _fetchSuccessMsg,
        checkSuccessMessage: true,
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
      debugPrint('│ Body: ${_formatResponseBody(responseBody)}');
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

  String _formatResponseBody(dynamic body) {
    try {
      if (body is Map || body is List) {
        return const JsonEncoder.withIndent('  ').convert(body);
      }
      return body.toString();
    } catch (e) {
      return body.toString();
    }
  }

  @override
  void onClose() {
    httpClient.close();
    super.onClose();
  }
}