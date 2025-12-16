import 'package:family_mart/Store/Screens/Dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Extras/styles.dart';
import '../Cart/cart_page.dart';
import '../Category/category_page.dart';
import '../Grocery Home/HomePage/grocery_home_page.dart';
import '../Profile/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => MainNavigationPageState();
}

class MainNavigationPageState extends State<MainNavigationPage> {
  // This is our reactive tab index
  final RxInt _selectedIndex = 0.obs;

  // Make this accessible globally without a controller file
  static MainNavigationPageState get to =>
      Get.find<MainNavigationPageState>();

  final List<Widget> _pages = [
    GroceryHomePage(),
    const CategoryPage(),
    const DashboardPage(),
    const CartPage(),
    ProfilePage(),
  ];

  void changeTab(int index) {
    _selectedIndex.value = index;
  }

  @override
  void initState() {
    super.initState();
    // Register this state in GetX so we can access it from anywhere
    Get.put<MainNavigationPageState>(this);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: _pages[_selectedIndex.value],
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          selectedLabelStyle: AppTextStyles.caption,
          unselectedLabelStyle: AppTextStyles.caption,
          elevation: 0,
          currentIndex: _selectedIndex.value,
          onTap: changeTab,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex.value == 2
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dashboard_outlined, color: AppColors.white),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      }),
    );
  }
}
