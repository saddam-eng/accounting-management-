import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt {
  final String id;
  final String customerId;
  final String receiptNumber;
  final Timestamp date;
  final double amount;
  final String status;
  final String approved;
  final String sellerName;
  final String note;


  Receipt({
    required this.id,
    required this.customerId,
    required this.sellerName,
    required this.note,
    required this.approved,
    required this.receiptNumber,
    required this.date,
    required this.amount,
    required this.status,

  });

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
        id: map['receiptId'],
        customerId: map['customerId'],
        receiptNumber: map['receiptNumber'],
        date: map['date'],
      approved: map['approved'],
        amount: map['amount'],
    status: map['status'],
    sellerName: map['sellerName'],
    note: map['note'],

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiptId': id,
      'customerId': customerId,
      'receiptNumber': receiptNumber,
      'date': date,
      'approved': approved,
      'amount': amount,
      'status': status,
      'sellerName': sellerName,
      'note': note,

    };
  }
  Map<String, dynamic> tojosn() {
    return

      {

        id: toMap(),

      };
}}
