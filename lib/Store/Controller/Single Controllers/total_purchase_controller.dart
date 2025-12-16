import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Extras/urls.dart';
import '../../services/shared_pref.dart';

class PurchaseCountController extends GetxController {
  RxInt totalPurchaseCount = 0.obs;
  RxBool isLoading = false.obs;

  final userId = Get.find<SharedPreferencesService>().userId;

  @override
  void onInit() {
    super.onInit();
    print('User ID in purchase count controller: $userId');
    fetchPurchaseCount();
  }

  Future<void> fetchPurchaseCount() async {
    print('User ID in purchase count controller....: $userId');
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${Constants.baseURL}${Constants.totalPurchaseCount}'),
        headers: {
          'Content-Type': 'application/json',
          'api-key': Constants.apiKey,
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        print(userId);
        print('Response from total purchase count: ${response.body}');
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          totalPurchaseCount.value = json['data'] ?? 0;
        } else {
          Get.snackbar('Error', json['msg'] ?? 'Something went wrong');
        }
      } else {
        Get.snackbar('Error', 'Failed to load purchase count');
        print('Failed to load purchase count: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
