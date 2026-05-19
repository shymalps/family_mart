import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Extras/urls.dart';
import '../Models/login_model.dart';
import 'product_service.dart';

class LoginService {
  final http.Client _client = http.Client();

  Future<ApiResponse<LoginModel>> login(String phone, String password) async {
    final url =
        Uri.parse('${Constants.baseURL}${Constants.login}'); // Update endpoint
    final body = {'username': phone, 'password': password};

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'api-key': Constants.apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded['status'] == 'success' &&
          decoded['data'] != "") {
        print('condition1');
        return ApiResponse.success(
          data: LoginModel.fromJson(decoded['data']),
          rawResponse: decoded,
        );
      } else if (response.statusCode == 200 &&
          decoded['status'] == 'success' &&
          decoded['data'] == "") {
        print('condition2');
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: decoded['msg'] ?? 'Invalid login response',
          statusCode: response.statusCode,
          rawResponse: decoded,
        );
      } else {
        print('condition3');
        return ApiResponse.failure(
          error: ApiError.invalidResponse,
          message: decoded['msg'] ?? 'Invalid login response',
          statusCode: response.statusCode,
          rawResponse: decoded,
        );
      }
    } catch (e) {
      print('condition4');
      return ApiResponse.failure(
        error: ApiError.unexpected,
        message: e.toString(),
      );
    }
  }
}
