import 'package:family_mart/Store/Extras/approutes/route_name.dart';
import 'package:family_mart/Store/Widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/bill_controller.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/styles.dart';

import '../../Models/bill_model.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late final BillController billController;
  final RxString selectedFilter = 'All'.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    billController = Get.find<BillController>();
  }

  List<Bill> get filteredBills {
    List<Bill> allBills = [];

    // Combine history and dues based on filter
    switch (selectedFilter.value) {
      case 'Paid':
        allBills =
            billController.billHistory.where((bill) => !bill.due).toList();
        break;
      case 'Due':
        allBills = billController.billDues.toList();
        break;
      case 'All':
      default:
        allBills = [...billController.billHistory, ...billController.billDues];
        break;
    }

    // Apply date filter if both dates are selected
    if (fromDate.value != null && toDate.value != null) {
      allBills = allBills.where((bill) {
        try {
          final parts = bill.date.split('-');
          final billDate = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          return billDate
                  .isAfter(fromDate.value!.subtract(const Duration(days: 1))) &&
              billDate.isBefore(toDate.value!.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return allBills;
  }

  void _handleDateFilter() {
    if (fromDate.value != null && toDate.value != null) {
      String fromDateStr = _formatDateForAPI(fromDate.value!);
      String toDateStr = _formatDateForAPI(toDate.value!);
      billController.filterBillHistoryByDate(fromDateStr, toDateStr);
    }
  }

  String _formatDateForAPI(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => billController.refreshAll(),
            color: AppColors.primary,
            child: Column(
              children: [
                AnimatedWrapper(index: 0, child: _buildTopBar()),
                AnimatedWrapper(index: 1, child: _buildCompactFilters()),
                Expanded(
                    child: AnimatedWrapper(index: 2, child: _buildBillsList())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
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
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Bills', style: AppTextStyles.heading1),
                    const SizedBox(width: 8),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${billController.totalBills}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Date Filter Row
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: _buildDateButton('From', fromDate)),
              const SizedBox(width: 8),
              Expanded(child: _buildDateButton('To', toDate)),
              const SizedBox(width: 8),
              _buildQuickActionButton(Icons.clear_rounded, Colors.red, () {
                fromDate.value = null;
                toDate.value = null;
                billController.clearDateFilters();
              }),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Row
          Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Row(
                      children: [
                        _buildCompactFilterChip(
                            'All', selectedFilter.value == 'All'),
                        const SizedBox(width: 8),
                        _buildCompactFilterChip(
                            'Paid', selectedFilter.value == 'Paid'),
                       
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, Rx<DateTime?> dateValue) {
    return Obx(() => GestureDetector(
          onTap: () => _selectDate(dateValue),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dateValue.value != null
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: dateValue.value != null
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.grey.withOpacity(0.3)),
            ),
            child: Text(
              dateValue.value != null ? _formatDate(dateValue.value!) : label,
              style: AppTextStyles.caption.copyWith(
                color: dateValue.value != null
                    ? AppColors.primary
                    : AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  Widget _buildQuickActionButton(
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildCompactFilterChip(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectedFilter.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.white : AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(Rx<DateTime?> dateValue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateValue.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateValue.value = picked;
      _handleDateFilter();
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  Widget _buildBillsList() {
    return Obx(() {
      final bool isLoading = billController.isBillHistoryLoading ||
          billController.isBillDuesLoading;
      final bool hasError =
          billController.hasBillHistoryError || billController.hasBillDuesError;
      final String errorMessage = billController.hasBillHistoryError
          ? billController.billHistoryError
          : billController.billDuesError;

      if (isLoading && filteredBills.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Center(child: SmallLoadingSpinner()),
        );
      }

      if (hasError && filteredBills.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Error loading bills',
                  style: AppTextStyles.heading2.copyWith(color: Colors.red)),
              const SizedBox(height: 8),
              Text(errorMessage,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.grey.withOpacity(0.7)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => billController.refreshAll(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (filteredBills.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 64, color: AppColors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No bills found',
                  style:
                      AppTextStyles.heading2.copyWith(color: AppColors.grey)),
              const SizedBox(height: 8),
              Text('Try changing the filter or refresh the page',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.grey.withOpacity(0.7)),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              // Load more based on current filter
              if (selectedFilter.value == 'Due') {
                billController.loadMoreBillDues();
              } else {
                billController.loadMoreBillHistory();
              }
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            itemCount: filteredBills.length +
                (billController.isLoadingMoreBillHistory ||
                        billController.isLoadingMoreBillDues
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index >= filteredBills.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: SmallLoadingSpinner()),
                );
              }
              return _buildBillCard(filteredBills[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildBillCard(Bill bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Bill #${bill.billNo}',
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: bill.due
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(bill.due ? 'DUE' : 'PAID',
                              style: AppTextStyles.caption.copyWith(
                                  color: bill.due ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(bill.date,
                            style: AppTextStyles.heading2),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${_formatAmount(double.parse(bill.total))}',
                      style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: bill.due ? Colors.red : AppColors.primary)),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPaymentTypeColor(bill.paymentType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getPaymentTypeIcon(bill.paymentType),
                            size: 10,
                            color: _getPaymentTypeColor(bill.paymentType)),
                        const SizedBox(width: 3),
                        Text(bill.paymentType,
                            style: AppTextStyles.caption.copyWith(
                                color: _getPaymentTypeColor(bill.paymentType),
                                fontWeight: FontWeight.w600,
                                fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print(bill.id);
                    print('navigating to single bill view');
                    Get.toNamed(RouteName.singlebillview, arguments: bill.id);
                  },
                  child: Container(
                    // onTap: () => _showBillDetails(bill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('View Details',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Color _getPaymentTypeColor(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'upi':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPaymentTypeIcon(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'upi':
        return Icons.qr_code_rounded;
      default:
        return Icons.payment_rounded;
    }
  }


  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }
}
