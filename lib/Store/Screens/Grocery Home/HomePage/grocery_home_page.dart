import 'package:family_mart/Store/Extras/approutes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Controller/category_controller.dart';
import '../../../Controller/product_list_controller.dart';
import '../../../Controller/profile_controller.dart';
import '../../../Extras/animated_wrapper.dart';
import '../../../Extras/image_urls.dart';
import '../../../Extras/styles.dart';
import '../../../Widgets/loading_spinner.dart';
import '../../../services/shared_pref.dart';
import '../../Navigation/bottom_navigation.dart';
import '../Widgets/enchanced_search.dart';

class GroceryHomePage extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();
  final CategoryController categoryController = Get.put(CategoryController());
  final ProfileController profileController = Get.put(ProfileController());
  final ScrollController _scrollController = ScrollController();
  final SharedPreferencesService authService = Get.find<
      SharedPreferencesService>();


  GroceryHomePage({super.key}) {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      productController.loadMoreProducts();
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
            stops: [0.1, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedWrapper(index: 0, child: _buildTopBar(context)),
              AnimatedWrapper(index: 1, child: _buildSearchBar()),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: productController.refreshProducts,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedWrapper(
                            index: 2, child: _buildVegetablesBanner()),
                        const SizedBox(height: 24),
                        AnimatedWrapper(
                            index: 3, child: _buildMostPopularCategory()),
                        const SizedBox(height: 24),
                        AnimatedWrapper(
                            index: 4, child: _buildFeaturedProducts()),
                        _buildLoadMoreIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.white,
            child: Image.asset(ImageUrls.logo, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FamilyMart', style: AppTextStyles.heading0),
                Obx(() {
                  return Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.primary),
                      authService.isLoggedIn ? Text(
                          profileController.customer.value?.place ??
                              'Not Available',
                          style: AppTextStyles.body2.copyWith(color: AppColors
                              .black)) : Text('Loading...',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.black)),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(RouteName.notifications);
            },
            icon:
            const Icon(Icons.notifications_outlined, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: EnhancedSearchWidget(
        productController: productController,
        categoryController: categoryController,
        onSearch: (query) {
          productController.searchProducts(query);
        },
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.mic, color: AppColors.primary),
    );
  }

  Widget _buildVegetablesBanner() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          _buildBannerBackground(),
          _buildBannerContent(),
          _buildBannerRating(),
        ],
      ),
    );
  }

  Widget _buildBannerBackground() {
    return Positioned(
      right: -20,
      top: -20,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildBannerContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get',
                    style:
                    AppTextStyles.body1.copyWith(color: AppColors.white)),
                Text('VEGETABLES',
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.white)),
                Text('UPTO 50% OFF',
                    style:
                    AppTextStyles.caption.copyWith(color: AppColors.white)),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ORDER NOW',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_basket,
                size: 40, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerRating() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('5.00',
            style: AppTextStyles.caption.copyWith(color: AppColors.white)),
      ),
    );
  }

  Widget _buildMostPopularCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Most Popular Categories', Icons.trending_up),
        const SizedBox(height: 14),
        Obx(() => _buildCategoryContent()),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading3),
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.3)
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: AppColors.primary, size: 20),
            onPressed: () {
              MainNavigationPageState.to.changeTab(1); // Go to Category tab

            },),
        ),
      ],
    );
  }

  Widget _buildCategoryContent() {
    if (categoryController.isLoading.value) {
      return _buildSkeletonList(
          height: 100, itemCount: 5, itemBuilder: _buildSkeletonCategoryItem);
    }

    if (categoryController.errorMessage.isNotEmpty) {
      return _buildErrorContainer('Unable to load categories');
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categoryController.categories.length > 10
            ? 10
            : categoryController.categories.length,
        itemBuilder: (context, index) {
          final category = categoryController.categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildCategoryItem(category.name, index, category.id),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList({required double height,
    required int itemCount,
    required Widget Function() itemBuilder}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: itemBuilder(),
            ),
      ),
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.grey, size: 24),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String categoryName, int index, int id) {
    final Color backgroundColor = _getCategoryColor(categoryName);

    return GestureDetector(
      onTap: () {
        print(categoryName);

        Get.toNamed(RouteName.productsBasedOnCategory, arguments: {
          'id': id,
          'name': categoryName.toString(),
          'icon': Icons.eco_rounded,
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOutBack,
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor.withOpacity(0.15),
              backgroundColor.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: backgroundColor.withOpacity(0.3), width: 2),
        ),
        child: Stack(
          children: [
            _buildCategoryBackground(backgroundColor),
            _buildCategoryText(categoryName),
            _buildCategoryShine(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBackground(Color backgroundColor) {
    return Positioned(
      top: -8,
      right: 10,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildCategoryText(String categoryName) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          categoryName,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCategoryShine() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSkeletonCategoryItem() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 80, height: 12, child: ColoredBox(color: Colors.grey)),
            SizedBox(height: 8),
            SizedBox(
                width: 60, height: 8, child: ColoredBox(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    const colors = [
      AppColors.accent,
      AppColors.primary,
      AppColors.primary,
      AppColors.primaryDark,
      AppColors.primary,
      AppColors.primary,
      AppColors.primaryDark,
    ];
    return colors[categoryName.hashCode % colors.length];
  }

  Widget _buildFeaturedProducts() {
    return Obx(() {
      if (productController.errorMessage.isNotEmpty &&
          productController.filteredProducts.isEmpty) {
        return _buildProductErrorWidget();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductsHeader(),
          const SizedBox(height: 16),
          _buildProductsGrid(),
        ],
      );
    });
  }

  Widget _buildProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Featured Products', style: AppTextStyles.heading3),
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.3)
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (productController.searchQuery.isNotEmpty)
              IconButton(
                onPressed: productController.clearSearch,
                icon: const Icon(Icons.clear, color: AppColors.grey),
              ),
            const Icon(Icons.more_horiz, color: AppColors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsGrid() {
    return Skeletonizer(
      enabled: productController.isLoading,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: productController.isLoading &&
            productController.filteredProducts.isEmpty
            ? 6
            : productController.filteredProducts.length,
        itemBuilder: (context, index) {
          // print('dummy print 2');
          // print(productController.filteredProducts[index].fileName);
          // print(productController.filteredProducts[index].imageUrl);
          if (productController.isLoading &&
              productController.filteredProducts.isEmpty) {
            return _buildSkeletonProductCard();
          }

          final product = productController.filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (productController.isLoadingMore) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SmallLoadingSpinner(
              colors: [AppColors.primary],
            ),
          ),
        );
      }

      if (!productController.hasMoreData &&
          productController.filteredProducts.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No more products to load',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildProductErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text('Oops! Something went wrong', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            productController.errorMessage,
            style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: productController.refreshProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: ColoredBox(color: Colors.grey),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: double.infinity,
                    height: 16,
                    child: ColoredBox(color: Colors.grey)),
                SizedBox(height: 8),
                SizedBox(
                    width: 80,
                    height: 12,
                    child: ColoredBox(color: Colors.grey)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 60,
                            height: 16,
                            child: ColoredBox(color: Colors.grey)),
                        SizedBox(height: 4),
                        SizedBox(
                            width: 100,
                            height: 12,
                            child: ColoredBox(color: Colors.grey)),
                      ],
                    ),
                    CircleAvatar(radius: 15, backgroundColor: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return InkWell(
      onTap: () {
        Get.toNamed(RouteName.prodesc, arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),
            _buildProductInfo(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(dynamic product) {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                  Icons.shopping_basket,
                  size: 40,
                  color: AppColors.grey),
            ),
          )
              : const Icon(Icons.shopping_basket,
              size: 40, color: AppColors.grey),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-20%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
                color: AppColors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, size: 22),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: AppTextStyles.body2.copyWith(color: AppColors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.subName.toString().toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${product.mrp.toStringAsFixed(2)}',
                      style: AppTextStyles.price),
                  Text(
                    '${product.value}/${product.measurement}',
                    style:
                    AppTextStyles.caption.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.white, size: 22),
                  onPressed: () {},
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
