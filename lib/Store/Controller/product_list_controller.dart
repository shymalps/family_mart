import 'package:family_mart/Store/services/category_services.dart';
import 'package:family_mart/Store/services/profile_service.dart';
import 'package:family_mart/Store/services/update_profile_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../Extras/urls.dart';
import '../Models/product_list_model.dart';
import '../services/product_service.dart';

enum ProductFetchType { all, category, shop }

class ProductController extends GetxController {
  // Service instance
  late ProductService _productService;
  final categoryServices = Get.put(CategoryService());
  final profileService = Get.put(ProfileService());
  final profileserviceUpdate= Get.put(ProfileServiceUpdate());

  // Observable variables
  final RxList<Product> _products = <Product>[].obs;
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedShopId = ''.obs;
  final RxString _selectedCategoryId = ''.obs;

  // Pagination variables
  final RxInt _currentOffset = 0.obs;
  final RxBool _hasMoreData = true.obs;
  final int _fixedLimit = 20;

  // Current fetch type to track what we're displaying
  final Rx<ProductFetchType> _currentFetchType = ProductFetchType.all.obs;

  // User ID - you should get this from your auth service or user preferences
  final String _userId = "0"; // Replace with actual user ID

  // Getters
  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  bool get hasMoreData => _hasMoreData.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  ProductFetchType get currentFetchType => _currentFetchType.value;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    fetchProducts();
  }

  void _initializeService() {
    _productService = ProductService(baseURL: Constants.baseURL);
  }

  /// Generic method to fetch products based on type
  Future<void> _fetchProductsGeneric({
    bool isRefresh = false,
    String? shopId,
    String? categoryId,
    ProductFetchType fetchType = ProductFetchType.all,
  }) async {
    try {
      // Set loading states
      if (isRefresh) {
        _isLoading.value = true;
        _currentOffset.value = 0;
        _products.clear();
        _filteredProducts.clear();
        _hasMoreData.value = true;
        _currentFetchType.value = fetchType;
      } else {
        _isLoadingMore.value = true;
      }

      _errorMessage.value = '';

      // Update filters if provided
      if (shopId != null) {
        _selectedShopId.value = shopId;
      }
      if (categoryId != null) {
        _selectedCategoryId.value = categoryId;
      }

      // Choose the appropriate API call based on fetch type
      ApiResponse<Map<String, dynamic>> response;

      switch (fetchType) {
        case ProductFetchType.category:
          response = await _productService.fetchCategoryProducts(
            userId: _userId,
            categoryId: _selectedCategoryId.value,
            offset: _currentOffset.value,
            limit: _fixedLimit,
          );
          break;
        case ProductFetchType.shop:
        case ProductFetchType.all:
        default:
          response = await _productService.fetchProducts(
            userId: _userId,
            offset: _currentOffset.value,
            limit: _fixedLimit,
            shopId: _selectedShopId.value.isEmpty
                ? null
                : _selectedShopId.value,
          );
          break;
      }

      if (response.success && response.data != null) {
        final productListResponse = ProductListResponse.fromJson(
          response.data!,
        );

        if (productListResponse.status == 'success') {
          final newProducts = productListResponse.data;
          final receivedCount = newProducts.length;

          // Add new products to list
          if (isRefresh) {
            _products.assignAll(newProducts);
          } else {
            _products.addAll(newProducts);
          }

          // Update offset for next page
          _currentOffset.value += _fixedLimit;

          // Check if there's more data
          _hasMoreData.value = receivedCount == _fixedLimit;

          // Update filtered products if no active search
          if (_searchQuery.value.isEmpty) {
            _filteredProducts.assignAll(_products);
          }

          debugPrint('Products loaded: ${_products.length} (Type: $fetchType)');
        } else {
          _errorMessage.value = productListResponse.message.isNotEmpty
              ? productListResponse.message
              : 'Failed to load products';
          _hasMoreData.value = false;
          debugPrint('API Error: ${productListResponse.message}');
        }
      } else {
        _errorMessage.value = response.message ?? 'Failed to load products';
        _hasMoreData.value = false;
        debugPrint('API Error: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred: ${e.toString()}';
      _hasMoreData.value = false;
      debugPrint('Exception in _fetchProductsGeneric: $e');
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  /// Fetches all products with pagination
  Future<void> fetchProducts({bool isRefresh = false, String? shopId}) async {
    await _fetchProductsGeneric(
      isRefresh: isRefresh,
      shopId: shopId,
      fetchType: shopId != null ? ProductFetchType.shop : ProductFetchType.all,
    );
  }

  /// Fetches products by category with pagination
  Future<void> fetchCategoryProducts({
    required String categoryId,
    bool isRefresh = false,
  }) async {
    await _fetchProductsGeneric(
      isRefresh: isRefresh,
      categoryId: categoryId,
      fetchType: ProductFetchType.category,
    );
  }

  /// Loads more products (for pagination) based on current fetch type
  Future<void> loadMoreProducts() async {
    debugPrint('Loading more products... hasMoreData: ${_hasMoreData.value}');
    if (!_hasMoreData.value || _isLoadingMore.value) return;

    switch (_currentFetchType.value) {
      case ProductFetchType.category:
        await _fetchProductsGeneric(
          categoryId: _selectedCategoryId.value,
          fetchType: ProductFetchType.category,
        );
        break;
      case ProductFetchType.shop:
        await _fetchProductsGeneric(
          shopId: _selectedShopId.value,
          fetchType: ProductFetchType.shop,
        );
        break;
      case ProductFetchType.all:
      default:
        await _fetchProductsGeneric();
        break;
    }
  }

  /// Searches products with debouncing
  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      // If search is cleared, show all products
      _filteredProducts.assignAll(_products);
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _productService.searchProducts(
        query: query,
        userId: _userId,
      );

      if (response.success && response.data != null) {
        final productListResponse = ProductListResponse.fromJson(
          response.data!,
        );

        if (productListResponse.status == 'success' ||
            productListResponse.status == '1') {
          final searchResults = productListResponse.data;
          _filteredProducts.assignAll(searchResults);

          debugPrint('Search results: ${searchResults.length} products found');
        } else {
          _errorMessage.value = productListResponse.message.isNotEmpty
              ? productListResponse.message
              : 'Search failed';
          _filteredProducts.clear();
        }
      } else {
        _errorMessage.value = response.message ?? 'Search failed';
        _filteredProducts.clear();
      }
    } catch (e) {
      _errorMessage.value = 'Search error: ${e.toString()}';
      _filteredProducts.clear();
      debugPrint('Exception in searchProducts: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refreshes the current product list based on current fetch type
  Future<void> refreshProducts() async {
    switch (_currentFetchType.value) {
      case ProductFetchType.category:
        await fetchCategoryProducts(
          categoryId: _selectedCategoryId.value,
          isRefresh: true,
        );
        break;
      case ProductFetchType.shop:
        await fetchProducts(isRefresh: true, shopId: _selectedShopId.value);
        break;
      case ProductFetchType.all:
      default:
        await fetchProducts(isRefresh: true);
        break;
    }
  }

  /// Filters products by shop
  Future<void> filterByShop(String shopId) async {
    await fetchProducts(isRefresh: true, shopId: shopId);
  }

  /// Filters products by category
  Future<void> filterByCategory(String categoryId) async {
    await fetchCategoryProducts(categoryId: categoryId, isRefresh: true);
  }

  /// Clears all filters and shows all products
  Future<void> clearAllFilters() async {
    _selectedShopId.value = '';
    _selectedCategoryId.value = '';
    _searchQuery.value = '';
    await fetchProducts(isRefresh: true);
  }

  /// Clears search and shows current filtered products
  void clearSearch() {
    _searchQuery.value = '';
    _filteredProducts.assignAll(_products);
  }

  /// Gets a product by ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Checks if we're on the last page
  bool get isLastPage => !_hasMoreData.value;

  /// Gets products that are on sale
  List<Product> get productsOnSale =>
      _filteredProducts.where((product) => product.isOnSale).toList();

  /// Gets products by measurement type
  List<Product> getProductsByMeasurement(String measurement) {
    return _filteredProducts
        .where((product) => product.measurement == measurement)
        .toList();
  }

  /// Updates cart count for a specific product
  void updateProductCartCount(int productId, int newCount) {
    final productIndex = _products.indexWhere(
      (product) => product.id == productId,
    );
    if (productIndex != -1) {
      final updatedProduct = Product(
        id: _products[productIndex].id,
        name: _products[productIndex].name,
        subName: _products[productIndex].subName,
        amount: _products[productIndex].amount,
        mrp: _products[productIndex].mrp,
        saleRate: _products[productIndex].saleRate,
        fileName: _products[productIndex].fileName,
        measurement: _products[productIndex].measurement,
        value: _products[productIndex].value,
        cartCount: newCount,
      );

      _products[productIndex] = updatedProduct;

      final filteredIndex = _filteredProducts.indexWhere(
        (product) => product.id == productId,
      );
      if (filteredIndex != -1) {
        _filteredProducts[filteredIndex] = updatedProduct;
      }
    }
  }

  /// Helper method to check if currently showing category products
  bool get isShowingCategoryProducts =>
      _currentFetchType.value == ProductFetchType.category;

  /// Helper method to check if currently showing shop products
  bool get isShowingShopProducts =>
      _currentFetchType.value == ProductFetchType.shop;

  /// Get current filter status as a readable string
  String get currentFilterStatus {
    switch (_currentFetchType.value) {
      case ProductFetchType.category:
        return 'Category: $_selectedCategoryId';
      case ProductFetchType.shop:
        return 'Shop: $_selectedShopId';
      case ProductFetchType.all:
      default:
        return 'All Products';
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
