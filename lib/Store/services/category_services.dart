import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/category_model.dart';
import 'product_service.dart';

class CategoryService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;

  CategoryService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
        'api-key': Constants.apiKey,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  Future<ApiResponse<List<CategoryFamily>>> getCategories() async {
    try {
      const String url = '${Constants.baseURL}${Constants.categoryApi}';
      final Map<String, String> params = {'name': 'category'};

      _logRequest(url, params);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(params),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleResponse(response);
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

  ApiResponse<List<CategoryFamily>> _handleResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody);

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
          message: responseBody['message']?.toString() ??
              'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Response validation
      if (responseBody['status'] != 'success' ||
          responseBody['msg'] != 'get data') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Invalid response status or message',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Data parsing with proper type checking
      final responseData = responseBody['data'];
      if (responseData is! List) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Data field is not a list',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Safe mapping with type checking
      final List<CategoryFamily> categories =
          responseData.map<CategoryFamily>((item) {
        if (item is Map<String, dynamic>) {
          return CategoryFamily.fromJson(item);
        } else {
          throw const FormatException('Invalid item format in data list');
        }
      }).toList();

      return ApiResponse.success(
        data: categories,
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
      _logError('Response Handling Error', e.toString(),
          stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  // Reuse your existing logging methods from ProductService
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
      debugPrint('│ Body: category is printing successfully');
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
