import 'package:family_mart/Store/Extras/approutes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state variables
  bool notificationsEnabled = false;
  bool biometricEnabled = false;
  bool darkModeEnabled = false;
  bool autoBackupEnabled = true;
  String selectedLanguage = 'English';
  String selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                AnimatedWrapper(index: 0, child: _buildTopBar()),

                // Profile Section
                const SizedBox(height: 16),

                // General Settings
                AnimatedWrapper(
                  index: 2,
                  child: _buildGeneralSettings(),
                ),
                const SizedBox(height: 16),

                // Security Settings
                AnimatedWrapper(
                  index: 3,
                  child: _buildSecuritySettings(),
                ),
                const SizedBox(height: 16),

                // Preferences
                AnimatedWrapper(
                  index: 4,
                  child: _buildPreferences(),
                ),
                const SizedBox(height: 16),

                // Support & Legal
                AnimatedWrapper(
                  index: 5,
                  child: _buildSupportSection(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.4)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildGeneralSettings() {
    return _buildSettingsSection(
      'General',
      [
        _buildSwitchTile(
          'Push Notifications',
          'Receive alerts and updates',
          Icons.notifications_rounded,
          notificationsEnabled,
          (value) => setState(() => notificationsEnabled = false),
        ),
        _buildNavigationTile(
          'Language',
          selectedLanguage,
          Icons.language_rounded,
          () => _showLanguageSelector(),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return _buildSettingsSection(
      'Security',
      [
        _buildNavigationTile(
          'Reset Password',
          'Change your account password',
          Icons.lock_reset_rounded,
          () => _showResetPasswordDialog(),
          color: AppColors.primary,
        ),
        _buildSwitchTile(
          'Biometric Authentication',
          'Use fingerprint or face unlock',
          Icons.fingerprint_rounded,
          biometricEnabled,
          (value) => setState(() => biometricEnabled = value),
        ),
        _buildNavigationTile(
          'Edit Profile',
          'Update your profile details',
          Icons.person_add_alt_rounded,
          () {
            Get.toNamed(RouteName.editprofile);
          },
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return _buildSettingsSection(
      'Preferences',
      [
        _buildSwitchTile(
          'Dark Mode',
          'Enable dark theme',
          Icons.dark_mode_rounded,
          darkModeEnabled,
          (value) => setState(() => darkModeEnabled = value),
        ),
        _buildNavigationTile(
          'Downloaded Data',
          'Your data as CSV/PDF',
          Icons.download_rounded,
          () => _showExportOptions(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      'Support & Legal',
      [
        _buildNavigationTile(
          'Help Center',
          'Get help and support',
          Icons.help_center_rounded,
          () {

          },
        ),
        _buildNavigationTile(
          'About Us',
          'Learn more about us',
          Icons.contact_support_rounded,
          () {
            Get.toNamed(RouteName.aboutUs);
          },
        ),
        _buildNavigationTile(
          'Terms of Service',
          'Read our terms and conditions',
          Icons.description_rounded,
          () {
            // Navigate to terms
          },
        ),
        _buildNavigationTile(
          'Privacy Policy',
          'How we handle your data',
          Icons.policy_rounded,
          () {
            // Navigate to privacy policy
          },
        ),
        _buildNavigationTile(
          'About',
          'App version and information',
          Icons.info_rounded,
          () => _showAboutDialog(),
        ),
        _buildNavigationTile(
          'Delete Account',
          'Permanently delete your account',
          Icons.delete_rounded,
          () {},
          color: Colors.red,
        ),

      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.grey.withOpacity(0.2),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final itemColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: itemColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.grey.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: AppColors.grey,
            inactiveTrackColor: AppColors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reset Password',
          style: AppTextStyles.heading2,
        ),
        content: Text(
          'Are you sure you want to reset your password? You will receive an email with instructions.',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
             Get.toNamed(RouteName.changepassword);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reset',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English'];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Language',
                style: AppTextStyles.heading2,
              ),
            ),
            ...languages.map((lang) => ListTile(
                  title: Text(lang, style: AppTextStyles.body1),
                  trailing: selectedLanguage == lang
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => selectedLanguage = lang);
                    Get.back();
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  void _showExportOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Export Data',
                style: AppTextStyles.heading2,
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.table_chart_rounded, color: Colors.green),
              title: Text('Export as CSV', style: AppTextStyles.body1),
              subtitle:
                  Text('Excel-compatible format', style: AppTextStyles.caption),
              onTap: () {
                Get.back();
                _showSnackbar('Exporting data as CSV...');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
              title: Text('Export as PDF', style: AppTextStyles.body1),
              subtitle: Text('Printable format', style: AppTextStyles.caption),
              onTap: () {
                Get.back();
                _showSnackbar('Exporting data as PDF...');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'About App',
          style: AppTextStyles.heading2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A modern ledger management app designed to help you track your finances efficiently.',
              style: AppTextStyles.body2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showSnackbar(String message) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
