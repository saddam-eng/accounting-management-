import 'package:adminaccountingapp/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as t;

import '../../consts/string.dart';
import '../../consts/text_format.dart';
import '../../controllers/databasehelper.dart';
import '../../models/invoce_model.dart';
import '../../models/products.dart';
import '../../models/storage_products.dart';
import '../show_invoice_page.dart';

class AddRuturnsPage extends StatefulWidget {
  final user;
  final returns;
  final tableName;
  final returnsNum;
  final productsfromdb;

  const AddRuturnsPage(
      {super.key,
      required this.user,
      this.returns,
      required this.tableName,
      required this.productsfromdb,
      required this.returnsNum});

  @override
  _AddRuturnsPageState createState() => _AddRuturnsPageState();
}

List<String> grop = ["اجل", "نقد"];

class _AddRuturnsPageState extends State<AddRuturnsPage> {
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  late var supplierName = "";
  final invoiceNumber = TextEditingController();
  var isLoading = false.obs;
  String current = grop[0];
  final List<Product> productsFromDb = [];
  final List<Product> products = [];
  DatabaseHelper db = DatabaseHelper();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final invDate = TextEditingController();

  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final availableQuantityController = TextEditingController();
  final avgPriceController = TextEditingController();
  final profitController = TextEditingController();
  final productIdController = TextEditingController();

  FormatText f = FormatText();

  late int index;

  gg() {

    Map<String, dynamic> invoices =widget.tableName=='saleReturns' ?widget.user.saleInvoices:widget.user.buyInvoices;
    DateTime data = DateTime.now().subtract(Duration(days: 1));

    for (String key in invoices.keys) {
      Map<String, dynamic> invoice = invoices[key];

      if (f.dateFormat(invoice['date'].toDate()) ==
              f.dateFormat(DateTime.now()) ||
          f.dateFormat(invoice['date'].toDate()) == f.dateFormat(data)) {
        invoice['products'].forEach((element) {
          Product product = Product.fromMap(element);
          productsFromDb.add(product);
        });
      }
    }

  }

