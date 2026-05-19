// Services/cart_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/cart_model.dart';

class CartService extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  CartService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Get user's cart items
  Future<ApiResponse<CartResponse>> getCart() async {
    try {
      final int userId = _prefsService.userId;
      // final int userId = 148; // Uncomment for testing

      if (kDebugMode) {
        print('User ID: $userId');
        print('Getting cart items');
      }

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.viewCart}'; // Add this to your Constants class

      final request = CartRequest(userId: userId);

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

      return _handleCartResponse(response);
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

  /// Add item to cart
  Future<ApiResponse<CartResponse>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.updateCart}'; // Add this to your Constants class

      final request = {
        'user_id': userId,
        'product_id': productId,
        'count': quantity,
      };

      _logRequest(url, request);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request),
      )
          .timeout(timeout);

      return _handleCartResponse(response);
    } catch (e, stackTrace) {
      _logError('Add to Cart Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'Failed to add item to cart: ${e.toString()}',
      );
    }
  }

  /// Update cart item quantity
  Future<ApiResponse<CartResponse>> updateCartItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.updateCart}'; // Add this to your Constants class

      final request = {
        'user_id': userId,
        'product_id': productId,
        'count': quantity,
      };

      _logRequest(url, request);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request),
      )
          .timeout(timeout);

      return _handleCartResponse(response);
    } catch (e, stackTrace) {
      _logError('Update Cart Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'Failed to update cart item: ${e.toString()}',
      );
    }
  }

  /// Remove item from cart
  Future<ApiResponse<CartResponse>> removeFromCart({
    required int productId,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: 'User ID not found in preferences',
        );
      }

      const String url = '${Constants.baseURL}${Constants.clearCart}'; // Add this to your Constants class

      final request = {
        'user_id': userId,
        'product_id': productId,
      };

      _logRequest(url, request);

      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(request),
      )
          .timeout(timeout);

      return _handleCartResponse(response);
    } catch (e, stackTrace) {
      _logError('Remove from Cart Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: 'Failed to remove item from cart: ${e.toString()}',
      );
    }
  }

  /// Handle cart response
  ApiResponse<CartResponse> _handleCartResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Cart');

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
      if (responseBody['status'] != 'success') {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: responseBody['msg']?.toString() ?? 'Request failed',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      // Data parsing with proper type checking
      final responseData = responseBody['data'];
      if (responseData is! List) {
        return ApiResponse.failure(
          error: ApiError.parsing,
          message: 'Cart data not found or invalid format',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      final cartResponse = CartResponse.fromJson(responseBody);

      return ApiResponse.success(
        data: cartResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Cart Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse cart response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Cart Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle cart response: ${e.toString()}',
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
      debugPrint('│ Message: ${responseBody['msg'] ?? 'N/A'}');
      debugPrint('│ Items Count: ${responseBody['data']?.length ?? 0}');
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