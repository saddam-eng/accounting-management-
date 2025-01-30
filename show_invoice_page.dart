import 'package:adminaccountingapp/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as t;

import '../../consts/string.dart';
import '../../consts/text_format.dart';
import '../../controllers/databasehelper.dart';
import '../../models/invoce_model.dart';
import '../../models/products.dart';
import '../../models/storage_products.dart';


class ShowInvoicePage extends StatelessWidget {

  final Invoice invoice;
  final tableName;
  final cusomerName;
 final List<Product>products;


   ShowInvoicePage(
      {super.key,required this.invoice, required this.tableName, required this.products, required this.cusomerName,});



  DatabaseHelper db = DatabaseHelper();

  FormatText f = FormatText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
appBar: AppBar(title:  Text( ' فاتورة${tableName == "saleInvoices"
    ? 'مبيعات'
    : 'مشتريات'} ${invoice.paymentType}'
   ),
centerTitle: true,
),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$name :  ${cusomerName}"),
          Text("التاريخ:   ${ f.dateFormat(invoice.date.toDate())}"),
          Text("رقم الفاتورة:   ${invoice.invoiceNumber.toString()}"),

          Expanded(
            child: Card(
              color: Colors.blueGrey.shade50,
              child: SingleChildScrollView(
                child: Table(
                    textBaseline: TextBaseline.alphabetic,
                    defaultVerticalAlignment:
                    TableCellVerticalAlignment.middle,
                    border: TableBorder.all(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(5)),
                    columnWidths: const {
                      0:  FlexColumnWidth(3.3),
                      1:  FlexColumnWidth(0.9),
                      2:  FlexColumnWidth(0.8),
                      3:  FlexColumnWidth(1.5),
                      4:  FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10))),
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text('اسم الصتف')),
                          Align(
                              alignment: Alignment.center,
                              child: Text('العبوة')),
                          Align(
                              alignment: Alignment.center,
                              child: Text('العدد')),
                          Align(
                              alignment: Alignment.center,
                              child: Text('السعر')),
                          Align(
                              alignment: Alignment.center,
                              child: Text(total)),
                        ],
                      ),
                      for (int index = 0; index < products.length; index++)
                        TableRow(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.teal.shade50,
                              border: const Border.fromBorderSide(
                                BorderSide(color: Colors.teal),
                              )),
                          children: [
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    Align(
                                        alignment: Alignment.center,
                                        child: FittedBox(
                                            child: Text(
                                                products[index].name))),
                                    Baseline(
                                      baseline: 20,
                                      baselineType: TextBaseline.ideographic,
                                      child: Text("${index + 1}"),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Text(products[index].unit == 1
                                    ? 'حبة':products[index].unit == 12?
                                     'ك12': 'ك10')),
                            Align(
                                alignment: Alignment.center,
                                child: Text(
                                    products[index].quantity.toString())),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                  '${f.currency(products[index].price)}'),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Text(
                                    '${f.currency(products[index].price *
                                        products[index].quantity)}')),
                          ],
                        ),
                    ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(total),
                Text("  ${f.currency(invoice.amount)}")
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(onPressed: (){
              db.createInvoPdf(invoice,tableName,cusomerName);
            }, child: Text('عرض pdf')),
            ElevatedButton(onPressed: (){
            Get.offAll(HomePage());
            }, child: Text('اغلاق')),


          ],)


        ],
      ),
    );
  }
}
