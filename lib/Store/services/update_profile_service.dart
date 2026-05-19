// Services/profile_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Extras/urls.dart';
import '../Models/update_profile_model.dart';

class ProfileServiceUpdate extends GetxService {
  final http.Client httpClient;
  final Duration timeout;
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  ProfileServiceUpdate({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : httpClient = client ?? http.Client();

  Map<String, String> get _headers => {
    'api-key': Constants.apiKey,
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Update user profile
  Future<ApiResponse<ProfileUpdateResponse>> updateProfile({
    required String name,
    required String phone,
    required String place,
    required String address,
  }) async {
    try {
      final int userId = _prefsService.userId;

      if (kDebugMode) {
        print('User ID: $userId');
        print('Updating profile for user: $name');
      }

      if (userId <= 0) {
        return ApiResponse.failure(
          error: ApiError.validation,
          message: 'User ID not found in preferences',
        );
      }

      // Validate input fields
      final validationError = _validateProfileData(name, phone, place, address);
      if (validationError != null) {
        return ApiResponse.failure(
          error: ApiError.validation,
          message: validationError,
        );
      }

       String url = '${Constants.baseURL}${Constants.profileUpdate}';

      final request = ProfileUpdateRequest(
        id: userId,
        name: name.trim(),
        phone: phone.trim(),
        place: place.trim(),
        address: address.trim(),
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

      return _handleProfileUpdateResponse(response);
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

  /// Validate profile data
  String? _validateProfileData(String name, String phone, String place, String address) {
    if (name.trim().isEmpty) {
      return 'Name cannot be empty';
    }

    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (phone.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }

    // Basic phone validation (10 digits)
    if (!RegExp(r'^\d{10}$').hasMatch(phone.trim())) {
      return 'Phone number must be 10 digits';
    }

    if (place.trim().isEmpty) {
      return 'Place cannot be empty';
    }

    if (address.trim().isEmpty) {
      return 'Address cannot be empty';
    }

    if (address.trim().length < 5) {
      return 'Address must be at least 5 characters long';
    }

    return null;
  }

  /// Handle profile update response
  ApiResponse<ProfileUpdateResponse> _handleProfileUpdateResponse(http.Response response) {
    try {
      final dynamic responseBody = jsonDecode(response.body);
      _logResponse(response.statusCode, responseBody, 'Profile Update');

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

      // Parse the response
      final profileUpdateResponse = ProfileUpdateResponse.fromJson(responseBody);

      // Check if the update was successful
      if (!profileUpdateResponse.isSuccess) {
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: profileUpdateResponse.msg.isNotEmpty
              ? profileUpdateResponse.msg
              : 'Profile update failed',
          statusCode: response.statusCode,
          rawResponse: responseBody,
        );
      }

      return ApiResponse.success(
        data: profileUpdateResponse,
        rawResponse: responseBody,
      );
    } on FormatException catch (e) {
      _logError('Profile Update Response Parsing Error', e.message);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to parse profile update response: ${e.message}',
        statusCode: response.statusCode,
        rawResponse: response.body,
      );
    } catch (e, stackTrace) {
      _logError('Profile Update Response Handling Error', e.toString(), stackTrace: stackTrace);
      return ApiResponse.failure(
        error: ApiError.parsing,
        message: 'Failed to handle profile update response: ${e.toString()}',
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
      debugPrint('│ Status: ${responseBody['status'] ?? 'Unknown'}');
      debugPrint('│ Message: ${responseBody['msg'] ?? 'No message'}');
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