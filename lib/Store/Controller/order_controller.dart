// Controller/order_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Models/order_model.dart';
import '../Services/order_service.dart';


class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  // Loading states
  final RxBool _isLoadingNewOrders = false.obs;
  final RxBool _isLoadingOldOrders = false.obs;
  final RxBool _isLoadingMoreNew = false.obs;
  final RxBool _isLoadingMoreOld = false.obs;
  final RxMap<String, bool> _loadingOrderDetails = <String, bool>{}.obs;

  // Data
  final RxList<Order> _newOrders = <Order>[].obs;
  final RxList<Order> _oldOrders = <Order>[].obs;
  final RxMap<String, List<OrderItem>> _orderDetailsCache = <String, List<OrderItem>>{}.obs;

  // Pagination
  final Rx<OrderPagination> _newOrdersPagination = OrderPagination().obs;
  final Rx<OrderPagination> _oldOrdersPagination = OrderPagination().obs;

  // Error handling
  final RxString _errorMessage = ''.obs;
  final RxString _newOrdersError = ''.obs;
  final RxString _oldOrdersError = ''.obs;

  // Filters and sorting
  final Rx<OrderSortBy> _sortBy = OrderSortBy.dateNewest.obs;
  final Rx<OrderFilterBy> _filterBy = OrderFilterBy.all.obs;
  final RxString _searchQuery = ''.obs;

  // Current tab
  final RxInt _currentTabIndex = 0.obs;

  // Getters
  bool get isLoadingNewOrders => _isLoadingNewOrders.value;
  bool get isLoadingOldOrders => _isLoadingOldOrders.value;
  bool get isLoadingMoreNew => _isLoadingMoreNew.value;
  bool get isLoadingMoreOld => _isLoadingMoreOld.value;

  List<Order> get newOrders => _newOrders;
  List<Order> get oldOrders => _oldOrders;
  List<Order> get filteredNewOrders => _getFilteredOrders(_newOrders);
  List<Order> get filteredOldOrders => _getFilteredOrders(_oldOrders);

  OrderPagination get newOrdersPagination => _newOrdersPagination.value;
  OrderPagination get oldOrdersPagination => _oldOrdersPagination.value;

  String get errorMessage => _errorMessage.value;
  String get newOrdersError => _newOrdersError.value;
  String get oldOrdersError => _oldOrdersError.value;

  OrderSortBy get sortBy => _sortBy.value;
  OrderFilterBy get filterBy => _filterBy.value;
  String get searchQuery => _searchQuery.value;

  int get currentTabIndex => _currentTabIndex.value;

  bool get hasNewOrders => _newOrders.isNotEmpty;
  bool get hasOldOrders => _oldOrders.isNotEmpty;
  bool get hasMoreNewOrders => _newOrdersPagination.value.hasMore;
  bool get hasMoreOldOrders => _oldOrdersPagination.value.hasMore;

  // Order details methods
  bool isLoadingOrderDetails(String orderId) => _loadingOrderDetails[orderId] ?? false;
  List<OrderItem>? getOrderDetails(String orderId) => _orderDetailsCache[orderId];
  bool hasOrderDetailsCache(String orderId) => _orderDetailsCache.containsKey(orderId);

  @override
  void onInit() {
    super.onInit();
    _initializeOrders();
  }

  void _initializeOrders() {
    // Load both new and old orders initially
    fetchNewOrders(isRefresh: true);
    fetchOldOrders(isRefresh: true);
  }

  /// Fetch new orders
  Future<void> fetchNewOrders({
    bool isRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && !hasMoreNewOrders) return;

      if (isRefresh) {
        _isLoadingNewOrders.value = true;
        _newOrdersError.value = '';
        _newOrdersPagination.value =const OrderPagination();
      } else if (loadMore) {
        _isLoadingMoreNew.value = true;
      }

      final offset = loadMore ? _newOrdersPagination.value.currentOffset : 0;

      final response = await _orderService.getNewOrders(offset: offset);

      if (response.success && response.data != null) {
        final orders = response.data!.data;

        if (isRefresh) {
          _newOrders.assignAll(orders);
        } else if (loadMore) {
          _newOrders.addAll(orders);
        }

        // Update pagination
        _newOrdersPagination.value = _newOrdersPagination.value.copyWith(
          currentOffset: offset + orders.length,
          hasMore: orders.length >= _newOrdersPagination.value.pageSize,
          totalCount: _newOrdersPagination.value.totalCount + orders.length,
        );

        _newOrdersError.value = '';
        _logSuccess('New Orders', 'Fetched ${orders.length} orders');
      } else {
        _newOrdersError.value = response.message!;
        _logError('New Orders Fetch Failed', response.message!);
      }
    } catch (e, stackTrace) {
      _newOrdersError.value = 'Failed to load new orders';
      _logError('New Orders Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isLoadingNewOrders.value = false;
      _isLoadingMoreNew.value = false;
    }
  }

  /// Fetch old orders
  Future<void> fetchOldOrders({
    bool isRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && !hasMoreOldOrders) return;

      if (isRefresh) {
        _isLoadingOldOrders.value = true;
        _oldOrdersError.value = '';
        _oldOrdersPagination.value = OrderPagination();
      } else if (loadMore) {
        _isLoadingMoreOld.value = true;
      }

      final offset = loadMore ? _oldOrdersPagination.value.currentOffset : 0;

      final response = await _orderService.getOldOrders(offset: offset);

      if (response.success && response.data != null) {
        final orders = response.data!.data;

        if (isRefresh) {
          _oldOrders.assignAll(orders);
        } else if (loadMore) {
          _oldOrders.addAll(orders);
        }

        // Update pagination
        _oldOrdersPagination.value = _oldOrdersPagination.value.copyWith(
          currentOffset: offset + orders.length,
          hasMore: orders.length >= _oldOrdersPagination.value.pageSize,
          totalCount: _oldOrdersPagination.value.totalCount + orders.length,
        );

        _oldOrdersError.value = '';
        _logSuccess('Old Orders', 'Fetched ${orders.length} orders');
      } else {
        _oldOrdersError.value = response.message!;
        _logError('Old Orders Fetch Failed', response.message!);
      }
    } catch (e, stackTrace) {
      _oldOrdersError.value = 'Failed to load old orders';
      _logError('Old Orders Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isLoadingOldOrders.value = false;
      _isLoadingMoreOld.value = false;
    }
  }

  /// Fetch order details for a specific order
  Future<void> fetchOrderDetails(String orderId) async {
    try {
      if (_loadingOrderDetails[orderId] == true) return;

      _loadingOrderDetails[orderId] = true;
      update();

      final response = await _orderService.getOrderDetails(orderId: orderId);

      if (response.success && response.data != null) {
        final orderItems = response.data!.data.items; // ✅ use .items
        _orderDetailsCache[orderId] = orderItems;
        _logSuccess('Order Details', 'Fetched ${orderItems.length} items for order $orderId');
      } else {
        _errorMessage.value = response.message!;
        _logError('Order Details Fetch Failed', response.message!);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Failed to load order details';
      _logError('Order Details Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _loadingOrderDetails.remove(orderId);
      update();
    }
  }


  /// Refresh both new and old orders
  Future<void> refreshAllOrders() async {
    await Future.wait([
      fetchNewOrders(isRefresh: true),
      fetchOldOrders(isRefresh: true),
    ]);
  }

  /// Load more orders based on current tab
  Future<void> loadMoreOrders() async {
    if (_currentTabIndex.value == 0) {
      await fetchNewOrders(loadMore: true);
    } else {
      await fetchOldOrders(loadMore: true);
    }
  }

  /// Set current tab index
  void setCurrentTab(int index) {
    _currentTabIndex.value = index;
  }

  /// Set sort option
  void setSortBy(OrderSortBy sortBy) {
    _sortBy.value = sortBy;
    _sortOrders();
  }

  /// Set filter option
  void setFilterBy(OrderFilterBy filterBy) {
    _filterBy.value = filterBy;
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery.value = '';
  }

  /// Toggle order expansion state
  void toggleOrderExpansion(Order order) {
    final index = _newOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _newOrders[index] = order.copyWith(isExpanded: !order.isExpanded);
      _newOrders.refresh();
      return;
    }

    final oldIndex = _oldOrders.indexWhere((o) => o.id == order.id);
    if (oldIndex != -1) {
      _oldOrders[oldIndex] = order.copyWith(isExpanded: !order.isExpanded);
      _oldOrders.refresh();
    }
  }

  /// Clear all cached order details
  void clearOrderDetailsCache() {
    _orderDetailsCache.clear();
  }

  /// Clear order details for a specific order
  void clearOrderDetails(String orderId) {
    _orderDetailsCache.remove(orderId);
  }

  /// Get filtered orders based on current filter and search
  List<Order> _getFilteredOrders(List<Order> orders) {
    List<Order> filteredOrders = List.from(orders);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filteredOrders = filteredOrders.where((order) {
        return order.id.toLowerCase().contains(query) ||
            (order.customerName?.toLowerCase() ?? '').contains(query) ||
            (order.customerPhone?.toLowerCase() ?? '').contains(query);
      }).toList();
    }

    // Apply amount filter
    switch (_filterBy.value) {
      case OrderFilterBy.withAmount:
        filteredOrders = filteredOrders.where((order) => order.hasAmount).toList();
        break;
      case OrderFilterBy.withoutAmount:
        filteredOrders = filteredOrders.where((order) => !order.hasAmount).toList();
        break;
      case OrderFilterBy.lastWeek:
      // Implement date filtering logic here
        break;
      case OrderFilterBy.lastMonth:
      // Implement date filtering logic here
        break;
      case OrderFilterBy.lastThreeMonths:
      // Implement date filtering logic here
        break;
      case OrderFilterBy.all:
      default:
        break;
    }

    // Apply sorting
    _sortOrdersList(filteredOrders);

    return filteredOrders;
  }

  /// Sort the orders list based on current sort option
  void _sortOrdersList(List<Order> orders) {
    switch (_sortBy.value) {
      case OrderSortBy.dateNewest:
        orders.sort((a, b) => (b.orderDate ?? '').compareTo(a.orderDate ?? ''));
        break;
      case OrderSortBy.dateOldest:
        orders.sort((a, b) => (a.orderDate ?? '').compareTo(b.orderDate ?? ''));
        break;
      case OrderSortBy.amountHighest:
        orders.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case OrderSortBy.amountLowest:
        orders.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case OrderSortBy.itemsCount:
        orders.sort((a, b) => b.count.compareTo(a.count));
        break;
    }
  }

  /// Sort both new and old orders
  void _sortOrders() {
    _sortOrdersList(_newOrders);
    _sortOrdersList(_oldOrders);
    _newOrders.refresh();
    _oldOrders.refresh();
  }

  /// Clear all errors
  void clearErrors() {
    _errorMessage.value = '';
    _newOrdersError.value = '';
    _oldOrdersError.value = '';
  }

  /// Clear all data and reload
  void reset() {
    _newOrders.clear();
    _oldOrders.clear();
    _orderDetailsCache.clear();
    _newOrdersPagination.value = OrderPagination();
    _oldOrdersPagination.value = OrderPagination();
    clearErrors();
    _initializeOrders();
  }

  // Logging methods
  void _logSuccess(String type, String message) {
    if (kDebugMode) {
      debugPrint('✅ $type: $message');
    }
  }

  void _logError(String type, String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $type');
      debugPrint('   Message: $message');
      if (stackTrace != null) {
        debugPrint('   StackTrace: $stackTrace');
      }
    }
  }

  @override
  void onClose() {
    _orderDetailsCache.clear();
    super.onClose();
  }
}