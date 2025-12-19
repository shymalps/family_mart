import 'package:family_mart/Store/Extras/approutes/route_name.dart';
import 'package:family_mart/Store/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/profile_controller.dart';
import '../../Extras/animated_wrapper.dart';

import '../../Extras/styles.dart';
import '../Dashboard/dashboard_screen.dart';

class ProfilePage extends StatelessWidget {
  final profileController = Get.find<ProfileController>();
  final sharedController = Get.find<SharedPreferencesService>();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Profile Page");
    print(profileController.isLoggedIn);
    return profileController.isLoggedIn
        ? Scaffold(
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
                      AnimatedWrapper(
                        index: 1,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildProfileContent(),
                        ),
                      ),
                      Column(
                        children: [
                          AnimatedWrapper(
                            index: 2,
                            child: _buildMenuSection([
                              _MenuItemData(
                                Icons.shopping_bag,
                                'My Orders',
                                () {
                                  Get.toNamed(RouteName.orders);
                                },
                              ),
                              _MenuItemData(Icons.dashboard, 'Dashboard', () {
                                Get.to(
                                  () =>
                                      const DashboardPage(showBackButton: true),
                                  transition: Transition
                                      .rightToLeft, // Optional: smooth transition
                                );
                              }),
                              _MenuItemData(Icons.receipt_long, 'Bills', () {
                                Get.toNamed(RouteName.billlist);
                              }),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          AnimatedWrapper(
                            index: 3,
                            child: _buildMenuSection([
                              _MenuItemData(
                                Icons.account_balance_wallet,
                                'Credit',
                                () {
                                  Get.toNamed(RouteName.creditHistory);
                                },
                              ),
                              _MenuItemData(Icons.book_rounded, 'Ledger', () {
                                Get.toNamed(RouteName.ledger);
                              }),
                              _MenuItemData(
                                Icons.settings_rounded,
                                'Settings',
                                () {
                                  Get.toNamed(RouteName.settings);
                                },
                              ),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          AnimatedWrapper(
                            index: 5,
                            child: _buildMenuItem(
                              Icons.logout_rounded,
                              'Logout',
                              () => _showLogoutDialog(context),
                              color: AppColors.red,
                              isDestructive: true,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You are not logged in', style: AppTextStyles.heading1),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(RouteName.login);
                    },
                    child: Text(
                      'Login',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildProfileContent() {
    return Obx(() {
      return Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profileController.customer.value?.name ?? 'Not Available',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            profileController.user.value?.email ?? 'Not Available',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildInfoSection(),
        ],
      );
    });
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Obx(() {
        return Column(
          children: [
            _buildInfoRow(
              Icons.phone_rounded,
              'Phone',
              profileController.user.value?.phone ?? 'Not Available',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_city_rounded,
              'Place',
              profileController.customer.value?.place ?? 'Not Available',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.home_rounded,
              'Address',
              profileController.customer.value?.address ?? 'Not Available',
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<_MenuItemData> items) {
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
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          _MenuItemData item = entry.value;
          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: AppColors.grey.withOpacity(0.2),
                  indent: 56,
                ),
              _buildMenuTile(item.icon, item.title, item.onTap),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDestructive
            ? AppColors.red.withOpacity(0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDestructive
            ? Border.all(color: AppColors.red.withOpacity(0.2), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMenuTile(icon, title, onTap, color: color),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.grey.withOpacity(0.6),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // GestureDetector(
          //   onTap: () {
          //     // Get.offNamed(RouteName.GroceryHomePage);
          //     print("Back to previous screen");
          //   },
          //   child: Icon(Icons.arrow_back),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTextStyles.heading1),
              const SizedBox(width: 20),
              Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              sharedController.clearUserData();
              print('is user logged in: ${sharedController.isLoggedIn}');
              Get.offAllNamed(RouteName.login);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItemData(this.icon, this.title, this.onTap);
}
