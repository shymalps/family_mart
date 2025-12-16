import 'package:family_mart/Store/Controller/profile_controller.dart';
import 'package:family_mart/Store/Extras/approutes/route_name.dart';
import 'package:family_mart/Store/Screens/Dashboard/credit_screen.dart';
import 'package:family_mart/Store/Widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/Single Controllers/total_purchase_controller.dart';

import '../../Extras/animated_wrapper.dart';
import '../../Extras/image_urls.dart';
import '../../Extras/styles.dart';

class DashboardPage extends StatefulWidget {
  final bool showBackButton;
  const DashboardPage({super.key, this.showBackButton = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final profileController = Get.find<ProfileController>();
  final controller = Get.put(PurchaseCountController());

  // Sample data - replace with your actual data sources
  final RxDouble totalPurchases = 00.00.obs;
  final RxDouble totalCredits = 00.00.obs;
  final RxDouble availableCredits = 00.00.obs;
  double accountBalance = 00.00;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    isLoading.value = true;
    try {
      // Fetch latest purchase count
      await controller.fetchPurchaseCount();
      final purchaseCount = controller.totalPurchaseCount.value;

      // Update values from controller, handling null cases
      totalPurchases.value =
          (controller.totalPurchaseCount.value ?? 0).toDouble();
      totalCredits.value = profileController.customer.value != null
          ? double.tryParse(profileController.customer.value!.creditValue) ??
              0.0
          : 0.0;

      availableCredits.value = profileController.customer.value != null
          ? double.tryParse(profileController.customer.value!.availCredit) ??
              0.0
          : 0.0;
      accountBalance = (profileController.userBalance ?? 0).toDouble();

      // Debug prints
      print('Purchase Count: $purchaseCount');
      print('Total Purchases: $totalPurchases');
      print('Total Credits: $totalCredits');
      print('Available Credits: $availableCredits');
      print('Account Balance: $accountBalance');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgColor,
              AppColors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  AnimatedWrapper(index: 0, child: _buildTopBar()),

                  // Welcome Section
                  AnimatedWrapper(
                    index: 1,
                    child: _buildWelcomeSection(),
                  ),

                  const SizedBox(height: 20),

                  // Financial Overview Cards
                  AnimatedWrapper(
                    index: 2,
                    child: _buildFinancialOverview(),
                  ),

                  const SizedBox(height: 20),

                  // Quick Actions
                  AnimatedWrapper(
                    index: 3,
                    child: _buildQuickActions(),
                  ),

                  const SizedBox(height: 20),

                  // Recent Activity
                  AnimatedWrapper(
                    index: 4,
                    child: _buildRecentActivity(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
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
         if(widget.showBackButton) ...[ GestureDetector(
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
          ],
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard', style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 80,
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

      ],),
    );
  }

  Widget _buildWelcomeSection() {
    print('profileController.customer.value!.imageUrl');
    print(profileController.customer.value!.imageUrl);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileController.user.value?.name ?? 'User',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Here\'s your financial overview',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // optional rounded corners
                child: (profileController.customer.value?.imageUrl.isNotEmpty ?? false)
                    ? Image.network(
                  profileController.customer.value!.imageUrl,
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      ImageUrls.logo,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  ImageUrls.logo,
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                ),
              ),
            )

          ],
        );
      }),
    );
  }

  Widget _buildFinancialOverview() {
    return Obx(() {
      if (isLoading.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(40),
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
          child: const Center(child: SmallLoadingSpinner()),
        );
      }

      return Column(
        children: [
          // Top Row
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  title: 'Total Purchases',
                  amount: totalPurchases.value,
                  icon: Icons.shopping_cart_rounded,
                  color: Colors.blue,
                  trend: '+12.5%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialCard(
                  title: 'Account Balance',
                  amount: accountBalance,
                  icon: Icons.account_balance_rounded,
                  color: Colors.green,
                  trend: '+5.2%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom Row
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  title: 'Total Credits',
                  amount: totalCredits.value,
                  icon: Icons.credit_card_rounded,
                  color: Colors.orange,
                  trend: '+8.1%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialCard(
                  title: 'Available Credits',
                  amount: availableCredits.value,
                  icon: Icons.savings_rounded,
                  color: Colors.purple,
                  trend: '-2.3%',
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildFinancialCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: AppTextStyles.caption.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.grey,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₹${_formatAmount(amount)}',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.receipt,
                label: 'Bills',
                color: Colors.blue,
                onTap: () {
                  Get.toNamed(RouteName.billlist);
                },
              ),
              _buildQuickActionItem(
                icon: Icons.history,
                label: 'Ledger',
                color: Colors.green,
                onTap: () {
                  Get.toNamed(RouteName.ledger);
                },
              ),
              _buildQuickActionItem(
                icon: Icons.pending_actions,
                label: 'Dues',
                color: Colors.orange,
                onTap: () {
                  Get.toNamed(RouteName.dues);
                },
              ),
              _buildQuickActionItem(
                icon: Icons.credit_card_sharp,
                label: 'Credits',
                color: Colors.purple,
                onTap: () {
                 Get.toNamed(RouteName.creditHistory);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentActivities = [
      _ActivityItem(
        title: 'Payment Received',
        subtitle: 'From order #1234',
        amount: '+₹2,500.00',
        time: '2 hours ago',
        icon: Icons.payment_rounded,
        color: Colors.green,
        isCredit: true,
      ),
      _ActivityItem(
        title: 'Purchase Made',
        subtitle: 'Electronics & Gadgets',
        amount: '-₹1,200.50',
        time: '5 hours ago',
        icon: Icons.shopping_bag_rounded,
        color: Colors.blue,
        isCredit: false,
      ),
      _ActivityItem(
        title: 'Credit Added',
        subtitle: 'Bank transfer',
        amount: '+₹5,000.00',
        time: '1 day ago',
        icon: Icons.account_balance_rounded,
        color: Colors.orange,
        isCredit: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bills',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity history
                },
                child: Text(
                  'View All',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentActivities.asMap().entries.map((entry) {
            int index = entry.key;
            _ActivityItem activity = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    height: 24,
                    color: AppColors.grey.withOpacity(0.2),
                  ),
                _buildActivityItem(activity),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem activity) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activity.icon, color: activity.color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.subtitle,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              activity.amount,
              style: AppTextStyles.body1.copyWith(
                color: activity.isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              activity.time,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final IconData icon;
  final Color color;
  final bool isCredit;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.icon,
    required this.color,
    required this.isCredit,
  });
}
