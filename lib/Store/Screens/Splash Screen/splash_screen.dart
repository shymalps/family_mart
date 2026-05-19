import 'package:flutter/material.dart';
import 'package:family_mart/Store/Extras/image_urls.dart';
import 'package:get/get.dart';

import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';
import '../../Widgets/loading_spinner.dart';
import '../../services/shared_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));


    final authService = Get.find<SharedPreferencesService>();
    if (authService.isLoggedIn) {
      Get.offAllNamed(RouteName.navbar);
    } else {
      Get.offAllNamed(RouteName.login);
    }
  }

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Image.asset(
                  ImageUrls.logo,
                  color: Colors.yellow[700],
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // App Name (optional)
              // Text(
              //   'Hyper Mart', // Replace with your app name
              //   style: AppTextStyles.heading1.copyWith(
              //     color: AppColors.primary,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 10),
              // Tagline (optional)
              Text(
                'Fresh groceries delivered to your door',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              const SizedBox(
                height: 20,
                width: 20,
                child: SmallLoadingSpinner(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}