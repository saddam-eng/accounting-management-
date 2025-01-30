import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../consts/string.dart';
import '../consts/text_format.dart';
import '../controllers/databasehelper.dart';
import '../models/recipts.dart';
import '../models/users_model.dart';

Future showAddReceiptDialog(
  context,
  final User user,
  final receiptt,
  final tableName,
  final receiptNum,
) {
  final _formKey = GlobalKey<FormState>();
  final descraptionController = TextEditingController();

  FormatText f = FormatText();
  final invDate = TextEditingController();
  final amountController = TextEditingController();
  final receiptNumController = TextEditingController();
  DatabaseHelper db = DatabaseHelper();

  final priceController = TextEditingController();
  receiptNumController.text = receiptNum.toString();
  invDate.text = f.dateFormat(Timestamp.now().toDate());

  if (receiptt != null) {
    //receiptNumber = widget.tableName;
    invDate.text = f.dateFormat(receiptt.date.toDate());
  }
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      receiptNumController.text = receiptNum.toString();
      if (receiptt != null) {
        receiptNumController.text = receiptt.receiptNumber;
        invDate.text = f.dateFormat(receiptt.date.toDate());
        amountController.text = receiptt.amount.toString();
        descraptionController.text = receiptt.note;
      }
      return AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Text(
              receiptt == null
                  ? ''
                      '  أضافه سند ${tableName == 'receipts' ? ' قبض ' : ' صرف '} '
                  : '${tableName == 'receipts' ? '  قبض ' : ' صرف '}تعديل سند',
              style: TextStyle(fontSize: 12),
            ),
            InkWell(
              onTap: () async {
                DateTime? newDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2022, 1, 1),
                    lastDate: DateTime(2030, 1, 1));
                if (newDate != null) {
                  invDate.text = f.dateFormat(newDate);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textDirection: TextDirection.rtl,
                  controller: invDate,
                  enabled: false,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      constraints: BoxConstraints(maxWidth: 140)),
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(" الاسم : ${user.name}"),
                ],
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              constraints: BoxConstraints(maxWidth: 130),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              labelText: 'المبلغ'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: receiptNumController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            labelText: 'رقم الستد',
                            constraints: BoxConstraints(maxWidth: 100),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                        maxLines: 3,
                        controller: descraptionController,
                        decoration: const InputDecoration(
                          labelText: 'البيان',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final receipt = Receipt(
                id: receiptt?.id ?? id,
                approved: '1',
                customerId: user.id,
                // name: nameController.text,
                amount: double.parse(amountController.text),
                receiptNumber: receiptNumController.text,
                date: Timestamp.fromDate(DateTime.parse(invDate.text)),
                status: 'لم يرحل',
                sellerName: '',
                note: descraptionController.text,
                // Add other invoice properties as needed
              );

              db.saveReceipt(receipt, user, tableName, context, false);
            },
            child: Text(receiptt == null ? 'اضافة' : 'تعديل'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final receipt = Receipt(
                id: receiptt?.id ?? id,
                approved: '1',
                customerId: user.id,
                // name: nameController.text,
                amount: double.parse(amountController.text),
                receiptNumber: receiptNumController.text,
                date: Timestamp.fromDate(DateTime.parse(invDate.text)),
                status: 'مرحل',
                sellerName: '',
                note: descraptionController.text,
                // Add other invoice properties as needed
              );

              db.saveReceipt(receipt, user, tableName, context, true);
            },
            child: Text(receiptt == null ? 'حفظ وترحيل' : 'تعديل وترحيل'),
          ),
        ],
      );
    },
  );
}
