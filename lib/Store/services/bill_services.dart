// Services/bill_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/bill_model.dart';
import 'product_service.dart';

class BillService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  BillService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Get customer bill history with optional date range and pagination
  Future<ApiResponse<BillHistoryResponse>> getBillHistory({
    int offset = 0,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final int userId = _prefsService.userId;
      print(userId);
      print('userId in bill history service');

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.customerBillHistory}';

      final request = BillHistoryRequest(
        userId: userId,
        offset: offset,
        fromDate: fromDate,
        toDate: toDate,
      );

      _logRequest(url, request.toJson());

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleBillHistoryResponse(response);
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

  /// Get customer bill dues history with pagination
  Future<ApiResponse<BillDuesResponse>> getBillDues({
    int offset = 0,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL} ${Constants.billDuesHistory}';

      final request = BillDuesRequest(
        userId: userId,
        offset: offset,
      );

      _logRequest(url, request.toJson());

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleBillDuesResponse(response);
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

  /// Handle bill history response
  ApiResponse<BillHistoryResponse> _handleBillHistoryResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Bill History');

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
      if (responseData is! List) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Bill history data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final billHistoryResponse = BillHistoryResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: billHistoryResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Bill History Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse bill history response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Bill History Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle bill history response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  /// Handle bill dues response
  ApiResponse<BillDuesResponse> _handleBillDuesResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Bill Dues');

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
      if (responseData is! List) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Bill dues data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final billDuesResponse = BillDuesResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: billDuesResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Bill Dues Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse bill dues response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Bill Dues Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle bill dues response: ${e.toString()}',
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