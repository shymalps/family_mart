import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Models/profile_model.dart';
import '../Widgets/snack_bar.dart';
import '../services/profile_service.dart';
import '../services/shared_pref.dart';
import '../services/update_profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final ProfileServiceUpdate _profileServiceUpdate = Get.find<ProfileServiceUpdate>();
  final SharedPreferencesService _prefsService = Get.find<SharedPreferencesService>();

  // Observables
  final isLoading = false.obs;
  final isLoadingUser = false.obs;
  final isLoadingCustomer = false.obs;
  final errorMessage = ''.obs;
  final hasError = false.obs;

  // Data observables
  final Rx<User?> user = Rx<User?>(null);
  final Rx<Customer?> customer = Rx<Customer?>(null);
  final Rx<ProfileData?> profileData = Rx<ProfileData?>(null);

  // Password reset observables
  final RxBool isResettingPassword = false.obs;
  final RxString passwordResetMessage = ''.obs;

  // Profile update observables
  final RxBool isUpdatingProfile = false.obs;
  final RxString profileUpdateMessage = ''.obs;

  // Getters for easy access
  User? get currentUser => user.value;
  Customer? get currentCustomer => customer.value;
  ProfileData? get currentProfileData => profileData.value;
  bool get hasUserData => user.value != null;
  bool get hasCustomerData => customer.value != null;
  bool get hasCompleteProfile => hasUserData && hasCustomerData;

  @override
  void onInit() {
    super.onInit();
    // Load profile data when controller is initialized
    loadCompleteProfile();
  }

  /// Load complete profile data (both user and customer)
  Future<void> loadCompleteProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _profileService.getCompleteProfileData();

      if (response.success && response.data != null) {
        profileData.value = response.data;
        user.value = response.data!.user;
        customer.value = response.data!.customer;

        // Update shared preferences with latest user data
        await _updateSharedPreferences();

        _logSuccess('Complete profile data loaded successfully');
      } else {
        _setError(response.message!);
        _logError('Failed to load complete profile', response.message!);
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading profile');
      _logError('Load Complete Profile Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load user data only
  Future<void> loadUserData() async {
    try {
      _setUserLoading(true);
      _clearError();

      final response = await _profileService.getUserData();

      if (response.success && response.data != null) {
        user.value = response.data;

        // Update profile data if customer data exists
        if (customer.value != null) {
          profileData.value = ProfileData(
            user: response.data!,
            customer: customer.value!,
          );
        }

        await _updateSharedPreferences();
        _logSuccess('User data loaded successfully');
      } else {
        _setError(response.message!);
        _logError('Failed to load user data', response.message!);
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading user data');
      _logError('Load User Data Error', e.toString());
    } finally {
      _setUserLoading(false);
    }
  }

  /// Load customer data only
  Future<void> loadCustomerData() async {
    try {
      _setCustomerLoading(true);
      _clearError();

      final response = await _profileService.getCustomerData();

      if (response.success && response.data != null) {
        customer.value = response.data;

        // Update profile data if user data exists
        if (user.value != null) {
          profileData.value = ProfileData(
            user: user.value!,
            customer: response.data!,
          );
        }

        _logSuccess('Customer data loaded successfully');
      } else {
        _setError(response.message!);
        _logError('Failed to load customer data', response.message!);
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading customer data');
      _logError('Load Customer Data Error', e.toString());
    } finally {
      _setCustomerLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String place,
    required String address,
  }) async {
    // Validation
    final validationError = _validateProfileInputs(name, phone, place, address);
    if (validationError != null) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: validationError,
      );
      return false;
    }

    try {
      isUpdatingProfile.value = true;
      profileUpdateMessage.value = '';
      _clearError();

      final response = await _profileServiceUpdate.updateProfile(
        name: name,
        phone: phone,
        place: place,
        address: address,
      );

      if (response.isSuccess && response.data != null) {
        // Update local user data
        if (user.value != null) {
          await _updateSharedPreferences();

          // Refresh complete profile to get latest data from server
          await loadCompleteProfile();
        }

        // Update shared preferences
        await _updateSharedPreferences();

        // Refresh complete profile to get latest data
        await loadCompleteProfile();

        profileUpdateMessage.value = response.data!.msg.isNotEmpty
            ? response.data!.msg
            : 'Profile updated successfully';

        AppSnackBar.show(
          title: 'Profile Update',
          message: profileUpdateMessage.value,
        );

        _logSuccess('Profile updated successfully');
        return true;
      } else {
        profileUpdateMessage.value = response.message ?? 'Failed to update profile';
        AppSnackBar.show(
          title: 'Profile Update Error',
          message: profileUpdateMessage.value,
        );
        _setError(profileUpdateMessage.value);
        return false;
      }
    } catch (e) {
      profileUpdateMessage.value = 'An unexpected error occurred while updating profile';
      AppSnackBar.show(
        title: 'Error',
        message: profileUpdateMessage.value,
      );
      _setError(profileUpdateMessage.value);
      _logError('Update Profile Error', e.toString());
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Validate profile input data
  String? _validateProfileInputs(String name, String phone, String place, String address) {
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

  /// Check if profile data has changed
  bool hasProfileDataChanged({
    required String name,
    required String phone,
    required String place,
    required String address,
  }) {
    if (user.value == null) return true;

    return user.value!.name != name.trim() ||
        user.value!.phone != phone.trim();
    // Add other field comparisons if available in User model
  }

  /// Get current profile data for form initialization
  Map<String, String> get currentProfileFormData {
    return {
      'name': user.value?.name ?? '',
      'phone': user.value?.phone ?? '',
      'place': '', // Add from customer data if available
      'address': '', // Add from customer data if available
    };
  }

  /// Reset password functionality
  Future<bool> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: 'Please fill all fields',
      );
      return false;
    }
    if (oldPassword.isEmpty) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: 'Please enter your old password',
      );
      return false;
    }

    if (_prefsService.userPassword != oldPassword) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: 'Your old password is incorrect',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: 'Passwords do not match',
      );
      return false;
    }

    if (newPassword.length < 6) {
      AppSnackBar.show(
        title: 'Validation Error',
        message: 'Password must be at least 6 characters',
      );
      return false;
    }

    try {
      isResettingPassword.value = true;
      passwordResetMessage.value = '';

      final response = await _profileService.resetPassword(newPassword);

      if (response.success) {
        passwordResetMessage.value = 'Password reset successfully';
        AppSnackBar.show(
          title: 'Password Reset',
          message: passwordResetMessage.value,
        );
        return true;
      } else {
        passwordResetMessage.value = response.message ?? 'Failed to reset password';
        AppSnackBar.show(
          title: 'Password Reset Error',
          message: passwordResetMessage.value,
        );
        return false;
      }
    } catch (e) {
      passwordResetMessage.value = 'An unexpected error occurred';
      AppSnackBar.show(
        title: 'Error',
        message: passwordResetMessage.value,
      );
      return false;
    } finally {
      isResettingPassword.value = false;
    }
  }

  /// Refresh all profile data
  Future<void> refreshProfile() async {
    await loadCompleteProfile();
  }

  /// Refresh user data only
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  /// Refresh customer data only
  Future<void> refreshCustomerData() async {
    await loadCustomerData();
  }

  /// Clear all profile data
  void clearProfileData() {
    user.value = null;
    customer.value = null;
    profileData.value = null;
    _clearError();
  }

  /// Check if user is logged in
  bool get isLoggedIn => _prefsService.isLoggedIn;

  /// Get user balance as double
  double get userBalance {
    if (customer.value?.balance != null) {
      try {
        return double.parse(customer.value!.balance);
      } catch (e) {
        _logError('Balance Parsing Error', e.toString());
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Get available credit as double
  double get availableCredit {
    if (customer.value?.availCredit != null) {
      try {
        return double.parse(customer.value!.availCredit);
      } catch (e) {
        _logError('Available Credit Parsing Error', e.toString());
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Get credit value as double
  double get creditValue {
    if (customer.value?.creditValue != null) {
      try {
        return double.parse(customer.value!.creditValue);
      } catch (e) {
        _logError('Credit Value Parsing Error', e.toString());
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Update shared preferences with current user data
  Future<void> _updateSharedPreferences() async {
    if (user.value != null) {
      await _prefsService.saveUser(
        id: user.value!.id,
        name: user.value!.name,
        userType: user.value!.userType,
        email: user.value!.email,
        phone: user.value!.phone,
      );
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    isLoading.value = value;
  }

  /// Set user loading state
  void _setUserLoading(bool value) {
    isLoadingUser.value = value;
  }

  /// Set customer loading state
  void _setCustomerLoading(bool value) {
    isLoadingCustomer.value = value;
  }

  /// Set error state
  void _setError(String message) {
    errorMessage.value = message;
    hasError.value = true;
  }

  /// Clear error state
  void _clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  /// Logging methods
  void _logSuccess(String message) {
    if (kDebugMode) {
      debugPrint('✅ ProfileController: $message');
    }
  }

  void _logError(String type, String message) {
    if (kDebugMode) {
      debugPrint('❌ ProfileController - $type: $message');
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}