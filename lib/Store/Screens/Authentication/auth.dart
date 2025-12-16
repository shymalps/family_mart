import 'package:family_mart/Store/Extras/image_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/authcontroller.dart';
import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';

import '../../Widgets/loading_spinner.dart';

import '../Navigation/bottom_navigation.dart';

class AuthPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Image.asset(
            ImageUrls.logo,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        Text(
          'Fresh groceries delivered to your door',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.grey,
          ),
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
            _buildAuthToggle(),
            const SizedBox(height: 30),
            _buildAuthForm(),
            const SizedBox(height: 24),
            _buildAuthButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!authController.isLogin.value) {
                      authController.toggleAuthMode();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: authController.isLogin.value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: authController.isLogin.value
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: AppTextStyles.body1.copyWith(
                          color: authController.isLogin.value
                              ? AppColors.white
                              : AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (authController.isLogin.value) {
                      authController.toggleAuthMode();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !authController.isLogin.value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: !authController.isLogin.value
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        'Register',
                        style: AppTextStyles.body1.copyWith(
                          color: !authController.isLogin.value
                              ? AppColors.white
                              : AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildAuthForm() {
    return Obx(() => Column(
          children: [
            if (!authController.isLogin.value) ...[
              _buildTextField(
                controller: authController.nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: authController.phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
            ],
            _buildTextField(
              controller: authController.emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: authController.passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: authController.obscurePassword.value,
              onToggleVisibility: authController.togglePasswordVisibility,
            ),
            if (!authController.isLogin.value) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: authController.confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: authController.obscureConfirmPassword.value,
                onToggleVisibility:
                    authController.toggleConfirmPasswordVisibility,
              ),
            ],
            if (authController.isLogin.value) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Handle forgot password
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.body2,
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
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return Obx(() => Container(
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
                : authController.authenticate,
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
                    child: SmallLoadingSpinner(
                      colors: [AppColors.white],
                    ),
                  )
                : Text(
                    authController.isLogin.value ? 'Login' : 'Register',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
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
          color: AppColors.white, // Container background
          child: Material(
            // color: Colors.red, // Forces white behind the button
            child: OutlinedButton(
              onPressed: () async {
                // Show loading indicator
                authController.isLoading1.value = true;

                await Future.delayed(const Duration(seconds: 2));

                authController.isLoading1.value = false;

                // Navigate after loading
                Get.toNamed(RouteName.navbar);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                // Button background
                foregroundColor: AppColors.primary,
                // Text and ripple
                side: const BorderSide(color: AppColors.primary),
                // Border
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  AppColors.primary.withOpacity(0.1), // Light ripple effect
                ),
              ),
              child: Obx(() => authController.isLoading1.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: SmallLoadingSpinner(
                        colors: [AppColors.primary],
                      ),
                    )
                  : Text(
                      'Continue without login',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
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
