// Models/single_bill_model.dart
class SingleBillResponse {
  final String status;
  final String message;
  final SingleBillData? data;

  SingleBillResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SingleBillResponse.fromJson(Map<String, dynamic> json) {
    return SingleBillResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? json['msg']?.toString() ?? '',
      data: json['data'] != null ? SingleBillData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SingleBillData {
  final List<ProductDetail>? productDetails;
  final BillDetails? billDetails;

  SingleBillData({
    this.productDetails,
    this.billDetails,
  });

  factory SingleBillData.fromJson(Map<String, dynamic> json) {
    return SingleBillData(
      productDetails: json['product_details'] != null
          ? (json['product_details'] as List)
          .map((item) => ProductDetail.fromJson(item))
          .toList()
          : null,
      billDetails: json['bill_details'] != null
          ? BillDetails.fromJson(json['bill_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_details': productDetails?.map((item) => item.toJson()).toList(),
      'bill_details': billDetails?.toJson(),
    };
  }

  // Helper getters for easy access
  String get customerName => billDetails?.name ?? 'N/A';
  String get billNumber => billDetails?.billNo ?? 'N/A';
  String get phoneNumber => billDetails?.phone ?? 'N/A';
  String get address => billDetails?.place ?? 'N/A';
  double get totalAmount => _parseToDouble(billDetails?.totalAmd) ?? 0.0;
  double get paidAmount => _parseToDouble(billDetails?.paidAmd) ?? 0.0;
  double get finalTotal => _parseToDouble(billDetails?.finalTotal) ?? 0.0;
  String get paymentType => billDetails?.paymentType ?? 'N/A';
  String get staff => billDetails?.staff ?? 'N/A';
  int get totalQuantity => billDetails?.qty ?? 0;
  double get balance => _parseToDouble(billDetails?.balance) ?? 0.0;
  bool get isFullyPaid => balance <= 0;
  String get createdAt => billDetails?.createdAt ?? 'N/A';
  String get updatedAt => billDetails?.updatedAt ?? 'N/A';
}

class ProductDetail {
  final int? catId;
  final String? purchId;
  final String? catName;
  final String? proId;
  final String? proName;
  final String? qty;
  final String? per;
  final String? mrp;
  final String? discount;
  final String? measurement;
  final String? value;
  final String? total;
  final String? remark;
  final int? stockId;

  ProductDetail({
    this.catId,
    this.purchId,
    this.catName,
    this.proId,
    this.proName,
    this.qty,
    this.per,
    this.mrp,
    this.discount,
    this.measurement,
    this.value,
    this.total,
    this.remark,
    this.stockId,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      catId: _parseToInt(json['cat_id']),
      purchId: json['purch_id']?.toString(),
      catName: json['cat_name']?.toString(),
      proId: json['pro_id']?.toString(),
      proName: json['pro_name']?.toString(),
      qty: json['qty']?.toString(),
      per: json['per']?.toString(),
      mrp: json['mrp']?.toString(),
      discount: json['discount']?.toString(),
      measurement: json['measurement']?.toString(),
      value: json['value']?.toString(),
      total: json['total']?.toString(),
      remark: json['remark']?.toString(),
      stockId: _parseToInt(json['stock_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cat_id': catId,
      'purch_id': purchId,
      'cat_name': catName,
      'pro_id': proId,
      'pro_name': proName,
      'qty': qty,
      'per': per,
      'mrp': mrp,
      'discount': discount,
      'measurement': measurement,
      'value': value,
      'total': total,
      'remark': remark,
      'stock_id': stockId,
    };
  }

  // Helper getters for typed values
  double get quantityDouble => _parseToDouble(qty) ?? 0.0;
  double get priceDouble => _parseToDouble(per) ?? 0.0;
  double get mrpDouble => _parseToDouble(mrp) ?? 0.0;
  double get discountDouble => _parseToDouble(discount) ?? 0.0;
  double get totalDouble => _parseToDouble(total) ?? 0.0;
  String get formattedPrice => '₹${priceDouble.toStringAsFixed(2)}';
  String get formattedTotal => '₹${totalDouble.toStringAsFixed(2)}';
  String get formattedMrp => '₹${mrpDouble.toStringAsFixed(2)}';
}

class BillDetails {
  final int? id;
  final int? customerId;
  final String? purchaseId;
  final String? shopId;
  final String? billUserName;
  final String? counter;
  final String? billNo;
  final String? name;
  final String? email;
  final String? phone;
  final String? place;
  final String? address;
  final String? proDetailsJs;
  final int? qty;
  final int? perTotalAmd;
  final String? totalAmd;
  final String? paidAmd;
  final int? changeStatus;
  final String? receivedAmdAdvance;
  final int? tDiscount;
  final int? billDiscount;
  final String? finalTotal;
  final String? paymentType;
  final String? credits;
  final int? timestamp;
  final String? balance;
  final String? staff;
  final int? assignDelboyId;
  final String? assignDelboyStatus;
  final String? delComTime;
  final String? ledgerBalanceStore;
  final String? accountBalanceStore;
  final int? creditpoints;
  final int? delivaryHome;
  final String? createdAt;
  final String? updatedAt;

  BillDetails({
    this.id,
    this.customerId,
    this.purchaseId,
    this.shopId,
    this.billUserName,
    this.counter,
    this.billNo,
    this.name,
    this.email,
    this.phone,
    this.place,
    this.address,
    this.proDetailsJs,
    this.qty,
    this.perTotalAmd,
    this.totalAmd,
    this.paidAmd,
    this.changeStatus,
    this.receivedAmdAdvance,
    this.tDiscount,
    this.billDiscount,
    this.finalTotal,
    this.paymentType,
    this.credits,
    this.timestamp,
    this.balance,
    this.staff,
    this.assignDelboyId,
    this.assignDelboyStatus,
    this.delComTime,
    this.ledgerBalanceStore,
    this.accountBalanceStore,
    this.creditpoints,
    this.delivaryHome,
    this.createdAt,
    this.updatedAt,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      id: _parseToInt(json['id']),
      customerId: _parseToInt(json['customer_id']),
      purchaseId: json['purchase_id']?.toString(),
      shopId: json['shop_id']?.toString(),
      billUserName: json['bill_user_name']?.toString(),
      counter: json['counter']?.toString(),
      billNo: json['bill_no']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      place: json['place']?.toString(),
      address: json['address']?.toString(),
      proDetailsJs: json['pro_details_js']?.toString(),
      qty: _parseToInt(json['qty']),
      perTotalAmd: _parseToInt(json['per_total_amd']),
      totalAmd: json['total_amd']?.toString(),
      paidAmd: json['paid_amd']?.toString(),
      changeStatus: _parseToInt(json['change_status']),
      receivedAmdAdvance: json['received_amd_advance']?.toString(),
      tDiscount: _parseToInt(json['t_discount']),
      billDiscount: _parseToInt(json['bill_discount']),
      finalTotal: json['final_total']?.toString(),
      paymentType: json['payment_type']?.toString(),
      credits: json['credits']?.toString(),
      timestamp: _parseToInt(json['timestamp']),
      balance: json['balance']?.toString(),
      staff: json['staff']?.toString(),
      assignDelboyId: _parseToInt(json['assign_delboy_id']),
      assignDelboyStatus: json['assign_delboy_status']?.toString(),
      delComTime: json['del_com_time']?.toString(),
      ledgerBalanceStore: json['ledger_balance_store']?.toString(),
      accountBalanceStore: json['account_balance_store']?.toString(),
      creditpoints: _parseToInt(json['creditpoints']),
      delivaryHome: _parseToInt(json['delivary_home']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'purchase_id': purchaseId,
      'shop_id': shopId,
      'bill_user_name': billUserName,
      'counter': counter,
      'bill_no': billNo,
      'name': name,
      'email': email,
      'phone': phone,
      'place': place,
      'address': address,
      'pro_details_js': proDetailsJs,
      'qty': qty,
      'per_total_amd': perTotalAmd,
      'total_amd': totalAmd,
      'paid_amd': paidAmd,
      'change_status': changeStatus,
      'received_amd_advance': receivedAmdAdvance,
      't_discount': tDiscount,
      'bill_discount': billDiscount,
      'final_total': finalTotal,
      'payment_type': paymentType,
      'credits': credits,
      'timestamp': timestamp,
      'balance': balance,
      'staff': staff,
      'assign_delboy_id': assignDelboyId,
      'assign_delboy_status': assignDelboyStatus,
      'del_com_time': delComTime,
      'ledger_balance_store': ledgerBalanceStore,
      'account_balance_store': accountBalanceStore,
      'creditpoints': creditpoints,
      'delivary_home': delivaryHome,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to get formatted date from timestamp
  String get formattedDate {
    if (timestamp == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get formatted date time from timestamp
  String get formattedDateTime {
    if (timestamp == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to check if delivery is completed
  bool get isDeliveryCompleted => assignDelboyStatus?.toLowerCase() == 'completed';

  // Helper method to get payment status
  String get paymentStatus {
    final balanceAmount = _parseToDouble(balance) ?? 0.0;
    if (balanceAmount <= 0) {
      return 'Paid';
    } else {
      return 'Pending';
    }
  }
}

// Helper functions for safe parsing
int? _parseToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      try {
        return double.parse(value).toInt();
      } catch (e) {
        return null;
      }
    }
  }
  return null;
}

double? _parseToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}