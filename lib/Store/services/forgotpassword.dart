// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// class Forgotpassword extends GetxController {
//   final TextEditingController emailController = TextEditingController();
//   final RxBool isLoading = false.obs;

//   // In your AuthController class
//   Future<void> forgotPassword(String email) async {
//     try {
//       final response = await .post(
//         Uri.parse('YOUR_API_URL/forgot-password'),
//         body: {'email': email},
//       );

//       if (response.statusCode == 200) {
//         // Success - the dialog will show success message
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to send reset link. Please try again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Something went wrong. Please check your connection.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }
