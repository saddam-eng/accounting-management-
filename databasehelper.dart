import 'dart:io';
import 'dart:typed_data';

import 'package:adminaccountingapp/models/cach_box_model.dart';
import 'package:adminaccountingapp/models/products.dart';
import 'package:adminaccountingapp/models/recipts.dart';
import 'package:adminaccountingapp/services/create_recript.dart';
import 'package:adminaccountingapp/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as t;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import '../consts/string.dart';
import '../consts/text_format.dart';
import '../models/invoce_model.dart';
import '../models/report_model.dart';
import '../models/storage_products.dart';
import '../models/users_model.dart';
import '../services/create_invoice.dart';
import '../services/invoice.dart';

class DatabaseHelper {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  FormatText f = FormatText();

  t.FirebaseAuth auth = t.FirebaseAuth.instance;

  Stream<List<User>> watchUsers() {
    return _database.collection('users').snapshots().map((snapshot) {
      List<User> users = [];
      for (var doc in snapshot.docs) {
        User user = User.fromMap(doc.data());
        users.add(user);
      }

      return users;
    });
  }

  Stream<List<Invoice>> watchUsersDoc(id, tableName) {
    return _database.collection('users').doc(id).snapshots().map((snapshot) {
      Map<String, dynamic> invoic = snapshot.get(tableName);
      List<Invoice> users = [];
      for (String doc in invoic.keys) {
        users.add(Invoice.fromMap(invoic[doc]));
      }

      return users;
    });
  }
  Stream<List<CaschBox>> watchCashBox() {
    return _database.collection('cashes_box').snapshots().map((snapshot) {
      List<CaschBox> users = [];
      for (var doc in snapshot.docs) {
        CaschBox user = CaschBox.fromMap(doc.data());
        users.add(user);
      }

      return users;
    });
  }

  Stream<List<StorageProduct>> watchProducts() {
    return _database.collection('Storage').snapshots().map((snapshot) {
      List<StorageProduct> products = [];
      for (var doc in snapshot.docs) {
        StorageProduct product = StorageProduct.fromMap(doc.data());
        products.add(product);
      }
      return products;
    });
  }

