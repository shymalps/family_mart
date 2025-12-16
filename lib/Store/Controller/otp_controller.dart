import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Extras/approutes/route_name.dart';
import '../Models/login_model.dart';
import '../Widgets/snack_bar.dart';
import '../services/otp_services.dart';
import '../services/shared_pref.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;
  final otpController = TextEditingController();
  final password = ''.obs;
  final phoneNumber = ''.obs;
  final generatedOtp = ''.obs; // For debugging only, remove in production

  // Store user data temporarily until OTP verification
  LoginModel? _userData;

  final OtpService _otpService = OtpService();
  final SharedPreferencesService _prefs = Get.find<SharedPreferencesService>();

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from login
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      phoneNumber.value = arguments['phone'] ?? '';
      _userData = arguments['userData'] as LoginModel?;
      password.value = arguments['currentPassword'] ?? '';
      Future.delayed(Duration.zero, () {
        sendOtp();
      });
    }
  }

  void setPhoneNumber(String phone) {
    phoneNumber.value = phone;
  }

  /// Send OTP
  Future<void> sendOtp() async {
    print(password);
    print('working start for send otp');
    if (phoneNumber.isEmpty) {
      AppSnackBar.show(title: 'Something Went Wrong', message: 'Please Verify Phone Number');
      return;
    }

    isLoading.value = true;

    // For debugging - skip actual API call and use default OTP
    generatedOtp.value = '1234'; // Default OTP for debugging
    AppSnackBar.show(title: 'Success', message: 'OTP Sent Successfully (Debug mode: 1234)');

    /*
    // Actual OTP service call (commented for debugging)
    final response = await _otpService.sendOtp(phoneNumber.value);

    if (response.success && response.data != null) {
      generatedOtp.value = response.data.toString(); // Debug purpose
     AppSnackBar.show(title: 'Success', message: 'OTP Sent Successfully');
    } else {
      AppSnackBar.show(title: 'Something Went Wrong', message: '${response.message}');
    }
    */

    isLoading.value = false;
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      AppSnackBar.show(title: 'Error', message: 'Please Enter OTP');
      return;
    }

    if (_userData == null) {
      AppSnackBar.show(title: 'Error', message: 'User data not found');
    }

    isLoading.value = true;

    // For debugging - compare with default OTP
    final isVerified = otpController.text.trim() == '1234';

    /*
    // Actual OTP verification (commented for debugging)
    final response = await _otpService.verifyOtp(phoneNumber.value, otpController.text.trim());
    final isVerified = response.success && response.data == true;
    */

    if (isVerified) {
      print('OTP verified successfully');
      print('User ID: ${_userData!.id}');
      print('User Name: ${_userData!.name}');
      print('User Email: ${_userData!.email}');
      print('User Phone: ${_userData!.phone}');
      print('User Type: ${_userData!.userType}');
      // ✅ Save user credentials after successful OTP verification
      await _prefs.saveUser(
        id: _userData!.id,
        name: _userData!.name,
        userType: _userData!.userType ?? '',
        email: _userData!.email,
        phone: _userData!.phone,
        password: password.value,
      );

      print('User ID: ${_userData!.id}');
      print('User Name: ${_userData!.name}');
      print('User Email: ${_userData!.email}');
      print('User Phone: ${_userData!.phone}');
      print('User Type: ${_userData!.userType}');
      print('User data saved successfully');
      AppSnackBar.show(title: 'Success', message: 'OTP Verified Successfully');

      // Navigate to dashboard/home after verification
      Get.offAllNamed(RouteName.navbar);
    } else {
      AppSnackBar.show(title: 'Error ', message: 'Invalid OTP. Debug mode expects: 1234');
      // Original message: '${response.message}'
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}