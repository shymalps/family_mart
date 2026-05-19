// Services/bill_dues_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/due_model.dart';

class BillDuesService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  BillDuesService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Get customer bill dues history with pagination
  Future<ApiResponse<BillDuesHistoryResponse>> getBillDuesHistory({
    int offset = 0,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (kDebugMode) {
        print('User ID: $userId');
        print('Getting bill dues history with offset: $offset');
      }

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.billDuesHistory}';

      final request = BillDuesHistoryRequest(
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

      return _handleBillDuesHistoryResponse(response);
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

  /// Handle bill dues history response
  ApiResponse<BillDuesHistoryResponse> _handleBillDuesHistoryResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Bill Dues History');

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
              responseBody['msg']?.toString() ??
              'Request failed with status ${response.statusCode}',
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
          message: 'Bill dues history data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final billDuesHistoryResponse = BillDuesHistoryResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: billDuesHistoryResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Bill Dues History Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse bill dues history response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Bill Dues History Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle bill dues history response: ${e.toString()}',
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
      debugPrint('│ Data Count: ${responseBody['data']?.length ?? 0}');
      debugPrint('│ Total: ${responseBody['total'] ?? 0}');
      debugPrint('│ Limit: ${responseBody['limit'] ?? 0}');
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