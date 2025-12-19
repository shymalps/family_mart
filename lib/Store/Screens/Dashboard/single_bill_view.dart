import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/Single Controllers/single_bill_controller.dart';
import '../../Extras/styles.dart';

class SingleBillViewUI extends StatefulWidget {
  const SingleBillViewUI({super.key});

  @override
  State<SingleBillViewUI> createState() => _SingleBillViewUIState();
}

class _SingleBillViewUIState extends State<SingleBillViewUI> {

  @override
  void initState() {
    super.initState();
    final billId = Get.arguments;
    print('Bill ID in SingleBillView: $billId');
    Get.find<SingleBillController>().fetchSingleBill(billId!);
  }

  @override
  Widget build(BuildContext context) {
    final SingleBillController controller = Get.find<SingleBillController>();

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
              _buildTopBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.hasError.value) {
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
                            'Error loading bill',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final billId = Get.arguments as int?;
                              print('Bill ID in SingleBillView: $billId');
                              if (billId != null) {
                                controller.retryFetchBill(billId);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!controller.hasBillData) {
                    final billId = Get.arguments;
                    print('Bill ID in SingleBillView under no bill data: $billId');
                    return const Center(
                      child: Text('No bill data available'),
                    );
                  }

                  return _buildBillContent(controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillContent(SingleBillController controller) {
    // Calculate totals from product details
    double tMrp = 0;
    double itemDiscount = 0;

    for (final item in controller.productDetails) {
      final qty = item.quantityDouble;
      final mrp = item.mrpDouble;
      final per = item.priceDouble;

      tMrp += mrp * qty;
      itemDiscount += (mrp - per) * qty;
    }

    // Add bill discount if any
    final billDiscount = controller.billDetails?.billDiscount?.toDouble() ?? 0.0;
    final totalDiscount = itemDiscount + billDiscount;
    final gTotal = tMrp - totalDiscount;

    return RefreshIndicator(
      onRefresh: () async {
        final billId = Get.arguments as int?;
        if (billId != null) {
          await controller.refreshBillData(billId);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Store Header
                const Text(
                  'FAMILY MART',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'NH 47 - TEN SQUARE BUILDING',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Text(
                  '15/454AP, KORATTY',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Text(
                  'MOB : 9946098799',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Text(
                  'GSTIN : 32AKUPA1746P1ZT',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Text(
                  'EMAIL : familymart.koratty@gmail.com',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Bill Information
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Bill No. : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          controller.formattedBillNumber,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Text(
                        'Date : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        controller.formattedBillDate,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Customer Information
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Customer Name : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.customerName,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Text(
                      'Time : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      controller.formattedBillDateTime.split(' ').length > 1
                          ? controller.formattedBillDateTime.split(' ')[1]
                          : 'N/A',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Address : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.address,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Text(
                      'Phone : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      controller.phoneNumber,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // Separator
                const Text(
                  '---------------------------------------------------------------------------------------------------------------------',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Table Header
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'Sl. ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Items',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'Rate',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'MRP',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'Amount',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),

                const Text(
                  '--------------------------------------------------------------------------------------------------------------------',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Product Items
                for (int i = 0; i < controller.productDetails.length; i++)
                  _createProductEntry(
                    (i + 1).toString(),
                    controller.productDetails[i].proName ?? 'N/A',
                    controller.productDetails[i].per ?? '0',
                    controller.productDetails[i].mrp ?? '0',
                    controller.productDetails[i].qty ?? '0',
                    controller.productDetails[i].total ?? '0',
                  ),

                const Text(
                  '=============================================================',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Totals Section
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Total MRP : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatAmount(tMrp.toString()),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Text(
                      'Discount : ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      _formatAmount(totalDiscount.toString()),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // Grand Total
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Grand Total : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        controller.formattedFinalTotal,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Text(
                  '____________________________________________________________________',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),

                // Payment Information
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Expanded(
                      child: Text(
                        'Paid Amount : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      controller.formattedPaidAmount,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Acc Balance : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '₹${controller.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // Amount in Words
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Amount payable in words : ',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      _rupeesInWords(controller.finalTotal),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // Staff Information
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Billing Staff : ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        controller.staff,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Thank You Section
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Thank You',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Image.asset(
                          'assets/images/ic_hands.png',
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Text(
                        'Visit Again',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProductEntry(String slNo, String item, String rate, String mrp,
      String qty, String amt) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Text(
            slNo,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 90,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              item,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        Container(
          width: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Text(
            rate,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Text(
            mrp,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Text(
            amt,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value.toStringAsFixed(2);
    } catch (e) {
      return amount;
    }
  }

  String _rupeesInWords(double amount) {
    // Simplified version - you can implement a proper number-to-words converter
    if (amount == 0) return 'Zero Rupees Only';
    return '${amount.toStringAsFixed(2)} Rupees Only';
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bill View', style: AppTextStyles.heading1),
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
        ],
      ),
    );
  }
}