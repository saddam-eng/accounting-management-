

import 'package:adminaccountingapp/controllers/databasehelper.dart';
import 'package:flutter/material.dart';

import '../consts/text_format.dart';
import '../models/recipts.dart';
import '../models/users_model.dart';
import '../widget/add_reciept_dailog.dart';
import 'add_doc_pages/add_receipt_page.dart';

class CustomerReceiptsPage extends StatelessWidget {
  final User customer;
  final  Map<String, dynamic> receiptType;
  final tableName;
  final receiptNum;

  CustomerReceiptsPage({super.key, required this.customer,required this.receiptType,required this.tableName,required this.receiptNum});

  final FormatText f = FormatText();
DatabaseHelper db=DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receipts = receiptType;
    List<Receipt> receipt = [];
    for (String key in receipts.keys) {
      receipt.add(Receipt.fromMap(receipts[key]));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: List.generate(receipt.length, (index)  {
            final c = receipt[index];
        
            return buildListTile(c, context);
        })),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddReceiptDialog(context, customer,null, tableName, receiptNum);

        },
        child: const Icon(Icons.add),
      ),
    );
  }

  buildListTile(Receipt c, BuildContext context) {
    return    Card(
      color: Colors.teal.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' رقم السند:  ${c.receiptNumber}'),
              Text(' الحالة :  ${c.status}'),
              PopupMenuButton(
                  itemBuilder: (context) => [
                    if (c.status != 'مرحل')
                      PopupMenuItem(
                        child: Text('ترحيل'),
                        onTap: () {
                          db.archiveReceipt(
                              c, customer, tableName, context);
                        },
                      ),
                    if (c.status != 'مرحل')
                      PopupMenuItem(
                        child: Text('تعديل'),
                        onTap: () {
                          showAddReceiptDialog(context, customer,
                              c, tableName, receiptNum);
                        },
                      ),
                    if (c.status != 'مرحل')
                      PopupMenuItem(
                        child: Text('حذف'),
                        onTap: () async {
                          db.removeDoc(
                              customer.id, tableName, c.id);

                          // db.deleteFromUser(widget.customer.id, c.id);
                        },
                      ),
                    PopupMenuItem(
                      child: Text('اصدار فاتورة'),
                      onTap: () async {
                        db.createReceiptPdf(c.date.toDate(), customer.name, c.receiptNumber, c.amount, tableName=='receipts'?' قبض ':' صرف ');

                      },
                    ),
                  ]),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Card(
              color: Colors.teal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(' المبلغ :  ${f.currency(c.amount)}'),
                      Text(
                          ' التاريخ :  ${f.dateFormat(c.date.toDate())}'),
                    ],
                  ),
                  Text(' البيان :  ${c.note}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