  @override
  void initState() {
    super.initState();
    gg();

    invoiceNumber.text = widget.returnsNum.toString();
    supplierName = widget.user.name;
    unitController.text = '10';
    invDate.text = t.DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate());
    if (widget.returns != null) {
      widget.returns.products.forEach((element) {
        products.add(Product.fromMap(element));
      });

      invDate.text =
          t.DateFormat('yyyy-MM-dd').format(widget.returns.date.toDate());
      invoiceNumber.text = widget.returns.invoiceNumber;
      grop=widget.returns.paymentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return productsFromDb.isEmpty?Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text(widget.returns == null
            ? 'اضافة مرتجع ${widget.tableName == "saleReturns" ? 'مبيعات' : 'مشتريات'} '
            : 'تعديل مرتجع ${widget.tableName == "saleReturns" ? 'مبيعات' : 'مشتريات'}'),
      ),
      backgroundColor: Colors.teal.shade100,
      body:Center(
        child: Column(children: [

          Center(child: Text('لا يوجد فاتورة مبيعات بتاريخ البوم او قبلة'),

          ), Center(child: ElevatedButton(onPressed: (){
            Navigator.pop(context);
          },child: Text('خروج'),),)
        ],),
      )
    ) :Scaffold(
      appBar: AppBar(
        actions: [
          isLoading.value
              ? const CircularProgressIndicator(
                  color: Colors.red,
                )
              : ElevatedButton(
                  onPressed: () {
                    if (products.isNotEmpty) {
                      final total = calculateInvoiceAmount();
                      final profit = calculateProfitAmount();
                      final id =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      isLoading.value = true;
                      setState(() {});
                      List<Map<String, dynamic>> productsJson =
                          products.map((product) => product.toMap()).toList();
                      final invoice = Invoice(
                        id: widget.returns?.id ?? id,
                        customerId: widget.user.id,
                        amount: total,
                        profit: profit,
                        approved:'1',
                        sellerName: descriptionController.text,
                        products: productsJson,
                        invoiceNumber: invoiceNumber.text,
                        date: Timestamp.fromDate(DateTime.parse(invDate.text)),
                        dueDate: Timestamp.now(),
                        status: 'لم ترحل',
                        paymentType: current,
                        // Add other invoice properties as needed
                      );
                      showDialog(context:context,builder:(v){
                        return AlertDialog(
                            title: Text('هل تريد التاكيد'),
                            actions: [
                              ElevatedButton(onPressed: (){

                                db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, false,widget.user.name,widget.productsfromdb);

                                Get.off(ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));

                              }, child: Text('حفظ')),
                              ElevatedButton(onPressed: (){
                                db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, true,widget.user.name,widget.productsfromdb);
                                Get.off(ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));


                              }, child: Text(' حفظ وترحيل')),


                            ]

                        );
                      });
                     // Get.to(()=>ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("الرجاء ادخال اصناف")));
                    }
                  },
                  child: Text(widget.returns == null ? 'اضافة' : 'تعديل'),
                ),
        ],
        centerTitle: true,
        title: Text(widget.returns == null
            ? 'اضافة مرتجع ${widget.tableName == "saleReturns" ? 'مبيعات' : 'مشتريات'} '
            : 'تعديل مرتجع ${widget.tableName == "saleReturns" ? 'مبيعات' : 'مشتريات'}'),  ),
      backgroundColor: Colors.teal.shade100,
      body:Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("$name :${widget.user.name}"),
                TextButton.icon(
                  onPressed: () async {
                    DateTime? newDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2022, 1, 1),
                        lastDate: DateTime(2030, 1, 1));
                    if (newDate != null) {
                      invDate.text = t.DateFormat('yyyy-MM-dd').format(newDate);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text("${invDate.text}"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    controller: invoiceNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'رقم المرتجع',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal)),
                        hintStyle: TextStyle(color: Colors.teal)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء ادخال عدد';
                      }
                      return null;
                    },
                  ),
                ),
                const Text("اجل"),
                Radio(
                  value: grop[0],
                  groupValue: current,
                  onChanged: (v) {
                    setState(() {
                      current = v.toString();
                    });
                  },
                ),
                const Text("نقد"),
                Radio(
                  value: grop[1],
                  groupValue: current,
                  onChanged: (v) {
                    setState(() {
                      current = v.toString();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.transparent,
                  child: Table(
                      textBaseline: TextBaseline.alphabetic,
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.all(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(5)),
                      columnWidths: {
                        0: const FlexColumnWidth(3.3),
                        1: const FlexColumnWidth(0.9),
                        2: const FlexColumnWidth(0.8),
                        3: const FlexColumnWidth(1.5),
                        4: const FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
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
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.teal),
                                )),
                            children: [
                              Column(
                                children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                                child: Text(
                                                    products[index].name))),
                                      ),
                                      Baseline(
                                        baseline: 1,
                                        baselineType: TextBaseline.ideographic,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              splashColor: Colors.red,
                                              onTap: () {
                                                products.removeAt(index);

                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                              ),
                                            ),
                                            Text("${index + 1}"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          'الربح: ${f.currency(products[index].profit)}')),
                                ],
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child:Text(products[index].unit == 1
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
                                      '${f.currency(products[index].price * products[index].quantity)}')),
                            ],
                          ),
                      ]),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(total),
                Text("  ${f.currency(calculateInvoiceAmount())}")
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Autocomplete<Product>(
                        initialValue: nameController.value,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return productsFromDb;
                          }
                          return productsFromDb.where((item) => item.name
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          nameController = textEditingController;
                          return TextFormField(
                            controller: nameController,
                            focusNode: focusNode,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: 'اسم الصنف',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء ادخال اسم الصنف';
                              }
                              if (nameController.text.isEmpty) {
                                return ' لا يوجد صنف مشابه';
                              }
                              if (products
                                  .where((element) =>
                                      element.name.toLowerCase() ==
                                      textEditingController.text)
                                  .isNotEmpty) {
                                return ' لقد اضفت هذا الصنف';
                              }
                              return null;
                            },
                            onChanged: (v) {
                              // nameController.clear();
                            },
                            onEditingComplete: () {
                              // Triggered when editing is complete
                              // Access the selected value (assuming you have a way to get it)
                              // Update the controller
                              // Update the UI
                            },
                          );
                        },
                        onSelected: (selectedProduct) {
                          // This callback is only for updating the display text
                          nameController.text = selectedProduct.name;
                          index = productsFromDb.indexOf(selectedProduct);

                          avgPriceController.text='${selectedProduct.price/selectedProduct.unit}';
                          priceController.text =
                          '${selectedProduct.price*selectedProduct.unit}';
                          availableQuantityController.text='${selectedProduct.quantity*selectedProduct.unit}';
                          amountController.text =
                              selectedProduct.quantity.toString();
                          productIdController.text = selectedProduct.id;
                          unitController.text = selectedProduct.unit.toString();
                          print(selectedProduct.quantity);
                          setState(() {});
                        },
                        optionsViewOpenDirection: OptionsViewOpenDirection.up,
                        displayStringForOption: ((products) {
                          return "${products.name}";
                        }),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownMenu(

                          menuHeight: 150,
                          menuStyle: MenuStyle(alignment: Alignment.topCenter),

                          inputDecorationTheme: const InputDecorationTheme(
                            //

                              constraints: BoxConstraints(maxWidth: 100),
                              contentPadding: EdgeInsets.all( 1),

                              enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color: Colors.teal))
                          ),
                          initialSelection: unitController.text,
                          onSelected: (s) {
                            unitController.text = s!;
                            priceController.text=
"${double.parse('0'+priceController.text ) * double.parse(s!)}";
                            setState(() {});
                          },
                          trailingIcon: const Icon(Icons.arrow_drop_down),
                          label: FittedBox(
                              child: const Text(
                            'العبوة',
                          )),
                          dropdownMenuEntries: [
                            const DropdownMenuEntry(value: '10', label: ' 10 ك',),
                            const DropdownMenuEntry(value: '12', label: '12 ك',),
                            const DropdownMenuEntry(value: '1', label: 'حبة'),
                          ]),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(                                  "${(double.parse('0'+avgPriceController.text ) * double.parse(unitController.text)).floorToDouble().toInt()}",
                      ),
                      // SizedBox(
                      //   width: 150,
                      //   child: TextFormField(
                      //     enabled: false,
                      //     controller: priceController,
                      //     decoration: InputDecoration(
                      //         counterText:
                      //             "${double.parse('0'+avgPriceController.text ) * double.parse(unitController.text)}",
                      //         labelText: 'السعر',
                      //         labelStyle: TextStyle(color: Colors.teal),
                      //         border: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //             borderSide:
                      //                 const BorderSide(color: Colors.teal)),
                      //         focusedBorder: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //             borderSide:
                      //                 const BorderSide(color: Colors.teal)),
                      //         hintStyle: TextStyle(color: Colors.teal)),
                      //     keyboardType:
                      //         TextInputType.numberWithOptions(decimal: true),
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'الرجاء ادخال السعر';
                      //       }
                      //
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(

                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counterText:
                                  "${double.parse(availableQuantityController.text + '0') / double.parse(unitController.text)}",
                              labelText: 'العدد',
                              labelStyle: TextStyle(color: Colors.teal),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.teal)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.teal)),
                              hintStyle: TextStyle(color: Colors.teal)),
                          inputFormatters: [
                           FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء ادخال العدد';
                            }
                            if (value.contains('-') ||
                                value.contains(',') ||
                                value.contains(' ')) return ',c';
                            if (
                                (double.parse(value) *
                                    double.parse(unitController.text))>(double.parse(availableQuantityController.text) ))
                              return 'الكمبة ليست متاحة';
                            return null;
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState!.validate()) {
                                final prfit = (double.parse(
                                            priceController.text) *
                                        double.parse(amountController.text)) -
                                    (double.parse(avgPriceController.text) *
                                        double.parse(unitController.text) *
                                        double.parse(amountController.text));


                                products.add(Product(
                                    id: productIdController.text,
                                    name: nameController.text,
                                    unit: int.parse(unitController.text),
                                    profit: prfit,
                                    price: double.parse('0'+avgPriceController.text ) * double.parse(unitController.text),
                                    quantity:
                                        double.parse(amountController.text),
                                    category: ''));

                                nameController.clear();
                                priceController.clear();
                                productIdController.clear();
                                avgPriceController.clear();
                                amountController.clear();
                              }
                            });
                          },
                          child: const Text("اضافة"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double calculateInvoiceAmount() {
    double amount = 0.0;
    for (var product in products) {
      amount += product.price * product.quantity;
    }
    return amount;
  }

  double calculateProfitAmount() {
    double amount = 0.0;
    for (var product in products) {
      amount += product.profit;
    }
    return amount;
  }
}

