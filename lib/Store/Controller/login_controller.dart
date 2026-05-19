import 'package:get/get.dart';

import '../Extras/approutes/route_name.dart';
import '../Models/login_model.dart';
import '../services/login_service.dart';
import '../services/shared_pref.dart';

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();
  final SharedPreferencesService _prefs = Get.find<SharedPreferencesService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LoginModel?> user = Rx<LoginModel?>(null);

  Future<void> login(String phone, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _loginService.login(phone, password);

    if (response.success && response.data != null) {
      user.value = response.data;

      // Save to shared preferences
      await _prefs.saveUser(
        id: response.data!.id,
        name: response.data!.name,
        userType: response.data!.userType ?? '',
        email: response.data!.email,
        phone: response.data!.phone,
      );

      Get.toNamed(RouteName.otp);
    } else {
      errorMessage.value = response.message ?? 'Login failed';
    }

    isLoading.value = false;
  }

  void logout() async {
    user.value = null;
    await _prefs.clearUserData();
    // TODO: Navigate to login screen
  }
}
