// Controllers/bill_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Models/bill_model.dart';
import '../services/bill_services.dart';


class BillController extends GetxController {
  final BillService _billService = Get.find<BillService>();

  // Observable variables for bill history
  final RxList<Bill> _billHistory = <Bill>[].obs;
  final RxBool _isBillHistoryLoading = false.obs;
  final RxString _billHistoryError = ''.obs;
  final RxBool _hasBillHistoryError = false.obs;

  // Observable variables for bill dues
  final RxList<Bill> _billDues = <Bill>[].obs;
  final RxBool _isBillDuesLoading = false.obs;
  final RxString _billDuesError = ''.obs;
  final RxBool _hasBillDuesError = false.obs;

  // Pagination variables for bill history
  final RxInt _billHistoryOffset = 0.obs;
  final RxBool _hasMoreBillHistory = true.obs;
  final RxBool _isLoadingMoreBillHistory = false.obs;

  // Pagination variables for bill dues
  final RxInt _billDuesOffset = 0.obs;
  final RxBool _hasMoreBillDues = true.obs;
  final RxBool _isLoadingMoreBillDues = false.obs;

  // Additional bill history data
  final RxInt _totalBills = 0.obs;
  final RxDouble _finalTotal = 0.0.obs;
  final RxDouble _mrpTotal = 0.0.obs;
  final RxString _billDiscount = '0'.obs;
  final RxInt _limit = 20.obs;

  // Date filter variables
  final RxString _fromDate = ''.obs;
  final RxString _toDate = ''.obs;

  // Getters for bill history
  List<Bill> get billHistory => _billHistory;
  bool get isBillHistoryLoading => _isBillHistoryLoading.value;
  String get billHistoryError => _billHistoryError.value;
  bool get hasBillHistoryError => _hasBillHistoryError.value;
  bool get hasMoreBillHistory => _hasMoreBillHistory.value;
  bool get isLoadingMoreBillHistory => _isLoadingMoreBillHistory.value;

  // Getters for bill dues
  List<Bill> get billDues => _billDues;
  bool get isBillDuesLoading => _isBillDuesLoading.value;
  String get billDuesError => _billDuesError.value;
  bool get hasBillDuesError => _hasBillDuesError.value;
  bool get hasMoreBillDues => _hasMoreBillDues.value;
  bool get isLoadingMoreBillDues => _isLoadingMoreBillDues.value;

  // Getters for additional data
  int get totalBills => _totalBills.value;
  double get finalTotal => _finalTotal.value;
  double get mrpTotal => _mrpTotal.value;
  String get billDiscount => _billDiscount.value;
  int get limit => _limit.value;

  // Getters for date filters
  String get fromDate => _fromDate.value;
  String get toDate => _toDate.value;

  @override
  void onInit() {
    super.onInit();
    getBillHistory();
    getBillDues();
  }

