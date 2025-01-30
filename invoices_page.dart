import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adminaccountingapp/views/add_doc_pages/add_buying_invoice_page.dart';
import 'package:adminaccountingapp/views/add_doc_pages/add_return_view.dart';
import 'package:adminaccountingapp/views/show_invoice_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import '../consts/string.dart';
import '../consts/text_format.dart';
import '../controllers/databasehelper.dart';
import '../models/invoce_model.dart';
import '../models/products.dart';
import '../models/storage_products.dart';
import '../models/users_model.dart';
import '../services/create_invoice.dart' as t;
import 'add_doc_pages/add_invoice_page.dart';

class InvoicesPage extends StatefulWidget {
  final User customer;
  final tableName;
  final invNum;

  const InvoicesPage(
      {super.key,
      required this.customer,
      required this.tableName,
      required this.invNum});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  // Map<String, dynamic> invoic = customer.saleInvoices;
  DatabaseHelper db = DatabaseHelper();
  List<Invoice> invoce = [];
  final FormatText f = FormatText();
  final List<StorageProduct> productsFromDb = [];

  gg() {
    FirebaseFirestore.instance.collection('Storage').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        StorageProduct product = StorageProduct.fromMap(doc.data());

        productsFromDb.add(product);
      }
      setState(() {
        productsFromDb;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gg();
    db.watchUsersDoc(widget.customer.id, widget.tableName).listen((value) {
      setState(() {
        invoce = value;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    db
        .watchUsersDoc(widget.customer.id, widget.tableName)
        .listen((value) {})
        .cancel();
  }

  @override
  Widget build(BuildContext context) {
    invoce = invoce..sort((a, b) => b.date.compareTo(a.date));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView.builder(
          itemCount: invoce.length,
          itemBuilder: (context, index) {
            final c = invoce[index];

            return buildListTile(c, context, index);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (widget.tableName == 'saleInvoices')
              Get.to(AddInvoicePage(
                user: widget.customer,
                tableName: widget.tableName,
                invoceNum: widget.invNum,
              ));
            if (widget.tableName == 'buyInvoices')
              Get.to(AddBuyingInvoicePage(
                user: widget.customer,
                tableName: widget.tableName,
                invoceNum: widget.invNum,
              ));
            if (widget.tableName == 'buyReturns' ||
                widget.tableName == 'saleReturns')
              Get.to(AddRuturnsPage(
                user: widget.customer,
                tableName: widget.tableName,
                productsfromdb: productsFromDb,
                returnsNum: widget.invNum,
              ));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildListTile(Invoice c, BuildContext context, i) {
    List<Product> cartList = [];
    c.products.forEach((element) {
      cartList.add(Product.fromMap(element));
    });

    return InkWell(
      onTap: () {
        Get.to(ShowInvoicePage(
            invoice: c, tableName: widget.tableName, products: cartList, cusomerName: widget.customer.name,));
      },
      child: Card(
        color: Colors.teal.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$invoNum ${c.invoiceNumber}'),
                  Text(' التاريخ :  ${f.dateFormat(c.date.toDate())}'),
                  PopupMenuButton(
                      itemBuilder: (context) => [
                            if (c.status != 'مرحل')
                              PopupMenuItem(
                                child: Text('ترحيل'),
                                onTap: () {
                                  db.archive(
                                      cartList,
                                      c,
                                      widget.customer.id,
                                      context,
                                      widget.tableName,
                                      widget.customer.name,
                                      productsFromDb);
                                },
                              ),
                            if (c.status != 'مرحل')
                              PopupMenuItem(
                                child: Text('تعديل'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddInvoicePage(
                                        user: widget.customer,
                                        invoice: c,
                                        tableName: widget.tableName,
                                        invoceNum: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (c.status != 'مرحل')
                              PopupMenuItem(
                                child: Text('حذف'),
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.customer.id)
                                      .update({
                                    '${widget.tableName.toString().removeAllWhitespace}.${c.id}':
                                        FieldValue.delete(),
                                  });

                                  // db.deleteFromUser(widget.customer.id, c.id);
                                },
                              ),
                            PopupMenuItem(
                              child: Text('اصدار فاتورة'),
                              onTap: () async {
                                db.createInvoPdf(
                                    c, widget.tableName, widget.customer.name);
                              },
                            ),
                          ]),

                  // IconButton(
                  //   icon: const Icon(Icons.edit),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => AddInvoicePage(
                  //           user: widget.customer,
                  //           invoice:c ,
                  //           tableName: widget.tableName,
                  //           invoceNum: '',
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //
                  // ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.teal,
                child: Column(
                  children: [
                    Text('$total= ${c.amount}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('الحالة:  ${c.status}'),
                        Text('النوع:  ${c.paymentType}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
