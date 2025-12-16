import 'package:family_mart/Store/Controller/cart_controller.dart';
import 'package:family_mart/Store/Extras/approutes/route_name.dart';
import 'package:family_mart/Store/Widgets/loading_spinner.dart';
import 'package:family_mart/Store/Widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../Models/cart_model.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/styles.dart';
import '../../Extras/urls.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

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
            stops: [0.1, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedWrapper(index: 0, child: _buildTopBar()),
              Expanded(
                child: Obx(() {
                  if (cartController.isLoading) {
                    return _buildLoadingState();
                  }

                  if (cartController.isEmpty) {
                    return _buildEmptyState();
                  }

                  if (cartController.errorMessage.isNotEmpty) {
                    return _buildErrorState(cartController);
                  }

                  return _buildCartItems(cartController);
                }),
              ),
              Obx(() {
                if (cartController.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildCheckoutSection(cartController);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: AppTextStyles.heading1,
              ),
              Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const Spacer(),
          Obx(() {
            final CartController cartController = Get.find<CartController>();
            return Stack(
              children: [
                IconButton(
                  onPressed: () => cartController.refresh(),
                  icon: const Icon(Icons.refresh, color: AppColors.grey),
                ),
                if (cartController.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartController.itemCount}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            onPressed: () {
              Get.toNamed(RouteName.notifications);
            },
            icon: const Icon(Icons.notifications_outlined, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SmallLoadingSpinner(),
          SizedBox(height: 16),
          Text('Loading your cart...', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTextStyles.heading3.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your cart to see them here',
            style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to products/categories page
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Continue Shopping', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CartController cartController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: AppTextStyles.heading3.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              cartController.errorMessage,
              style: AppTextStyles.body2.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => cartController.fetchCart(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Retry', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartController cartController) {
    return RefreshIndicator(
      onRefresh: () => cartController.refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cartController.cartItems.length,
        itemBuilder: (context, index) {
          final CartItem item = cartController.cartItems[index];
          return AnimatedWrapper(
            index: index,
            child: _buildCartItem(item, cartController),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartController cartController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          _buildProductImage(item),
          const SizedBox(width: 16),
          Expanded(
            child: _buildProductDetails(item),
          ),
          _buildQuantityAndPrice(item, cartController),
        ],
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    print(item.fileName);
    print(Constants.imageBaseURL);
    print('${Constants.thumbnailBaseUrl}${item.fileName}');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: item.fileName.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: '${Constants.thumbnailBaseUrl}${item.fileName}',
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.shopping_basket,
            color: AppColors.grey,
          ),
        )
            : const Icon(Icons.shopping_basket, color: AppColors.grey),
      ),
    );
  }

  Widget _buildProductDetails(CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: AppTextStyles.body1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (item.subName.isNotEmpty && item.subName != '.')
          Text(
            item.subName,
            style: AppTextStyles.body2.copyWith(color: AppColors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (item.effectivePrice != item.mrpDouble)
              Text(
                '₹${item.mrpDouble.toStringAsFixed(2)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (item.effectivePrice != item.mrpDouble) const SizedBox(width: 8),
            Text(
              '₹${item.effectivePrice.toStringAsFixed(2)}',
              style: AppTextStyles.price.copyWith(
                color: item.effectivePrice != item.mrpDouble
                    ? AppColors.primary
                    : AppColors.bgColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndPrice(CartItem item, CartController cartController) {
    print(item.id);
    print(item.totalPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${item.totalPrice.toStringAsFixed(2)}',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Obx(() => cartController.isUpdating
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _buildQuantityButton(
            //   icon: Icons.remove,
            //   onTap: () => cartController.decreaseQuantity(item),
            //   backgroundColor: AppColors.lightGrey,
            //   iconColor: AppColors.blue,
            // ),
            const SizedBox(width: 12),
            Text(
              // '22',
              '${item.countInt}',
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            // _buildQuantityButton(
            //   icon: Icons.add,
            //   onTap: () => cartController.increaseQuantity(item),
            //   backgroundColor: AppColors.primary,
            //   iconColor: AppColors.white,
            // ),
          ],
        )),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items (${cartController.totalQuantity})',
                    style: AppTextStyles.body2.copyWith(color: AppColors.grey),
                  ),
                  Text(
                    'Total:',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              Text(
                '₹${cartController.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartController.isUpdating
                  ? null
                  : () {
                // Navigate to checkout page
                _proceedToCheckout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.lightGrey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: cartController.isUpdating
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text('Request this order', style: AppTextStyles.button),
            ),
          )),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    final CartController cartController = Get.find<CartController>();

    if (cartController.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items to your cart first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to checkout page
    // Get.toNamed('/checkout');

    // For now, show a dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${cartController.totalQuantity}'),
            Text('Total: ₹${cartController.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Proceed to payment?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AppSnackBar.show(title: 'Order Requested',message: 'Order requested successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Place Order', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}