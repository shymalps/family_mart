import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/otp_controller.dart';
import '../../Extras/styles.dart';
import '../../Widgets/loading_spinner.dart';


class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the OtpController
    final OtpController controller = Get.put(OtpController());

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
                _buildHeader(controller),
                const SizedBox(height: 40),
                _buildOtpCard(controller),
                const SizedBox(height: 30),
                _buildResendCode(controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(OtpController controller) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            size: 45,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'OTP Verification',
          style: AppTextStyles.heading0.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          'Enter the 4-digit code sent to\n${controller.phoneNumber.value}',
          textAlign: TextAlign.center,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.grey,
          ),
        )),
      ],
    );
  }

  Widget _buildOtpCard(OtpController controller) {
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
            _buildOtpInput(controller),
            const SizedBox(height: 30),
            _buildVerifyButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInput(OtpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP Code',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: AppTextStyles.heading0.copyWith(
              letterSpacing: 10,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: '----',
              hintStyle: AppTextStyles.heading0.copyWith(
                color: AppColors.lightGrey,
                letterSpacing: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Debug OTP display (remove in production)
        Obx(() => controller.generatedOtp.value.isNotEmpty
            ? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Debug OTP: ${controller.generatedOtp.value}',
            style: AppTextStyles.body2.copyWith(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildVerifyButton(OtpController controller) {
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
        onPressed: controller.isLoading.value
            ? null
            : () async {
          await controller.verifyOtp();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: SmallLoadingSpinner(
            colors: [AppColors.white],
          ),
        )
            : Text(
          'Verify OTP',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }

  Widget _buildResendCode(OtpController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: AppTextStyles.body2.copyWith(color: AppColors.grey),
        ),
        Obx(() => GestureDetector(
          onTap: controller.isLoading.value
              ? null
              : () async {
            await controller.sendOtp();
          },
          child: Text(
            'Resend',
            style: AppTextStyles.body2.copyWith(
              color: controller.isLoading.value
                  ? AppColors.lightGrey
                  : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
      ],
    );
  }
}