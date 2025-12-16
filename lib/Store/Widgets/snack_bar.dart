import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Extras/styles.dart';

class AppSnackBar {
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Color backgroundColor = AppColors.primary,
    Color textColor = AppColors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: const EdgeInsets.all(16), // Optional: adds some margin
      borderRadius: 8, // Optional: rounds the corners
    );
  }

  // Predefined types for common use cases
  static void success(String message, {String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.success, // Define this in your colors
    );
  }

  static void error(String message, {String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.error, // Define this in your colors
    );
  }

  static void info(String message, {String title = 'Info'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.info, // Define this in your colors
    );
  }
}