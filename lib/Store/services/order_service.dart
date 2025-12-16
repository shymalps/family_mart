import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/order_model.dart';
import 'product_service.dart';

class OrderService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  OrderService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Get new orders for the user
  Future<ApiResponse<OrderListResponse>> getNewOrders({
    int offset = 0,
  }) async {
    try {
      final int userId = _prefsService.userId;
      print('UserId in new orders service: $userId');

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}view_new_order';

      final request = OrderListRequest(
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
        throw TimeoutException(
            'Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleOrderListResponse(response, 'New Orders');
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

  /// Get old orders for the user
  Future<ApiResponse<OrderListResponse>> getOldOrders({
    int offset = 0,
  }) async {
    try {
      final int userId = _prefsService.userId;
      print('UserId in old orders service: $userId');

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}view_old_order';

      final request = OrderListRequest(
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
        throw TimeoutException(
            'Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleOrderListResponse(response, 'Old Orders');
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

  /// Get order details for a specific order
  Future<ApiResponse<OrderDetailsResponse>> getOrderDetails({
    required String orderId,
  }) async {
    try {
      if (orderId.isEmpty) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'Order ID is required',
        );
      }

      const String url = '${Constants.baseURL}product_order_details';

      final request = OrderDetailsRequest(orderId: orderId);

      _logRequest(url, request.toJson());

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${timeout.inSeconds} seconds');
      });

      return _handleOrderDetailsResponse(response);
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

  /// Handle order list response (for both new and old orders)
  ApiResponse<OrderListResponse> _handleOrderListResponse(
      http.Response response,
      String orderType,
      ) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, orderType);

      if (responseBody is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid response format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (response.statusCode != 200) {
        return ApiResponse.failure(
          error: ApiError.server,
          message: responseBody['message']?.toString() ??
              'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (responseBody['status'] != 'success') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: responseBody['msg']?.toString() ?? 'Request failed',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final responseData = responseBody['data'];
      if (responseData is! List) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Order data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final orderListResponse = OrderListResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: orderListResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('$orderType Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse $orderType response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('$orderType Response Handling Error', e.toString(),
          stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle $orderType response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  /// Handle order details response
  ApiResponse<OrderDetailsResponse> _handleOrderDetailsResponse(
      http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Order Details');

      if (responseBody is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Invalid response format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (response.statusCode != 200) {
        return ApiResponse.failure(
          error: ApiError.server,
          message: responseBody['message']?.toString() ??
              'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      if (responseBody['status'] != 'success') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: responseBody['msg']?.toString() ??
              'Failed to get order details',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final responseData = responseBody['data'];
      if (responseData is! Map<String, dynamic>) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Order details data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final orderDetailsResponse =
      OrderDetailsResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: orderDetailsResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Order Details Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse order details response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Order Details Response Handling Error', e.toString(),
          stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle order details response: ${e.toString()}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    }
  }

  // Logging methods
  void _logRequest(String url, Map<String, dynamic> payload) {
    if (kDebugMode) {
      debugPrint(
          '┌───────────────────────────────────────────────────────');
      debugPrint('│ API Request: $url');
      debugPrint('│ Headers: $_headers');
      debugPrint('│ Payload: ${jsonEncode(payload)}');
      debugPrint(
          '└───────────────────────────────────────────────────────');
    }
  }

  void _logResponse(int statusCode, dynamic responseBody, String dataType) {
    if (kDebugMode) {
      debugPrint(
          '┌───────────────────────────────────────────────────────');
      debugPrint('│ API Response: $statusCode');
      debugPrint('│ Type: $dataType');
      debugPrint('│ Body: $dataType retrieved successfully');
      debugPrint(
          '└───────────────────────────────────────────────────────');
    }
  }

  void _logError(String type, String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint(
          '┌───────────────────────────────────────────────────────');
      debugPrint('│ ERROR: $type');
      debugPrint('│ Message: $message');
      if (stackTrace != null) {
        debugPrint('│ StackTrace: $stackTrace');
      }
      debugPrint(
          '└───────────────────────────────────────────────────────');
    }
  }

  @override
  void onClose() {
    httpClient.close();
    super.onClose();
  }
}
