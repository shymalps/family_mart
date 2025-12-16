import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../Extras/urls.dart';
import '../Models/product_description_model.dart';
import '../services/product_description_service.dart';

class ProductDescriptionController extends GetxController {
  // Service instance
  late ProductDescriptionService _productDescriptionService;

  // Observable variables
  final Rx<ProductDescriptionModel?> _productDescription = Rx<ProductDescriptionModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentProductId = 0.obs;

  // Cache to store fetched product descriptions
  final RxMap<int, ProductDescriptionModel> _productDescriptionCache = <int, ProductDescriptionModel>{}.obs;

  // Getters
  ProductDescriptionModel? get productDescription => _productDescription.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get currentProductId => _currentProductId.value;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  void _initializeService() {
    _productDescriptionService = ProductDescriptionService(
      baseURL: Constants.baseURL,
    );
  }

  /// Fetches product description by ID
  Future<void> fetchProductDescription(int productId) async {
    try {
      // Check cache first
      if (_productDescriptionCache.containsKey(productId)) {
        _productDescription.value = _productDescriptionCache[productId];
        _currentProductId.value = productId;
        _errorMessage.value = '';
        debugPrint('Product description loaded from cache for ID: $productId');
        return;
      }

      _isLoading.value = true;
      _errorMessage.value = '';
      _currentProductId.value = productId;

      final response = await _productDescriptionService.fetchProductDescription(
        productId: productId,
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Handle both single object and array responses
          dynamic productData = responseData['data'];

          if (productData is List && productData.isNotEmpty) {
            // If data is an array, take the first item
            productData = productData.first;
          }

          if (productData is Map<String, dynamic>) {
            final productDescriptionModel = ProductDescriptionModel.fromJson(productData);

            // Cache the product description
            _productDescriptionCache[productId] = productDescriptionModel;
            _productDescription.value = productDescriptionModel;

            debugPrint('Product description loaded successfully for ID: $productId');
          } else {
            _errorMessage.value = 'Invalid product data format';
            debugPrint('Invalid product data format for ID: $productId');
          }
        } else {
          _errorMessage.value = responseData['msg'] ?? 'Failed to load product description';
          debugPrint('API Error: ${responseData['msg']}');
        }
      } else {
        _errorMessage.value = response.message ?? 'Failed to load product description';
        debugPrint('API Error: ${response.message}');
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred: ${e.toString()}';
      debugPrint('Exception in fetchProductDescription: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Gets product description from cache if available
  ProductDescriptionModel? getCachedProductDescription(int productId) {
    return _productDescriptionCache[productId];
  }

  /// Checks if product description is cached
  bool isProductDescriptionCached(int productId) {
    return _productDescriptionCache.containsKey(productId);
  }

  /// Clears the cache
  void clearCache() {
    _productDescriptionCache.clear();
    debugPrint('Product description cache cleared');
  }

  /// Removes a specific product from cache
  void removeFromCache(int productId) {
    _productDescriptionCache.remove(productId);
    debugPrint('Product description removed from cache for ID: $productId');
  }

  /// Refreshes current product description
  Future<void> refreshCurrentProductDescription() async {
    if (_currentProductId.value > 0) {
      // Remove from cache to force refresh
      removeFromCache(_currentProductId.value);
      await fetchProductDescription(_currentProductId.value);
    }
  }

  /// Preloads product descriptions for multiple IDs
  Future<void> preloadProductDescriptions(List<int> productIds) async {
    final uncachedIds = productIds.where((id) => !_productDescriptionCache.containsKey(id)).toList();

    if (uncachedIds.isEmpty) return;

    for (final productId in uncachedIds) {
      try {
        await fetchProductDescription(productId);
      } catch (e) {
        debugPrint('Failed to preload product description for ID $productId: $e');
      }
    }
  }

  /// Gets formatted price with currency symbol
  String getFormattedPrice() {
    if (_productDescription.value == null) return '';

    final saleRate = _productDescription.value!.saleRate;
    final mrp = _productDescription.value!.mrp;

    if (saleRate != null && saleRate.isNotEmpty) {
      return '₹$saleRate';
    }

    return '₹$mrp';
  }

  /// Gets formatted MRP
  String getFormattedMRP() {
    if (_productDescription.value == null) return '';
    return '₹${_productDescription.value!.mrp}';
  }

  /// Checks if product is on sale
  bool get isOnSale {
    if (_productDescription.value == null) return false;

    final saleRate = _productDescription.value!.saleRate;
    return saleRate != null && saleRate.isNotEmpty;
  }

  /// Gets discount percentage
  double getDiscountPercentage() {
    if (!isOnSale) return 0.0;

    final mrp = double.tryParse(_productDescription.value!.mrp) ?? 0.0;
    final saleRate = double.tryParse(_productDescription.value!.saleRate ?? '0') ?? 0.0;

    if (mrp > 0 && saleRate > 0) {
      return ((mrp - saleRate) / mrp) * 100;
    }

    return 0.0;
  }

  /// Gets formatted measurement
  String getFormattedMeasurement() {
    if (_productDescription.value == null) return '';
    return '${_productDescription.value!.value} ${_productDescription.value!.measurement}';
  }

  /// Gets cache size
  int get cacheSize => _productDescriptionCache.length;

  /// Clears current product description
  void clearCurrentProductDescription() {
    _productDescription.value = null;
    _currentProductId.value = 0;
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    clearCache();
    super.onClose();
  }
}