  Future<void> addUser(User user) async {
    await _database.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> archiveReceipt(
      Receipt receipt, user, String tableName, context) async {
    _database.collection('users').doc(user.id).set({
      tableName.toString(): {
        receipt.id.toString(): {'status': 'مرحل'}
      },
      'report': {
        receipt.id: {
          'id': receipt.date,
          'num': receipt.receiptNumber,
          'description':
              '  ${tableName == "receipts" ? ' لكم سند قبض   ' : 'عليكم سند صرف'} برقم ${receipt.receiptNumber}${receipt.note}',
          'onhim': tableName == "bills" ? receipt.amount : 0.0,
          'forhim': tableName == "receipts" ? receipt.amount : 0.0,
        }
      }
    }, SetOptions(merge: true));
    _database.collection('cashes_box').doc('1').set({
      tableName: receipt.tojosn(),
      'report': {
        receipt.id: {
          'id': receipt.date,
          'num': receipt.receiptNumber,
          'description':
              '  ${tableName == "receipts" ? '  سند قبض   ' : ' سند صرف'} برقم ${receipt.receiptNumber} ل  ${user.name}',
          'onhim': tableName == "bills" ? receipt.amount : 0.0,
          'forhim': tableName == "receipts" ? receipt.amount : 0.0,
        }
      },
    }, SetOptions(merge: true));
  }

  Future<void> saveReceipt(
      Receipt receipt, user, String tableName, context, isPost) async {
    _database
        .collection('users')
        .doc(user.id)
        .set({tableName: receipt.tojosn()}, SetOptions(merge: true));

    if (isPost) {
      archiveReceipt(receipt, user, tableName, context);
    }
    Navigator.of(context).pop();
  }

  Future<void> archive(products, Invoice invoice, id, context, tableName,
      username, productsFromDb) async {
    final db = _database.collection('users').doc(id);
    if (products.isNotEmpty) {
      for (final item in products) {
        StorageProduct b =
            productsFromDb.where((element) => element.id == item.id).first;
        final value = (item.quantity * item.unit).toInt();

        _database.collection('Storage').doc(item.id).update({
          if ((tableName == 'saleInvoices' || tableName == 'buyReturns') &&
              (item.quantity <= b.quantity))
            'quantity': FieldValue.increment(-value),
          if ((tableName == 'buyInvoices' || tableName == 'saleReturns'))
            'quantity': FieldValue.increment(value),

          'report.${invoice.id}': {
            'date': invoice.date,
            'num': invoice.invoiceNumber.toString(),
            'description':
                '  ${tableName == "saleInvoices" ? '  فاتورة مبيعات     ' : tableName == "buyReturns" ? '  مردود مشتريات     ' : tableName == "buyInvoices" ? '   فاتورة مشتريات     ' : '  مردود مبيعات     '}${invoice.paymentType} برقم ${invoice.invoiceNumber}  للعميل $username',
            'quantity': item.quantity,
            'unit': item.unit.toString(),
            'price': item.price.toString(),
          },
          if (tableName == 'buyInvoices')
            'avgPrice':
                ((b.avgPrice * b.quantity) + (item.price * item.quantity)) /
                    (b.quantity + (item.quantity * item.unit)),
          if (tableName == 'buyReturns' && (item.quantity <= b.quantity))
            'avgPrice':
                ((b.avgPrice * b.quantity) - (item.price * item.quantity)) /
                    (b.quantity - (item.quantity * item.unit))

          // tableName == 'buyInvoices'
          //         ? 'avgPrice'
          //         : ((b.avgPrice * b.quantity) + (item.price * item.quantity)) /
          //             (b.quantity + (item.quantity * item.unit)):
          //     tableName == 'buyReturns'
          //    ?           //         : FieldValue.increment(0)
        });
      }
      if (invoice.paymentType == 'اجل') {
        db.set({
          tableName.toString(): {
            invoice.id.toString(): {'status': 'مرحل'}
          },
          'report': {
            invoice.id: {
              'id': invoice.date,
              'num': invoice.invoiceNumber,
              'description':
                  '  ${tableName == "saleInvoices" ? ' عليكم فاتورة مبيعات اجل    ' : tableName == "buyReturns" ? ' عليكم مردود مشتريات اجل    ' : tableName == "buyInvoices" ? ' لكم  فاتورة مشتريات اجل    ' : ' لكم مردود مبيعات اجل    '} برقم ${invoice.invoiceNumber}',
              'onhim': tableName == "saleInvoices" || tableName == "buyReturns"
                  ? invoice.amount
                  : 0.0,
              'forhim': tableName == "saleReturns" || tableName == "buyInvoices"
                  ? invoice.amount
                  : 0.0,
            }
          }
        }, SetOptions(merge: true)).then((value) => {});
      } else {
        db.set({
          tableName.toString(): {
            invoice.id.toString(): {'status': 'مرحل'}
          },
        }, SetOptions(merge: true)).then((value) => {});
        final receipt = Receipt(
          id: invoice.id,
          customerId: id,
          approved:invoice.approved??'',
          // name: nameController.text,
          amount: invoice.amount,
          receiptNumber: invoice.invoiceNumber,
          date: invoice.date,
          status: invoice.status??'',
          sellerName: invoice.sellerName??'',
          note:
              '  ${tableName == "saleInvoices" ? '  فاتورة مبيعات نقد    ' : tableName == "buyReturns" ? '  مردود مشتريات نقد    ' : tableName == "buyInvoices" ? '   فاتورة مشتريات نقد    ' : '  مردود مبيعات اجل    '} برقم ${invoice.invoiceNumber}  للعميل $username',

          // Add other invoice properties as needed
        );

        _database.collection('cashes_box').doc('1').set({
          tableName == 'saleInvoices' || tableName == 'buyReturns'
              ? 'receipts'
              : 'bills': receipt.tojosn(),
          'report': {
            receipt.id: {
              'id': receipt.date,
              'num': receipt.receiptNumber,
              'description': receipt.note,
              'onhim': tableName == "saleInvoices" || tableName == "buyReturns"
                  ? receipt.amount
                  : 0.0,
              'forhim': tableName == "saleReturns" || tableName == "buyInvoices"
                  ? receipt.amount
                  : 0.0,
            }
          }
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> removeDoc(userId, tableName, docId) async {
    await _database.collection('users').doc(userId).update({
      '${tableName.toString().removeAllWhitespace}.$docId': FieldValue.delete(),
    });
  }

  Future<void> saveInv(Invoice invoice, id, tableName, context, products,
      isPosted, user, productsFromDb) async {
    final db = _database.collection('users').doc(id);

    db.set({
      '$tableName': invoice.tojosn(),
    }, SetOptions(merge: true)).then((value) => {});

    if (isPosted) {
      archive(products, invoice, id, context, tableName, user, productsFromDb);
    }
    //

    // Get.offAll(() => HomePage());
  }

  getInvoiceTotal(Map<String, dynamic> invoices, date, colName) {
    double total = 0.0;
    for (String key in invoices.keys) {
      Map<String, dynamic> invoice = invoices[key];

      if (invoice.containsKey(colName) &&
          invoice[colName] is num &&
          DateFormat('yyyy-MM-dd').format(invoice['date'].toDate()) == date &&
          invoice['status'] == 'مرحل') {
        total += invoice[colName] ?? 0.0;
      }
    }

    return total;
  }

  Future<void> showReport(User user, date1, date2) async {
    final path = (await getExternalStorageDirectory());
    final fd = "${f.dateFormat(date1).toString().removeAllWhitespace}.pdf";

    final userDir = Directory('${path!.absolute.path}/${user.name}');
    if (!(await userDir.exists())) {
      await userDir.create();
    }
    print(userDir);
    final file = File("//${userDir.path}/$fd");

    Map<String, dynamic> cartList = user.report;
    List<Report> report = [];
    for (String doc in cartList.keys) {
      report.add(Report.fromMap(cartList[doc]));
    }
    Uint8List byts = await (generateInvoice(
      PdfPageFormat.a4,
      report
          .where((element) =>
              element.id.toDate().isAfter(date1) &&
              element.id.toDate().isBefore(date2))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id)),
      username: user.name,
      date:
          '  من تاريخ ${f.dateFormat(date1.add(const Duration(days: 1)))}  الي  ${f.dateFormat(date2.subtract(const Duration(days: 1)))}  ',
      name: user.name,
      address: user.address,
      phone: user.phone,
    ));

    await file.writeAsBytes(byts);

    await OpenFile.open(file.path);
  }
  Future<void> createReceiptPdf( date,
      name,
      num,
      amount,
      type) async {
    final path = (await getExternalStorageDirectory());
    final fd = "${f.dateFormat(date).toString().removeAllWhitespace}.pdf";

    final file = File("//${path!.path}/$fd");



    Uint8List byts = await (createReceipt(
      PdfPageFormat.a4,

      date:   f.dateFormat(date),
      name:   name,
     num:    num,
     amount:    amount,
     type:    type

    ));

    await file.writeAsBytes(byts);

    await OpenFile.open(file.path);
  }

  double getcashTotal1(Map<String, dynamic> invoices, date) {
    double total = 0.0;
    for (String key in invoices.keys) {
      Map<String, dynamic> invoice = invoices[key];

      if (invoice.containsKey('amount') &&
          invoice['amount'] is num &&
          f.dateFormat(invoice['date'].toDate()) == date &&
          invoice['paymentType'] == 'نقد' &&
          invoice['status'] == 'مرحل') {
        total += invoice['amount'] ?? 0.0;
      }
    }

    return total;
  }

  Future<void> signupMothod(
      {email, password, name, context, phone, address, type}) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((valuee) {
        return addUser(User(
          id: valuee.user!.uid,
          name: name,
          address: address,
          phone: phone,
          email: email,
          password: phone,
          report: {},
          bills: {},
          saleReturns: {},
          buyReturns: {},
          type: type,
          status: '',
          balance: 0.0,
          saleInvoices: {},
          buyInvoices: {},
          receipts: {},
          onHim: 0.0,
          forHim: 0.0,
        )).then((value) async {
          auth.signOut();
          Get.offAll(const HomePage());
          return null;
        });
      });
    } catch (e) {
      Get.back();
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                content: SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(e.toString().trim()),
                    )),
              ));
    }
  }

  Future<t.UserCredential?> loginMethod(
      {context, emailController, passwordController}) async {
    t.UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: emailController, password: passwordController);
    } on t.FirebaseAuthException catch (ee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ee.message.toString().trim())),
      );
    }
    return userCredential;
  }

  Future<void> createInvoPdf(Invoice c, tableName, username) async {
    final products = [];
    for (var element in c.products) {
      products.add(Product.fromMap(element));
    }
    final path = (await getExternalStorageDirectory())!.path;
    final file = File("$path/$pdfName");
    Uint8List byts = await (createInvoice(
      PdfPageFormat.a4,
      products,
      name: c.invoiceNumber,
      phone: c.customerId,
      address:
          '    فاتورة ${tableName == "saleInvoices" ? 'مبيعات' : 'مشتريات'} ${c.paymentType}',
      date: f.dateFormat(c.date.toDate()),
      username: username,
    ));

    file.writeAsBytes(byts);
    await OpenFile.open(file.path);
    Get.offAll(const HomePage());
  }
}
