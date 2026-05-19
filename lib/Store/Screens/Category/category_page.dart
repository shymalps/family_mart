import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/category_controller.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the CategoryController instance
    final CategoryController categoryController =
        Get.find<CategoryController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              AnimatedWrapper(index: 0, child: _buildTopBar()),

              // Grid View - Wrapped in Expanded to prevent overflow
              Expanded(
                child: AnimatedWrapper(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      if (categoryController.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        );
                      }
                      if (categoryController.errorMessage.value.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                categoryController.errorMessage.value,
                                style: AppTextStyles.body1.copyWith(
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    categoryController.fetchCategories(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (categoryController.categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No categories available',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  1.5, // Adjusted for text-only cards
                            ),
                        itemCount: categoryController.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryController.categories[index];
                          // Create a gradient color based on the category name
                          final gradientColors = _getCategoryGradient(
                            category.name,
                            index,
                          );

                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // Handle category tap
                                  print('Tapped on ${category.name}');
                                  Get.toNamed(
                                    RouteName.productsBasedOnCategory,
                                    arguments: {
                                      'id': category.id,
                                      'name': category.name.toString(),
                                      'icon': Icons.eco_rounded,
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 20,
                                    bottom: 6,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Category initial as a decorative element
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(
                                            0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          border: Border.all(
                                            color: AppColors.white.withOpacity(
                                              0.5,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            category.name.isNotEmpty
                                                ? category.name[0].toUpperCase()
                                                : '?',
                                            style: AppTextStyles.heading2
                                                .copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Category name
                                      Text(
                                        category.name,
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Decorative dots
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          3,
                                          (dotIndex) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back_ios, color: AppColors.grey),
      //   onPressed: () {
      //     Get.back();
      //   },
      // ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.toNamed(RouteName.notifications);
          },
          icon: const Icon(Icons.notifications_outlined, color: AppColors.grey),
        ),
      ],
    );
  }

  // Helper method to generate gradient colors based on category name and index
  List<Color> _getCategoryGradient(String categoryName, int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple-Blue
      [const Color(0xFFc73866), const Color(0xFF8b2635)], // Dark Pink-Red
      [const Color(0xFF2563eb), const Color(0xFF1e40af)], // Dark Blue
      [const Color(0xFF059669), const Color(0xFF047857)], // Dark Green
      [const Color(0xFFd97706), const Color(0xFF92400e)], // Dark Orange
      [const Color(0xFF7c3aed), const Color(0xFF5b21b6)], // Dark Purple
      [const Color(0xFF0891b2), const Color(0xFF0e7490)], // Dark Cyan
      [const Color(0xFFdc2626), const Color(0xFF991b1b)], // Dark Red
      [const Color(0xFF1f2937), const Color(0xFF374151)], // Dark Gray
      [const Color(0xFF6366f1), const Color(0xFF4338ca)], // Dark Indigo
    ];

    return gradients[index % gradients.length];
  }
}
