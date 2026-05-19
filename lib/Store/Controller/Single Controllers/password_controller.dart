// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../Models/profile_model.dart';
// import '../../services/profile_service.dart';


// class ProfileController extends GetxController {
//   final ProfileService _profileService = Get.find<ProfileService>();

//   // Observable states
//   final Rx<ProfileData?> profileData = Rx<ProfileData?>(null);
//   final RxBool isLoading = false.obs;
//   final RxBool isUpdating = false.obs;
//   final RxString errorMessage = ''.obs;

//   // Password reset states
//   final RxBool isResettingPassword = false.obs;
//   final RxString passwordResetMessage = ''.obs;

//   // Getters
//   User? get user => profileData.value?.user;
//   Customer? get customer => profileData.value?.customer;
//   bool get hasProfile => profileData.value != null;

//   @override
//   void onInit() {
//     super.onInit();
//     loadProfile();
//   }

//   /// Load complete profile data
//   Future<void> loadProfile() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final response = await _profileService.getCompleteProfileData();

//       if (response.success && response.data != null) {
//         profileData.value = response.data;
//       } else {
//         errorMessage.value = response.message ?? 'Failed to load profile';
//         _showErrorSnackbar('Profile Error', errorMessage.value);
//       }
//     } catch (e) {
//       errorMessage.value = 'An unexpected error occurred';
//       _showErrorSnackbar('Error', errorMessage.value);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Refresh profile data
//   Future<void> refreshProfile() async {
//     await loadProfile();
//   }

//   /// Reset password
//   Future<bool> resetPassword({
//     required String phone,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     // Validation
//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showErrorSnackbar('Validation Error', 'Please fill all fields');
//       return false;
//     }

//     if (newPassword != confirmPassword) {
//       _showErrorSnackbar('Validation Error', 'Passwords do not match');
//       return false;
//     }

//     if (newPassword.length < 6) {
//       _showErrorSnackbar('Validation Error', 'Password must be at least 6 characters');
//       return false;
//     }

//     try {
//       isResettingPassword.value = true;
//       passwordResetMessage.value = '';

//       final response = await _profileService.resetPassword(newPassword);

//       if (response.success) {
//         passwordResetMessage.value = 'Password reset successfully';
//         _showSuccessSnackbar('Success', passwordResetMessage.value);
//         return true;
//       } else {
//         passwordResetMessage.value = response.message ?? 'Failed to reset password';
//         _showErrorSnackbar('Reset Failed', passwordResetMessage.value);
//         return false;
//       }
//     } catch (e) {
//       passwordResetMessage.value = 'An unexpected error occurred';
//       _showErrorSnackbar('Error', passwordResetMessage.value);
//       return false;
//     } finally {
//       isResettingPassword.value = false;
//     }
//   }

//   /// Update user profile
//   Future<bool> updateUserProfile({
//     String? name,
//     String? email,
//     String? phone,
//   }) async {
//     try {
//       isUpdating.value = true;
//       errorMessage.value = '';

//       // TODO: Implement update user profile API call
//       // This is a placeholder - you'll need to implement the actual API call
//       await Future.delayed(const Duration(seconds: 1));

//       // Refresh profile after update
//       await loadProfile();

//       _showSuccessSnackbar('Success', 'Profile updated successfully');
//       return true;
//     } catch (e) {
//       errorMessage.value = 'Failed to update profile';
//       _showErrorSnackbar('Update Failed', errorMessage.value);
//       return false;
//     } finally {
//       isUpdating.value = false;
//     }
//   }

//   /// Update customer profile
//   Future<bool> updateCustomerProfile({
//     String? address,
//     String? city,
//     String? state,
//     String? zipCode,
//   }) async {
//     try {
//       isUpdating.value = true;
//       errorMessage.value = '';

//       // TODO: Implement update customer profile API call
//       // This is a placeholder - you'll need to implement the actual API call
//       await Future.delayed(const Duration(seconds: 1));

//       // Refresh profile after update
//       await loadProfile();

//       _showSuccessSnackbar('Success', 'Customer details updated successfully');
//       return true;
//     } catch (e) {
//       errorMessage.value = 'Failed to update customer details';
//       _showErrorSnackbar('Update Failed', errorMessage.value);
//       return false;
//     } finally {
//       isUpdating.value = false;
//     }
//   }

//   /// Clear profile data (useful for logout)
//   void clearProfile() {
//     profileData.value = null;
//     errorMessage.value = '';
//     passwordResetMessage.value = '';
//   }

//   // Helper methods for showing snackbars
//   void _showSuccessSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       backgroundColor: Colors.green.withOpacity(0.9),
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(seconds: 3),
//       margin: const EdgeInsets.all(10),
//       borderRadius: 8,
//       icon: const Icon(Icons.check_circle, color: Colors.white),
//     );
//   }

//   void _showErrorSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       backgroundColor: Colors.red.withOpacity(0.9),
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(seconds: 3),
//       margin: const EdgeInsets.all(10),
//       borderRadius: 8,
//       icon: const Icon(Icons.error_outline, color: Colors.white),
//     );
//   }
// }