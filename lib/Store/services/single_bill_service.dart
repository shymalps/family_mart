// Services/single_bill_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/single_bill_model.dart';
import 'product_service.dart';

class SingleBillService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  SingleBillService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Get single bill details by bill ID
  Future<ApiResponse<SingleBillResponse>> getSingleBill({
    required int billId,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      if (billId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Invalid bill ID provided',
        );
      }

      final String url = '${Constants.baseURL}bill_view/$billId';

      _logRequest(url, {'billId': billId, 'userId': userId});

      final response = await httpClient
          .get(
        Uri.parse(url),
        headers: _headers,
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleSingleBillResponse(response);
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

  /// Handle single bill response
  ApiResponse<SingleBillResponse> _handleSingleBillResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Single Bill');

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
      if (responseBody['status'] != 'success') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: responseBody['message']?.toString() ?? 'Invalid response status',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Data parsing with proper type checking
      final responseData = responseBody['data'];
      if (responseData == null) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Bill data not found',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final singleBillResponse = SingleBillResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: singleBillResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Single Bill Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse single bill response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Single Bill Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle single bill response: ${e.toString()}',
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