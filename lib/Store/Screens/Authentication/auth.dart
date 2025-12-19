import 'package:family_mart/Store/Controller/category_controller.dart';
import 'package:family_mart/Store/Controller/product_list_controller.dart';
import 'package:family_mart/Store/Controller/profile_controller.dart';
import 'package:family_mart/Store/Extras/image_urls.dart';
import 'package:family_mart/Store/Screens/Category/category_page.dart';
import 'package:family_mart/Store/Screens/Dashboard/dashboard_screen.dart';
import 'package:family_mart/Store/Screens/Grocery%20Home/HomePage/grocery_home_page.dart';
import 'package:family_mart/Store/services/category_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/authcontroller.dart';
import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';

import '../../Widgets/loading_spinner.dart';

import '../Navigation/bottom_navigation.dart';

class AuthPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final productController = Get.put(ProductController());
  // final CategoryService = Get.put(CategoryServices());

  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildAuthCard(),
                const SizedBox(height: 30),
                _buildSocialLogin(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: Image.asset(ImageUrls.logo, fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        Text(
          'Fresh groceries delivered to your door',
          style: AppTextStyles.body2.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Login',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildAuthForm(),
            const SizedBox(height: 24),
            _buildAuthButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: authController.usernameController,
            label: 'Username',
            icon: Icons.person_2,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildTextField(
              controller: authController.passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: authController.obscurePassword.value,
              onToggleVisibility: authController.togglePasswordVisibility,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 4) {
                  return 'Password must be at least 4 characters';
                }
                return null;
              },
            ),
          ),
          // const SizedBox(height: 16),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: GestureDetector(
          //     onTap: () {
          //       // Handle forgot password
          //     },
          //     child: Text(
          //       'Forgot Password?',
          //       style: AppTextStyles.body2.copyWith(
          //         color: AppColors.primary,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.body2,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body2.copyWith(color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          errorStyle: AppTextStyles.caption.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: authController.isLoading.value
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    authController.authenticate();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: authController.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: SmallLoadingSpinner(colors: [AppColors.white]),
                )
              : Text(
                  'Login',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.lightGrey.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or',
                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.lightGrey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          color: AppColors.white,
          child: Material(
            child: Obx(
              () => OutlinedButton(
                onPressed: authController.isLoading1.value
                    ? null
                    : () async {
                        authController.isLoading1.value = true;
                        Get.put(ProductController());
                        // Get.put(CategoryController());
                        // Get.put(ProfileController());
                        await Future.delayed(const Duration(seconds: 1));

                        authController.isLoading1.value = false;
                        Get.off(() => GroceryHomePage());

                        print("Continue without login");
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authController.isLoading1.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: SmallLoadingSpinner(colors: [AppColors.primary]),
                      )
                    : Text(
                        'Continue without login',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Handle terms of service
              },
              child: Text(
                'Terms of Service',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              ' and ',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
            GestureDetector(
              onTap: () {
                // Handle privacy policy
              },
              child: Text(
                'Privacy Policy',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
