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
class AddBuyingInvoicePage extends StatefulWidget {
  final user;
  final invoice;
  final tableName;
  final invoceNum;

  const AddBuyingInvoicePage(
      {super.key, required this.user, this.invoice, required this.tableName,required this.invoceNum});

  @override
  _AddBuyingInvoicePageState createState() => _AddBuyingInvoicePageState();
}

List<String> grop = ["اجل", "نقد"];

class _AddBuyingInvoicePageState extends State<AddBuyingInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  late var supplierName = "";
  final invoiceNumber= TextEditingController();
  String current = grop[0];
  final  List<StorageProduct> productsFromDb = [];
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
    FirebaseFirestore.instance.collection('Storage').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        StorageProduct product = StorageProduct.fromMap(doc.data());

        print(product.id +product.name);
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
    unitController.text='10';
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
              final total = calculateInvoiceAmount();

              if (products.isNotEmpty) {
                List<Map<String, dynamic>> productsJson =
                products.map((product) => product.toMap()).toList();
                final invoice = Invoice(
                  id: widget.invoice?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  customerId: widget.user.id,
                  amount: total,
                  profit: 0.0,
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
                //   db.set({'${widget.tableName}': invoice.tojosn()},
                //       SetOptions(merge: true)).then((value)async {
                //
                //   }).then((value) => Get.back());
                //   if (products.isNotEmpty) {
                //
                //     for (final item in products) {
                //       StorageProduct b=productsFromDb.where((element) => element.id==item.id).first;
                //       final itemRef = FirebaseFirestore.instance
                //           .collection('Storage')
                //           .doc(item.id).update({
                //
                //         'quantity': FieldValue.increment((item.quantity*item.unit).toInt())
                //         ,'avgPrice':((b.avgPrice*b.quantity)+(item.price*item.quantity))/(b.quantity+(item.quantity*item.unit)),
                //       });
                //
                //     }
                //    Get.back();
                //     products.clear();
                //     setState(() {});
                //   }
                // } else {
                //   db.set({'${widget.tableName}': invoice.tojosn()},
                //       SetOptions(merge: true));
                // }
                //
                // Navigator.pop(context);
                showDialog(context:context,builder:(v){
                  return AlertDialog(
                      title: Text('هل تريد التاكيد'),
                      actions: [
                        ElevatedButton(onPressed: (){

                          db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, false,widget.user.name,productsFromDb);

                          Get.to(()=>ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));

                        }, child: Text('حفظ')),
                        ElevatedButton(onPressed: (){
                          db.saveInv(invoice, invoice.customerId, widget.tableName, context, products, true,widget.user.name,productsFromDb);
                          Get.to(()=>ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));


                        }, child: Text(' حفظ وترحيل')),


                      ]

                  );
                });
              //  Get.to(()=>ShowInvoicePage(invoice: invoice,cusomerName: widget.user.name, tableName: widget.tableName, products: products));

              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("الرجاء ادخال اصناف")));
              }
            },
            child: Text(widget.invoice == null ? 'اضافة' : 'تعديل'),
          ),
        ],
        centerTitle: true,
        title: Text(widget.invoice == null
            ? 'اضافة فاتورة${widget.tableName == "saleInvoices" ? 'مبيعات' : 'مشتريات'} '
            : 'تعديل فاتورة ${widget.tableName == "saleInvoices" ? 'مبيعات' : 'مشتريات'}'),
      ),
      backgroundColor: Colors.teal.shade100,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              color: Colors.teal.shade50,
              child: Row(
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
            ),
            Card(
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: invoiceNumber,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء ادخال رقم الفانورة';
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
                      columnWidths: const {
                        0: FlexColumnWidth(3.3),
                        1: FlexColumnWidth(0.9),
                        2: FlexColumnWidth(0.8),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(2),
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

                                                setState(() {
                                                });
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
                                          '${products[index].id}')),
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
            Card(
              color: Colors.teal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(total),
                  Text("  ${f.currency(calculateInvoiceAmount())}")
                ],
              ),
            ),
            Card(
              color: Colors.teal.shade50,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Autocomplete<StorageProduct>(

                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return List.empty(growable: true);

                            }

                            return productsFromDb.where((item) => item.name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {

                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,

                              decoration: const InputDecoration(
                                labelText: 'اسم الصنف',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ادخل اسم الصنف';
                                }
                                if (nameController.text.isEmpty) {
                                  showDialog(context: context, builder: (v){
nameController.text=textEditingController.text;
                                    return AlertDialog(
                                      title: const Text(' الصنف جديد هل تريد الاضافه'),
                                      content: Column(

                                        children: [
                                          TextFormField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                                labelText: 'اسم الصنف',
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
                                                return 'ادخل اسم الصنف';
                                              }

                                              return null;
                                            },
                                          ),
                                        TextFormField(
                                          controller: priceController,
                                          decoration: InputDecoration(
                                              counterText: avgPriceController.text,
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

                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),

                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                                          ],
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'ادخل السعر';
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
                                              counterText: availableQuantityController.text,
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
                                              return 'ادخل الغدد';
                                            }

                                            return null;
                                          },
                                        ),

                                      ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            nameController
                                                .clear();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final idd =DateTime.now().millisecondsSinceEpoch.toString();
                                  FirebaseFirestore.instance.collection('Storage').doc(idd).set(
                                      {'id': idd,
                                        'name': nameController.text,
                                        'price': 0.0,
                                        'quantity': 0,
                                        'avgPrice': 0.0,
                                        'report': {},},SetOptions(merge: true));
                                            productsFromDb.add(StorageProduct(id: idd, name: nameController.text, avgPrice: 0.0, report: {}, price: 0.0, quantity: 0, category: ''));
                                            productIdController.text = idd;

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("اضافه"),
                                        ),
                                      ],
                                    );
                                  });
                                  return ' الصنف غير موجود';
                                }
                                if (products.where((element) => element.name.toLowerCase()==textEditingController.text).isNotEmpty) {
                                  return ' الصنف مضاف مسبقا';
                                }
                                return null;
                              },
                              onChanged: (v) {

                                 nameController.clear();
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

                            productIdController.text=selectedProduct.id;
                            print(
                                "${selectedProduct.avgPrice}    ${selectedProduct.price}");
                            setState(() {});
                          },
                          optionsViewOpenDirection: OptionsViewOpenDirection.up,
                          displayStringForOption: ((products) {
                            return products.name;
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
                            },
                            trailingIcon: const Icon(Icons.arrow_drop_down),
                            label: const FittedBox(
                                child: Text(
                                  'العبوة',
                                )),
                            dropdownMenuEntries: const [
                               DropdownMenuEntry(value: '10', label: ' 10 ك',),
                               DropdownMenuEntry(value: '12', label: '12 ك',),
                               DropdownMenuEntry(value: '1', label: 'حبة'),
                            ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                                counterText: avgPriceController.text,

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

                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return ' ادخل السعر';
                              }

                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            maxLength: 5,

                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                counterText: availableQuantityController.text,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ادخل العدد';
                              }
                              if(value.contains('-')||value.contains(',')||value.contains(' '))return 'لا يمكن استخدام + او , او -';
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



                                  products.add(Product(
                                      id: productIdController.text,
                                      name: nameController.text,
                                      unit: int.parse(unitController.text),
                                      profit:0.0,
                                      price: double.parse(priceController.text),
                                      quantity:
                                      double.parse(amountController.text), category: ''));

                                  nameController.clear();
                                  priceController.clear();
avgPriceController.clear();
availableQuantityController.clear();
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

}
