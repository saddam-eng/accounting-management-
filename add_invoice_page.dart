import 'package:adminaccountingapp/views/show_invoice_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as t;

import '../../consts/string.dart';
import '../../consts/text_format.dart';
import '../../controllers/databasehelper.dart';
import '../../models/invoce_model.dart';
import '../../models/products.dart';
import '../../models/storage_products.dart';


class AddInvoicePage extends StatefulWidget {
  final user;
  final invoice;
  final tableName;
  final invoceNum;

  const AddInvoicePage(
      {super.key, required this.user, this.invoice, required this.tableName, required this.invoceNum});

  @override
  _AddInvoicePageState createState() => _AddInvoicePageState();
}

List<String> grop = ["اجل", "نقد"];

class _AddInvoicePageState extends State<AddInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  late var supplierName = "";
  final invoiceNumber = TextEditingController();
  var isLoading = false.obs;
  String current = grop[0];
  final List<StorageProduct> productsFromDb = [];
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
    FirebaseFirestore.instance.collection('Storage').where(
        'quantity', isGreaterThan: 0).get().then((snapshot) {
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
    super.initState();
    gg();

    invoiceNumber.text = widget.invoceNum.toString();
    supplierName = widget.user.name;
    unitController.text = '10';
    invDate.text = t.DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate());
    if (widget.invoice != null) {
      widget.invoice.products.forEach((element) {
        products.add(Product.fromMap(element));
      });

      invDate.text =
          t.DateFormat('yyyy-MM-dd').format(widget.invoice.date.toDate());
      invoiceNumber.text = widget.invoice.invoiceNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              if (products.isNotEmpty) {
                final total = calculateInvoiceAmount();
                final profit = calculateProfitAmount();
                final id = DateTime
                    .now()
                    .millisecondsSinceEpoch
                    .toString();

                isLoading.value = true;
                setState(() {});
                List<Map<String, dynamic>> productsJson =
                products.map((product) => product.toMap()).toList();
                final invoice = Invoice(
                  id: widget.invoice?.id ??
                      id,
                  customerId: widget.user.id,
                  amount: total,
                  profit: profit,
                  approved:'1',
                  sellerName: descriptionController.text,
                  products: productsJson,
                  invoiceNumber: invoiceNumber.text,
                  date: Timestamp.fromDate(DateTime.parse(invDate.text)),
                  dueDate: Timestamp.now(),
                  status: '',
                  paymentType: current,
                  // Add other invoice properties as needed
                );
                // final db = FirebaseFirestore.instance
                //     .collection('users')
                //     .doc(widget.user.id);
                // if (widget.invoice == null) {
                //   db.set({'${widget.tableName}': invoice.tojosn()
                //     ,
                //     'report': {id: {
                //       'id': Timestamp.now(),
                //       'num': invoiceNumber.text,
                //       'description': 'عليكم فاتورة مبيعات برقم ${invoiceNumber
                //           .text}',
                //       'onhim': total,
                //       'forhim': 0.0,
                //     }}
                //   },
                //       SetOptions(merge: true)).then((value) =>
                //   {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text("نمت الاضاضة")))
                //   })
                //       .then((value) async {
                //     if (products.isNotEmpty) {
                //       for (final item in products) {
                //          FirebaseFirestore.instance
                //
                //             .collection('Storage')
                //             .doc(item.id).update({
                //           'quantity': FieldValue.increment(
                //               -(item.quantity * item.unit).toInt())
                //         });
                //       }
                //
                //       products.clear();
                //       setState(() {});
                //     }
                //   });
                //   if (products.isNotEmpty) {
                //
                //     for (final item in products) {
                //      FirebaseFirestore.instance
                //
                //           .collection('Storage')
                //           .doc(item.id).update({
                //         'quantity': FieldValue.increment(-(item.quantity *
                //             item.unit).toInt())
                //       });
                //     }
                //     //      await batch.commit();
                //
                //     // Save the invoice to Firestore
                //     // ... (your existing invoice saving logic)
                //
                //     // Clear the invoice items
                //     products.clear();
                //     setState(() {});
                //   }
                // } else {
                //   db.set({'${widget.tableName}': invoice.tojosn()},
                //       SetOptions(merge: true));
                // }
                // //
               // Navigator.pop(context);
                showDialog(context:context,builder:(v){
                  return AlertDialog(
                    title: Text('هل تريد التاكيد'),
                    actions: [
                      ElevatedButton(onPressed: (){

                        db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, false,widget.user.name,productsFromDb);
                        Get.back();
                        Get.off(ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));

                      }, child: Text('حفظ')),
                      ElevatedButton(onPressed: (){
                        db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, true,widget.user.name,productsFromDb);
                      Get.back();
                        Get.off(ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));


                      }, child: Text(' حفظ وترحيل')),


                    ]

                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("الرجاء ادخال اصناف")));
              }
            },
            child: Text(widget.invoice == null ? 'اضافة' : 'تعديل'),
          ),
        ],
        centerTitle: true,
        title: Text(widget.invoice == null
            ? 'اضافة فاتورة${widget.tableName == "saleInvoices"
            ? 'مبيعات'
            : 'مشتريات'} '
            : 'تعديل فاتورة ${widget.tableName == "saleInvoices"
            ? 'مبيعات'
            : 'مشتريات'}'),
      ),

      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      invDate.text =
                          t.DateFormat('yyyy-MM-dd').format(newDate);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(invDate.text),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  controller: invoiceNumber,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 40, maxWidth: 150),
                      labelText: 'رقم الفاتورة',
                      labelStyle: const TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.teal)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.teal)),
                      hintStyle: const TextStyle(color: Colors.teal)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال عدد';
                    }
                    return null;
                  },
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
                                          'الربح: ${f.currency(
                                              products[index].profit)}')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(total),
                Text("  ${f.currency(calculateInvoiceAmount())}")
              ],
            ),
            Row(

              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Autocomplete<StorageProduct>(
                  
                      initialValue: nameController.value,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return productsFromDb;
                        }
                        return productsFromDb.where((item) =>
                            item.name
                                .toLowerCase()
                                .contains(
                                textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        nameController = textEditingController;
                        return TextFormField(
                          controller: nameController,
                          focusNode: focusNode,
                          autovalidateMode: AutovalidateMode
                              .onUserInteraction,
                          decoration: InputDecoration(

                            border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.teal)),
                            focusedBorder: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.teal)),
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
                            element.id.toLowerCase() ==
                                productIdController.text)
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
                        avgPriceController.text =
                            selectedProduct.avgPrice.toString();
                        availableQuantityController.text =
                            selectedProduct.quantity.toString();
                        productIdController.text = selectedProduct.id;
                  
                        print(selectedProduct.quantity);
                        setState(() {});
                      },
                      optionsViewOpenDirection: OptionsViewOpenDirection.up,
                      displayStringForOption: ((products) {
                        return products.name;
                      }),
                    ),
                  ),
                ),

                DropdownMenu(

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
                      setState(() {

                      });
                    },
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    label: const FittedBox(
                        child: Text(
                          'العبوة',
                        )),
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(value: '10', label: ' 10 ك',),
                      const DropdownMenuEntry(value: '12', label: '12 ك',),
                      const DropdownMenuEntry(value: '1', label: 'حبة'),
                    ]),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                        constraints: const BoxConstraints(
                           maxWidth: 150),

                        counterText: "${(double.parse(
                            '0' + avgPriceController.text) *
                            double.parse(unitController.text)).floorToDouble().toInt()}",
                        labelText: 'السعر',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.teal)),
                        focusedBorder: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.teal)),
                        hintStyle: const TextStyle(color: Colors.teal)),

                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                             ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء ادخال السعر';
                      }
                      if (double.parse(priceController.text) <
                          (double.parse(avgPriceController.text) *
                              double.parse(unitController.text))) {
                        return 'السعر اقل من سعر الشراء';
                      }
                      return null;
                    },
                  ),
                  TextFormField(


                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(

                        constraints: const BoxConstraints(
                             maxWidth: 150),

                        counterText: "${(double.parse(
                            '0' + availableQuantityController.text) /
                            double.parse(unitController.text))}",
                        labelText: 'العدد',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.teal)),
                        focusedBorder: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.teal)),
                        hintStyle: const TextStyle(color: Colors.teal)),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                       ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء ادخال العدد';
                      }
                      if (value.contains('-') || value.contains(',') ||
                          value.contains(' ')) return ',c';
                      if (double.parse(availableQuantityController.text) <
                          (double.parse(value) *
                              double.parse(unitController.text)))
                        return 'الكمبة ليست متاحة';
                      return null;
                    },
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

                            print(prfit);
                            products.add(Product(
                                id: productIdController.text,
                                name: nameController.text,
                                unit: int.parse(unitController.text),
                                profit: prfit,
                                price: double.parse(priceController.text),
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
