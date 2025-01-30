// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Invoice {
//   final String invoiceId;
//   final String customerId;
//
//   final double amount;
//   final String description;
//   final List<dynamic> products;
//
//   Invoice({
//     required this.invoiceId,
//     required this.customerId,
//
//     required this.amount,
//     required this.description,
//     required this.products,
//   });
//
//   factory Invoice.fromMap(Map<String, dynamic> map) {
//     return Invoice(
//       invoiceId: map['invoiceId'],
//       customerId: map['customerId'],
//
//       amount: map['amount'],
//       description: map['description'],
//       products: map['products'],
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'invoiceId': invoiceId,
//       'customerId': customerId,
//
//       'amount': amount,
//       'description': description,
//       'products': products,
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
class Invoice {
  final String id;
  final String customerId;
  final String invoiceNumber;
  final Timestamp date;
  final Timestamp dueDate;
  final double amount;
  final double profit;
  final String status;
  final String approved;
  final String sellerName;
  final String paymentType;
  final List<dynamic>  products;

  Invoice({
    required this.id,
    required this.customerId,
    required this.invoiceNumber,
    required this.date,
    required this.approved,
    required this.dueDate,
    required this.amount,
    required this.profit,
    required this.status,
    required this.sellerName,
    required this.paymentType,
    required this.products,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['invoiceId']!,
      customerId: map['customerId'],
      invoiceNumber: map['invoiceNumber'],
      date: map['date'],
      profit: map['profit'],
      approved: map['approved'],
      dueDate: map['dueDate'],
      amount:map['amount'],
      status: map['status'],
      sellerName: '',
      paymentType: map['paymentType'],
      products: map['products'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': id,
      'customerId': customerId,
      'invoiceNumber': invoiceNumber,
      'date': date,
      'dueDate': dueDate,
      'amount': amount,
      'profit': profit,
      'status': status,
      'sellerNeme': sellerName,
      'paymentType': paymentType,
      'products': products,
      'approved': approved,
    };
  }
  Map<String, dynamic> tojosn() {
    return
    // {DateFormat('yyyy-MM-dd').format(DateTime.now()).toString():
      {

      id: toMap(),

    };
  }
}