  /// Get bill history with optional date range
  Future<void> getBillHistory({
    bool refresh = false,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      if (refresh) {
        _billHistoryOffset.value = 0;
        _hasMoreBillHistory.value = true;
        _billHistory.clear();
      }

      _isBillHistoryLoading.value = true;
      _hasBillHistoryError.value = false;
      _billHistoryError.value = '';

      // Update date filters if provided
      if (fromDate != null) _fromDate.value = fromDate;
      if (toDate != null) _toDate.value = toDate;

      final response = await _billService.getBillHistory(
        offset: _billHistoryOffset.value,
        fromDate: _fromDate.value.isEmpty ? null : _fromDate.value,
        toDate: _toDate.value.isEmpty ? null : _toDate.value,
      );

      if (response.success && response.data != null) {
        final billHistoryResponse = response.data!;

        if (refresh || _billHistoryOffset.value == 0) {
          _billHistory.value = billHistoryResponse.bills;
        } else {
          _billHistory.addAll(billHistoryResponse.bills);
        }

        // Update additional data
        _totalBills.value = billHistoryResponse.total;
        _finalTotal.value = billHistoryResponse.finalTotal;
        _mrpTotal.value = billHistoryResponse.mrpTotal;
        _billDiscount.value = billHistoryResponse.billDiscount;
        _limit.value = billHistoryResponse.limit;

        // Check if there are more items to load
        _hasMoreBillHistory.value = billHistoryResponse.bills.length >= billHistoryResponse.limit;

        _logSuccess('Bill History', 'Loaded ${billHistoryResponse.bills.length} bills');
      } else {
        _hasBillHistoryError.value = true;
        _billHistoryError.value = response.message ?? 'Failed to load bill history';
        _logError('Bill History Error', _billHistoryError.value);
      }
    } catch (e, stackTrace) {
      _hasBillHistoryError.value = true;
      _billHistoryError.value = 'An unexpected error occurred';
      _logError('Bill History Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isBillHistoryLoading.value = false;
    }
  }

  /// Load more bill history items (pagination)
  Future<void> loadMoreBillHistory() async {
    if (_isLoadingMoreBillHistory.value || !_hasMoreBillHistory.value) return;

    try {
      _isLoadingMoreBillHistory.value = true;
      _billHistoryOffset.value += _limit.value;

      final response = await _billService.getBillHistory(
        offset: _billHistoryOffset.value,
        fromDate: _fromDate.value.isEmpty ? null : _fromDate.value,
        toDate: _toDate.value.isEmpty ? null : _toDate.value,
      );

      if (response.success && response.data != null) {
        final billHistoryResponse = response.data!;

        if (billHistoryResponse.bills.isNotEmpty) {
          _billHistory.addAll(billHistoryResponse.bills);
          _hasMoreBillHistory.value = billHistoryResponse.bills.length >= billHistoryResponse.limit;
        } else {
          _hasMoreBillHistory.value = false;
        }

        _logSuccess('Load More Bill History', 'Loaded ${billHistoryResponse.bills.length} more bills');
      } else {
        // Revert offset on failure
        _billHistoryOffset.value -= _limit.value;
        _logError('Load More Bill History Error', response.message ?? 'Failed to load more bills');
      }
    } catch (e, stackTrace) {
      // Revert offset on exception
      _billHistoryOffset.value -= _limit.value;
      _logError('Load More Bill History Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isLoadingMoreBillHistory.value = false;
    }
  }

  /// Get bill dues
  Future<void> getBillDues({bool refresh = false}) async {
    try {
      if (refresh) {
        _billDuesOffset.value = 0;
        _hasMoreBillDues.value = true;
        _billDues.clear();
      }

      _isBillDuesLoading.value = true;
      _hasBillDuesError.value = false;
      _billDuesError.value = '';

      final response = await _billService.getBillDues(
        offset: _billDuesOffset.value,
      );

      if (response.success && response.data != null) {
        final billDuesResponse = response.data!;

        if (refresh || _billDuesOffset.value == 0) {
          _billDues.value = billDuesResponse.duesBills;
        } else {
          _billDues.addAll(billDuesResponse.duesBills);
        }

        // Check if there are more items to load
        _hasMoreBillDues.value = billDuesResponse.duesBills.length >= billDuesResponse.limit;

        _logSuccess('Bill Dues', 'Loaded ${billDuesResponse.duesBills.length} due bills');
      } else {
        _hasBillDuesError.value = true;
        _billDuesError.value = response.message ?? 'Failed to load bill dues';
        _logError('Bill Dues Error', _billDuesError.value);
      }
    } catch (e, stackTrace) {
      _hasBillDuesError.value = true;
      _billDuesError.value = 'An unexpected error occurred';
      _logError('Bill Dues Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isBillDuesLoading.value = false;
    }
  }

  /// Load more bill dues items (pagination)
  Future<void> loadMoreBillDues() async {
    if (_isLoadingMoreBillDues.value || !_hasMoreBillDues.value) return;

    try {
      _isLoadingMoreBillDues.value = true;
      _billDuesOffset.value += 20; // Default limit for dues

      final response = await _billService.getBillDues(
        offset: _billDuesOffset.value,
      );

      if (response.success && response.data != null) {
        final billDuesResponse = response.data!;

        if (billDuesResponse.duesBills.isNotEmpty) {
          _billDues.addAll(billDuesResponse.duesBills);
          _hasMoreBillDues.value = billDuesResponse.duesBills.length >= billDuesResponse.limit;
        } else {
          _hasMoreBillDues.value = false;
        }

        _logSuccess('Load More Bill Dues', 'Loaded ${billDuesResponse.duesBills.length} more due bills');
      } else {
        // Revert offset on failure
        _billDuesOffset.value -= 20;
        _logError('Load More Bill Dues Error', response.message ?? 'Failed to load more due bills');
      }
    } catch (e, stackTrace) {
      // Revert offset on exception
      _billDuesOffset.value -= 20;
      _logError('Load More Bill Dues Exception', e.toString(), stackTrace: stackTrace);
    } finally {
      _isLoadingMoreBillDues.value = false;
    }
  }

  /// Refresh both bill history and dues
  Future<void> refreshAll() async {
    await Future.wait([
      getBillHistory(refresh: true),
      getBillDues(refresh: true),
    ]);
  }

  /// Filter bill history by date range
  void filterBillHistoryByDate(String? fromDate, String? toDate) {
    _fromDate.value = fromDate ?? '';
    _toDate.value = toDate ?? '';
    getBillHistory(refresh: true, fromDate: fromDate, toDate: toDate);
  }

  /// Clear date filters
  void clearDateFilters() {
    _fromDate.value = '';
    _toDate.value = '';
    getBillHistory(refresh: true);
  }

  /// Get total due amount
  double get totalDueAmount {
    return _billDues.fold(0.0, (sum, bill) => sum + (double.tryParse(bill.total) ?? 0.0));
  }

  /// Get count of due bills
  int get duesBillsCount => _billDues.length;

  /// Get count of paid bills
  int get paidBillsCount => _billHistory.where((bill) => !bill.due).length;

  // Logging methods
  void _logSuccess(String operation, String message) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ SUCCESS: $operation');
      debugPrint('│ Message: $message');
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  void _logError(String operation, String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ ERROR: $operation');
      debugPrint('│ Message: $message');
      if (stackTrace != null) {
        debugPrint('│ StackTrace: $stackTrace');
      }
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }
}