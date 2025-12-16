// Controllers/cart_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Models/cart_model.dart';
import '../services/cart_services.dart';

class CartController extends GetxController {
  final CartService _cartService = Get.find<CartService>();

  // Observable variables
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxDouble _totalAmount = 0.0.obs;
  final RxInt _totalQuantity = 0.obs;

  // Getters
  List<CartItem> get cartItems => _cartItems.value;
  bool get isLoading => _isLoading.value;
  bool get isUpdating => _isUpdating.value;
  String get errorMessage => _errorMessage.value;
  double get totalAmount => _totalAmount.value;
  int get totalQuantity => _totalQuantity.value;
  bool get isEmpty => _cartItems.isEmpty;
  int get itemCount => _cartItems.length;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  /// Fetch cart items from server
  Future<void> fetchCart({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _cartService.getCart();

      if (response.isSuccess && response.data != null) {
        _cartItems.value = response.data!.data;
        _calculateTotals();

        if (kDebugMode) {
          print('Cart fetched successfully: ${_cartItems.length} items');
        }
      } else {
        _errorMessage.value = response.message ?? 'Failed to fetch cart';
        _cartItems.clear();
        _resetTotals();

        if (kDebugMode) {
          print('Cart fetch failed: ${response.message}');
        }
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred while fetching cart';
      _cartItems.clear();
      _resetTotals();

      if (kDebugMode) {
        print('Cart fetch error: $e');
      }
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  /// Add item to cart
  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    try {
      _isUpdating.value = true;
      _errorMessage.value = '';

      final response = await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      if (response.isSuccess && response.data != null) {
        _cartItems.value = response.data!.data;
        _calculateTotals();

        Get.snackbar(
          'Success',
          'Item added to cart successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (kDebugMode) {
          print('Item added to cart successfully');
        }
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to add item to cart';

        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );

        if (kDebugMode) {
          print('Add to cart failed: ${response.message}');
        }
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred while adding item to cart';

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (kDebugMode) {
        print('Add to cart error: $e');
      }
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItem(int productId, int quantity) async {
    try {
      _isUpdating.value = true;
      _errorMessage.value = '';

      final response = await _cartService.updateCartItem(
        productId: productId,
        quantity: quantity,
      );

      if (response.isSuccess && response.data != null) {
        _cartItems.value = response.data!.data;
        _calculateTotals();

        if (kDebugMode) {
          print('Cart item updated successfully');
        }
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to update cart item';

        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );

        if (kDebugMode) {
          print('Update cart failed: ${response.message}');
        }
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred while updating cart item';

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (kDebugMode) {
        print('Update cart error: $e');
      }
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int productId) async {
    try {
      _isUpdating.value = true;
      _errorMessage.value = '';

      final response = await _cartService.removeFromCart(productId: productId);

      if (response.isSuccess && response.data != null) {
        _cartItems.value = response.data!.data;
        _calculateTotals();

        Get.snackbar(
          'Success',
          'Item removed from cart',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (kDebugMode) {
          print('Item removed from cart successfully');
        }
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to remove item from cart';

        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );

        if (kDebugMode) {
          print('Remove from cart failed: ${response.message}');
        }
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred while removing item from cart';

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (kDebugMode) {
        print('Remove from cart error: $e');
      }
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  /// Increase item quantity
  // Future<void> increaseQuantity(CartItem item) async {
  //   final newQuantity = item.countInt + 1;
  //   await updateCartItem(item.id, newQuantity);
  // }
  //
  // /// Decrease item quantity
  // Future<void> decreaseQuantity(CartItem item) async {
  //   if (item.countInt! > 1) {
  //     final newQuantity = item.countInt - 1;
  //     await updateCartItem(item.id, newQuantity);
  //   } else {
  //     await removeFromCart(item.id);
  //   }
  // }

  /// Get specific cart item by product ID
  CartItem? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.id == productId);
  }

  /// Get quantity of specific product in cart
  int getProductQuantity(int productId) {
    final item = getCartItem(productId);
    return item?.countInt ?? 0;
  }

  /// Clear all error messages
  void clearError() {
    _errorMessage.value = '';
  }

  /// Clear cart (local only)
  void clearCart() {
    _cartItems.clear();
    _resetTotals();
  }

  /// Calculate totals
  void _calculateTotals() {
    _totalQuantity.value = _cartItems.fold(0, (sum, item) => sum + item.countInt);
    _totalAmount.value = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Reset totals
  void _resetTotals() {
    _totalQuantity.value = 0;
    _totalAmount.value = 0.0;
  }

  /// Refresh cart
  Future<void> refresh() async {
    await fetchCart(showLoading: false);
  }

  @override
  void onClose() {
    super.onClose();
  }
}