// class AddRuturnsPage extends StatefulWidget {
//   final user;
//   final returns;
//   final tableName;
// final returnsNum;
//   const AddRuturnsPage(
//       {super.key, required this.user, required this.returnsNum,this.returns, required this.tableName});
//
//   @override
//   _AddRuturnsPageState createState() => _AddRuturnsPageState();
// }
//
// List<String> grop = ["اجل", "نقد"];
//
// class _AddRuturnsPageState extends State<AddRuturnsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   late var supplierName = "";
//   late var invoiceNumber;
//   String currint = grop[0];
//
//   DatabaseHelper db = DatabaseHelper();
//   final amountController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final invDate = TextEditingController();
//   List<Product> products = [];
//
//   final priceController = TextEditingController();
//   final uintController = TextEditingController();
//   FormatText f=FormatText();
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     invoiceNumber = widget.tableName;
//     supplierName = widget.user.name;
//     invDate.text = t.DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate());
//     if (widget.returns != null) {
//       widget.returns.products.forEach((element) {
//         products.add(Product.fromMap(element));
//       });
//
//       invDate.text =
//           t.DateFormat('yyyy-MM-dd').format(widget.returns.date.toDate());
//       invoiceNumber = widget.tableName;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               final total = calculateInvoiceAmount();
//               final profit = calculateProfitAmount();
//               if (products.isNotEmpty) {
//                 List<Map<String, dynamic>> productsJson =
//                 products.map((product) => product.toMap()).toList();
//                 final invoice = Invoice(
//                   id: widget.returns?.id ??
//                       DateTime.now().millisecondsSinceEpoch.toString(),
//                   customerId: widget.user.id,
//                   amount: total,
//                   profit: profit,
//                   sellerName: descriptionController.text,
//                   products: productsJson,
//                   invoiceNumber: '',
//                   date: Timestamp.fromDate(DateTime.parse(invDate.text)),
//                   dueDate: Timestamp.now(),
//                   status: '',
//                   paymentType: currint,
//                   // Add other invoice properties as needed
//                 );
//
//                 final db = FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(widget.user.id);
//                 if (widget.returns == null) {
//                   db.set({'${widget.tableName}': invoice.tojosn()},
//                       SetOptions(merge: true)).then((value) {
//                     if(currint=='نقد'){
//                       if(widget.tableName=="saleReturns"){
//                         print(widget.tableName);
//                       }
//                     }
//
//                   });
//                 } else {
//                   db.set({'${widget.tableName}': invoice.tojosn()},
//                       SetOptions(merge: true));
//                 }
//
//                 Navigator.pop(context);
//               }
//             },
//             child: Text(widget.returns == null ? 'اضافة' : 'تعديل'),
//           ),
//         ],
//         centerTitle: true,
//         title: Text(widget.returns == null
//             ? 'اضافة مردود ${widget.tableName=="saleInvoices"?'مبيعات':'مشتريات'} '
//             : 'تعديل مردود ${widget.tableName=="saleInvoices"?'مبيعات':'مشتريات'}'),
//       ),
//       body: Form(
//         key: _formKey,
//
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 Text("$name :${widget.user.name}"),
//                 TextButton.icon(
//                   onPressed: () async {
//                     DateTime? newDate = await showDatePicker(
//                         context: context,
//                         firstDate: DateTime(2022, 1, 1),
//                         lastDate: DateTime(2030, 1, 1));
//                     if (newDate != null) {
//                       invDate.text = t.DateFormat('yyyy-MM-dd').format(newDate);
//                       setState(() {});
//                     }
//                   },
//                   icon: const Icon(Icons.calendar_month),
//                   label: Text("${invDate.text}"),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//
//                 Container(
//                   child:  Text( "اجل")
//                   ,
//
//
//                 ),
//                 Radio(value: grop[0],groupValue: currint,onChanged: (v){
//                   setState(() {
//                     currint=v.toString();
//                   });
//                 },),
//
//
//                 Text("نقد"),
//
//                 Radio(value: grop[1],groupValue: currint,onChanged: (v){
//                   setState(() {
//                     currint=v.toString();
//
//                   });
//                 },),
//
//
//               ],),
//             Card(
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: nameController,
//                     decoration: const InputDecoration(labelText: 'اسم الصنف'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a name';
//                       }
//                       return null;
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       SizedBox(
//                         width: 100,
//                         child:
//
//                         DropdownMenu(dropdownMenuEntries: [
//                           DropdownMenuEntry(value: 'كرتون', label: 'كرتون'),
//                           DropdownMenuEntry(value: 'حبة', label: 'حبة'),
//
//                         ]),
//                         // TextFormField(
//                         //   controller: uintController,
//                         //   decoration:
//                         //       const InputDecoration(labelText: 'العبوة'),
//                         //   validator: (value) {
//                         //     if (value == null || value.isEmpty) {
//                         //       return 'Please enter an amount';
//                         //     }
//                         //     return null;
//                         //   },
//                         // ),
//                       ),
//                       SizedBox(
//                         width: 100,
//                         child: TextFormField(
//                           controller: priceController,
//                           decoration: const InputDecoration(labelText: 'السعر'),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter an amount';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         width: 100,
//                         child: TextFormField(
//                           controller: amountController,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(labelText: 'العدد'),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a description';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: FilledButton(
//                       onPressed: () {
//                         setState(() {
//                           if (_formKey.currentState!.validate()) {
//                             products.add(Product(
//                                 id: "productId",
//                                 name: nameController.text,
//                                 unit: int.parse(uintController.text),
//                                 price: double.parse(priceController.text),
//                                 quantity: double.parse(amountController.text), profit: 0.0, category: ''));
//                             nameController.clear();
//                             priceController.clear();
//                             uintController.clear();
//                             amountController.clear();
//                           }
//                         });
//                       },
//                       child: const Text("اضافة"),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             Card(
//               child: FittedBox(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     SizedBox(
//                       width: 150,
//                       child: Text('اسم الصتف'),
//                     ),
//                     SizedBox(
//                       width: 50,
//                       child: Text('العبوة'),
//                     ),
//                     SizedBox(
//                       width: 50,
//                       child: Text("العدد"),
//                     ),
//                     SizedBox(
//                       width: 80,
//                       child: Text('السعر'),
//                     ),
//
//                     SizedBox(
//                         width: 80,
//                         child: Text(
//                           total,
//                         )),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                     children: List.generate(
//                         products.length,
//                             (index) => Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Card.filled(
//                               child: FittedBox(
//                                 child: Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceAround,
//                                   children: [
//                                     SizedBox(
//                                       width: 150,
//                                       child: Card.outlined(
//                                         semanticContainer: false,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 8.0),
//                                           child: Text(
//                                             products[index].name,
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 50,
//                                       child:
//                                       Text(products[index].unit.toString()),
//                                     ),
//                                     SizedBox(
//                                       width: 50,
//                                       child: Text(products[index]
//                                           .quantity
//                                           .toString()),
//                                     ),
//                                     SizedBox(
//                                       width: 80,
//                                       child: Text(
//                                           f.currency(  products[index].price)),
//                                     ),
//
//                                     SizedBox(
//                                       width: 80,
//                                       child: Text(
//                                           "${f.currency(products[index].price * products[index].quantity)}"),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Baseline(
//                               baseline: 7,
//                               baselineType: TextBaseline.ideographic,
//                               child: TextButton.icon(
//                                 onPressed: () {
//                                   products.removeAt(index);
//                                   setState(() {});
//                                 },
//                                 label: Text("${index + 1}"),
//                                 icon: const Icon(
//                                   Icons.delete,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ))),
//               ),
//             ),
//             Card(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Text(total),
//                       Text(" : ${f.currency(calculateInvoiceAmount())}")
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text('خصم'),
//                       Text(" : ${f.currency(calculateInvoiceAmount())}")
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   double calculateInvoiceAmount() {
//     double amount = 0.0;
//     for (var product in products) {
//       amount += product.price * product.quantity;
//     }
//     return amount;
//   } double calculateProfitAmount() {
//     double amount = 0.0;
//     for (var product in products) {
//       amount += product.profit;
//     }
//     return amount;
//   }
// }
