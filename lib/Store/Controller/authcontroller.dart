import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Extras/approutes/route_name.dart';
import '../Models/login_model.dart';
import '../Widgets/snack_bar.dart';
import '../services/login_service.dart';
import '../services/shared_pref.dart';

class AuthController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isLogin = true.obs;
  final isLoading = false.obs;
  final isLoading1 = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final LoginService _loginService = LoginService();
  final SharedPreferencesService _prefs = Get.find<SharedPreferencesService>();

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    clearControllers();
  }
 @override
  void onInit() {
    super.onInit();
    
    clearControllers();
  }
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void clearControllers() {
    usernameController.clear();
    passwordController.clear();
    // confirmPasswordController.clear();
    // nameController.clear();
    // phoneController.clear();
  }

  Future<void> authenticate() async {
    isLoading.value = true;

    if (isLogin.value) {
      // Perform login
      final response = await _loginService.login(
          usernameController.text.trim(),
          passwordController.text.trim());

      if (response.success && response.data != null) {
        final LoginModel user = response.data!;
        print("----------------------------------------------");
        print("|");
        print("|");
        print("|");
        print("|");
        print("|");
        print("User ID: ${user.id}");
        print("User Name: ${user.name}");
        print("User Email: ${user.email}");
        print("User Phone: ${user.phone}");
        print("User Type: ${user.userType}");
        print("|");
        print("|");
        print("|");
        print("|");
        print("|");
        print("----------------------------------------------");
        // Navigate to OTP screen and pass user data
        Get.toNamed(RouteName.otp, arguments: {
          'currentPassword': passwordController.text.trim(),
          'usertype': user.userType,
          'phone': user.phone,
          'userData': user, // Pass the complete user data
        });
      } else {
        AppSnackBar.show(
          title: 'Login Failed',
          message: '${response.message}',
        );
      }
    } else {
      // Simulate register (or implement real one)
      Get.snackbar('Register Info', 'Implement registration logic.',
          snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
  }
  Future<void> validationform () async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  isLoading.value = true;

  final response = await _loginService.login(
    usernameController.text.trim(),
    passwordController.text.trim(),
  );

  isLoading.value = false;

  if (response.success && response.data != null) {
    Get.toNamed(RouteName.otp, arguments: {
      'currentPassword': passwordController.text.trim(),
      'usertype': response.data!.userType,
      'phone': response.data!.phone,
      'userData': response.data!,
    });
  } else {
    AppSnackBar.show(
      title: 'Login Failed',
      message: response.message ?? 'Invalid credentials',
    );
  }
}


  @override
  void onClose() {
    clearControllers();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  void logout() {
  clearControllers();
  Get.delete<AuthController>();
  Get.offAllNamed(RouteName.login);
}

}
