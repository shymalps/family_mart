// Models/bill_model.dart
class Bill {
  final int id;
  final String billNo;
  final String total;
  final String paymentType;
  final String date;
  final bool due;

  Bill({
    required this.id,
    required this.billNo,
    required this.total,
    required this.paymentType,
    required this.date,
    required this.due,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? 0,
      billNo: json['bill_no'] ?? '',
      total: json['total'] ?? '0',
      paymentType: json['payment_type'] ?? '',
      date: json['date'] ?? '',
      due: json['due'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_no': billNo,
      'total': total,
      'payment_type': paymentType,
      'date': date,
      'due': due,
    };
  }

  @override
  String toString() {
    return 'Bill{id: $id, billNo: $billNo, total: $total, paymentType: $paymentType, date: $date, due: $due}';
  }
}

class BillHistoryResponse {
  final List<Bill> bills;
  final int total;
  final double finalTotal;
  final double mrpTotal;
  final String billDiscount;
  final int limit;

  BillHistoryResponse({
    required this.bills,
    required this.total,
    required this.finalTotal,
    required this.mrpTotal,
    required this.billDiscount,
    required this.limit,
  });

  factory BillHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BillHistoryResponse(
      bills: (json['data'] as List<dynamic>?)
          ?.map((item) => Bill.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
      finalTotal: double.tryParse(json['final_total']?.toString() ?? '0') ?? 0.0,
      mrpTotal: double.tryParse(json['mrp_total']?.toString() ?? '0') ?? 0.0,
      billDiscount: json['bill_discount']?.toString() ?? '0',
      limit: json['limit'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': bills.map((bill) => bill.toJson()).toList(),
      'total': total,
      'final_total': finalTotal,
      'mrp_total': mrpTotal,
      'bill_discount': billDiscount,
      'limit': limit,
    };
  }
}

class BillDuesResponse {
  final List<Bill> duesBills;
  final int total;
  final int limit;

  BillDuesResponse({
    required this.duesBills,
    required this.total,
    required this.limit,
  });

  factory BillDuesResponse.fromJson(Map<String, dynamic> json) {
    return BillDuesResponse(
      duesBills: (json['data'] as List<dynamic>?)
          ?.map((item) => Bill.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': duesBills.map((bill) => bill.toJson()).toList(),
      'total': total,
      'limit': limit,
    };
  }
}

// Request models for better type safety
class BillHistoryRequest {
  final int userId;
  final int offset;
  final String? fromDate;
  final String? toDate;

  BillHistoryRequest({
    required this.userId,
    required this.offset,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'user_id': userId,
      'offset': offset,
    };

    if (fromDate != null && fromDate!.isNotEmpty) {
      json['f_date'] = fromDate;
    }

    if (toDate != null && toDate!.isNotEmpty) {
      json['t_date'] = toDate;
    }

    return json;
  }
}

class BillDuesRequest {
  final int userId;
  final int offset;

  BillDuesRequest({
    required this.userId,
    required this.offset,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'offset': offset,
    };
  }
}