import 'dart:io';
import 'dart:typed_data';
import 'package:adminaccountingapp/models/cach_box_model.dart';

import 'package:adminaccountingapp/models/invoce_model.dart';
import 'package:adminaccountingapp/models/report_model.dart';
import 'package:adminaccountingapp/views/user_dateils_page.dart';
import 'package:adminaccountingapp/widget/add_reciept_dailog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as au;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import '../consts/string.dart';
import '../consts/text_format.dart';
import '../controllers/databasehelper.dart';
import '../main.dart';
import '../models/recipts.dart';
import '../models/storage_products.dart';
import '../models/users_model.dart';
import '../services/invoice.dart';
import '../widget/add_user_dailog.dart';
import 'add_doc_pages/add_buying_invoice_page.dart';
import 'add_doc_pages/add_invoice_page.dart';
import 'add_doc_pages/add_receipt_page.dart';
import 'add_doc_pages/add_return_view.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'customer_receipts_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> users = [];
  List<User> customers = [];
  List<User> employee = [];
  List<User> supplier = [];
  List<CaschBox> caschBox = [];
  List<StorageProduct> productsFromDb = [];

  User expenses = User(
    id: '',
    name: '',
    address: '',
    balance: 0.0,
    phone: '',
    email: '',
    password: '',
    status: '',
    receipts: {},
    report: {},
    bills: {},
    saleReturns: {},
    buyReturns: {},
    type: "",
    saleInvoices: {},
    buyInvoices: {},
    onHim: 0.0,
    forHim: 0.0,
  );

  List<User> filteredCustomer = [];
  List<User> filteredSupplier = [];

  List<User> filteredUser = [];

  DatabaseHelper databaseHelper = DatabaseHelper();
  late double saleInvTotal;
  late int saleInvTotalNum;
  late double buyInvTotal;
  late int buyInvTotalNum;
  late int receiptTotalNum;
  late double receiptTotal;
  late double onYou;
  late String date;
  late double forYou;
  late double billTotal;
  late int billTotalNum;
  late double buyReturnsTotal;
  late double profitTotal;
  late int buyReturnsTotalNum;
  late double saleReturnsTotal;
  late int saleReturnsTotalNum;

  FormatText f = FormatText();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    databaseHelper.watchUsers().listen((event) {}).cancel();
  }

  getDayReport() {
    // postsRef();
    saleInvTotalNum = users.fold(
            0,
            (previousValue, element) =>
                previousValue += element.saleInvoices.length) +
        1;
    buyInvTotalNum = users.fold(
            0,
            (previousValue, element) =>
                previousValue += element.buyInvoices.length) +
        1;
    receiptTotalNum = users.fold(
            0,
            (previousValue, element) =>
                previousValue += element.receipts.length) +
        1;
    billTotalNum = users.fold(0,
            (previousValue, element) => previousValue += element.bills.length) +
        1;
    buyReturnsTotalNum = users.fold(
            0,
            (previousValue, element) =>
                previousValue += element.buyReturns.length) +
        1;
    saleReturnsTotalNum = users.fold(
            0,
            (previousValue, element) =>
                previousValue += element.saleReturns.length) +
        1;
    forYou = users.fold(
        0.0,
        (previousValue, element) => (element.onHim - element.forHim).isNegative
            ? previousValue + 0
            : previousValue + (element.onHim - element.forHim));
    onYou = users.fold(
        0.0,
        (previousValue, element) => (element.onHim - element.forHim).isNegative
            ? previousValue + (element.onHim - element.forHim)
            : previousValue + 0);
    saleInvTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(
                element.saleInvoices, date, 'amount'));
    saleReturnsTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(
                element.saleReturns, date, 'amount'));
    receiptTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(element.receipts, date, 'amount') +
            databaseHelper.getcashTotal1(element.saleInvoices, date) +
            databaseHelper.getcashTotal1(element.buyReturns, date));
    billTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(element.bills, date, 'amount') +
            databaseHelper.getcashTotal1(element.buyInvoices, date) +
            databaseHelper.getcashTotal1(element.saleReturns, date));
    buyReturnsTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(element.buyReturns, date, 'amount'));
    profitTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(
                element.saleInvoices, date, 'profit'));
    buyInvTotal = users.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            databaseHelper.getInvoiceTotal(
                element.buyInvoices, date, 'amount'));
  }

  @override
  void initState() {
    super.initState();
    date = f.dateFormat(DateTime.now());
    getDayReport();
    databaseHelper.watchProducts().listen((event) {
      setState(() {
        productsFromDb = event;
      });
    });
    databaseHelper.watchCashBox().listen((event) {
      setState(() {
        caschBox = event;
      });
    });
    databaseHelper.watchUsers().listen((event) {
      setState(() {
        users = event;
        customers = users.where((element) => element.type == "2").toList();
        employee = users.where((element) => element.type == "4").toList();
        supplier = users.where((element) => element.type == "1").toList();
        expenses = users.where((element) => element.type == "3").first;
        filteredCustomer = customers;
        filteredSupplier = supplier;

        getDayReport();
      });
    });
  }

  void filterCustomers(String query) {
    setState(() {
      filteredCustomer = customers.where((customer) {
        final name = customer.name.toLowerCase();
        final contactInfo = customer.phone.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            contactInfo.contains(query.toLowerCase());
      }).toList();
    });
  }

  void filterSupplier(String query) {
    setState(() {
      filteredSupplier = supplier.where((supplier) {
        final name = supplier.name.toLowerCase();
        final contactInfo = supplier.phone.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            contactInfo.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          bottomNavigationBar: Card(
            color: Colors.teal.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'عليك :${f.currency(onYou)}',
                  style: const TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'لك:${f.currency(forYou)} ',
                  style: const TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          body: NestedScrollView(
            body: TabBarView(children: [
              customerListWidget(filteredCustomer, context),
              suppliersListWidget(filteredSupplier, context),
              employeeListWidget(employee, context),

              CustomerReceiptsPag(expenses, expenses.bills, 'bills',
                  receiptTotalNum, context, caschBox),
            ]),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Center(
                    child: const Text('الصفحة الرئسية'),
                  ),
                  leading: ElevatedButton(
                    onPressed: () {
                      au.FirebaseAuth.instance.signOut();
                    },
                    child: Text(loggedOut),
                  ),
                  floating: false,
                  pinned: true,
                  toolbarHeight: 20,
                  bottom: buildPreferredSize(context),
                  expandedHeight: 350.0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    background: Padding(
                      padding: const EdgeInsets.only(top: 70.0),
                      child: Column(
                        children: [
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Center(
                                    child: Text(
                                  "    الجرد اليومي لتاريخ :  ",
                                  style: TextStyle(),
                                )),
                                TextButton.icon(
                                  onPressed: () async {
                                    DateTime? newDate = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(2022, 1, 1),
                                        lastDate: DateTime(2030, 1, 1));
                                    if (newDate != null) {
                                      date = f.dateFormat(newDate);
                                      setState(() {
                                        getDayReport();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text("${date}"),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي المبيعات"),
                                      Text("${f.currency(saleInvTotal)}"),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي المشتريات"),
                                      Text("${f.currency(buyInvTotal)}"),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي مردود المبيعات"),
                                      Text("${f.currency(saleReturnsTotal)}"),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي مردود المشتريات"),
                                      Text("${f.currency(buyReturnsTotal)}"),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي القبض"),
                                      Text("${f.currency(receiptTotal)}"),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي الصرف"),
                                      Text("${f.currency(billTotal)}"),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("اجمالي الربح"),
                                      Text("${f.currency(profitTotal)}"),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Column(
                                    children: [
                                      const Text("صاقي الصندوف"),
                                      Text(
                                          "${f.currency(receiptTotal - billTotal)}"),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ];
            },
          )),
    );
  }

  PreferredSize buildPreferredSize(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Card(
        color: Colors.transparent,
        child: TabBar(
          isScrollable: true,
          indicatorColor: Colors.green,
          indicatorWeight: 5,
          dividerHeight: 10,
          splashBorderRadius: BorderRadius.circular(40),
          tabs: [
            const Tab(text: customersList),
            const Tab(text: suppliersList),
            Tab(
              text: 'الموظفين',
            ),
            Tab(
              text: 'اضافيات',
            ),


          ],
        ),
      ),
    );
  }

  Widget suppliersListWidget(filteredSuppliers, context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                filteredSuppliers.length,
                (index) {
                  final supplier = filteredSuppliers[index];
                  final double balancenum = supplier.onHim - supplier.forHim;
                  return Card(
                    shadowColor: Colors.teal,
                    borderOnForeground: true,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    color: balancenum.isNegative
                        ? Colors.green.shade100
                        : balancenum == 0
                            ? Colors.white
                            : Colors.red.shade100,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDaitelsPage(
                                    customer: supplier,
                                    saleInvTotalNum: saleInvTotalNum,
                                    buyInvTotalNum: buyInvTotalNum,
                                    receiptTotalNum: receiptTotalNum,
                                    billTotalNum: buyInvTotalNum,
                                    buyReturnsTotalNum: buyReturnsTotalNum,
                                    saleReturnsTotalNum: saleReturnsTotalNum,
                                  )),
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                  child: Text(
                                      "   اسم المورد : ${supplier.name}   ")),
                              PopupMenuButton(
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Text('انشاء تقرير'),
                                            onTap: () async {
                                              DateTimeRange? v =
                                                  await showDateRangePicker(
                                                      context: context,
                                                      firstDate: DateTime(2022),
                                                      lastDate: DateTime(2030));
                                              if (v != null) {
                                                databaseHelper.showReport(
                                                    supplier,
                                                    v.start.subtract(
                                                        Duration(days: 1)),
                                                    v.end.add(
                                                        Duration(days: 1)));
                                              }
                                            }),
                                      ]),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(onHim),
                              Text(forHim),
                              Text(
                                balance,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(" ${f.currency(supplier.onHim)}"),
                              Text("${f.currency(supplier.forHim)}"),
                              Text(
                                '${f.currency(balancenum)}${balancenum.isNegative ? ' له ' : " عليه "}'
                                    .replaceAll('-', ' '),
                              ),
                            ],
                          ),
                          Text(
                              '${Tafqeet.convert(balancenum.toInt().toString().replaceAll('-', ''))} ريال '),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddBuyingInvoicePage(
                                                  user: supplier,
                                                  tableName: 'buyInvoices',
                                                  invoceNum: saleInvTotalNum,
                                                )),
                                      );
                                    },
                                    child: const Text("فاتورة مشتريات")),
                                OutlinedButton(
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => AddreceiptPage(user: supplier,tableName: 'bills',receiptNum:billTotalNum+1),
                                      //   ),
                                      // );
                                      showAddReceiptDialog(context, supplier,
                                          null, 'bills', billTotalNum);
                                    },
                                    child: const Text("سند صرف")),
                                OutlinedButton(
                                    onPressed: () {
                                      Get.to(AddRuturnsPage(
                                        user: supplier,
                                        tableName: 'buyReturns',
                                        returnsNum: buyReturnsTotalNum,
                                        productsfromdb: productsFromDb,
                                      ));
                                    },
                                    child: const Text("مردود مشتريات")),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchBar(
              constraints: BoxConstraints(maxWidth: 340),
              leading: Icon(Icons.search),
              hintText: 'بحث باسم العميل',
              onChanged: (q) {
                filterSupplier(q);
              },
            ),
            FloatingActionButton(
              onPressed: () {
                showAddCustomerDialog(context, 1);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget customerListWidget(filteredCustomers, context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                filteredCustomers.length,
                (index) {
                  final customer = filteredCustomers[index];
                  final double balancenum = customer.onHim - customer.forHim;
                  return Card(
                    shadowColor: Colors.teal,
                    borderOnForeground: true,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    color: balancenum.isNegative
                        ? Colors.green.shade100
                        : balancenum == 0
                            ? Colors.white
                            : Colors.red.shade100,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDaitelsPage(
                                    customer: customer,
                                    saleInvTotalNum: saleInvTotalNum,
                                    buyInvTotalNum: buyInvTotalNum,
                                    receiptTotalNum: receiptTotalNum,
                                    billTotalNum: buyInvTotalNum,
                                    buyReturnsTotalNum: buyReturnsTotalNum,
                                    saleReturnsTotalNum: saleReturnsTotalNum,
                                  )),
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                  child: Text(
                                      "   اسم العميل : ${customer.name}   ")),
                              PopupMenuButton(
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Text('انشاء تقرير'),
                                            onTap: () async {
                                              DateTimeRange? v =
                                                  await showDateRangePicker(
                                                      context: context,
                                                      firstDate: DateTime(2022),
                                                      lastDate: DateTime(2030));
                                              if (v != null) {
                                                await databaseHelper.showReport(
                                                    customer,
                                                    v.start.subtract(
                                                        Duration(days: 1)),
                                                    v.end.add(
                                                        Duration(days: 1)));
                                              }
                                            }),
                                      ]),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(onHim),
                              Text(forHim),
                              Text(
                                balance,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(" ${f.currency(customer.onHim)}"),
                              Text("${f.currency(customer.forHim)}"),
                              Text(
                                '${f.currency(balancenum)}${balancenum.isNegative ? ' له ' : " عليه "}'
                                    .replaceAll('-', ' '),
                              ),
                            ],
                          ),
                          Text(
                              ' ${Tafqeet.convert(balancenum.toInt().toString().replaceAll('-', ''))}  ريال '),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      Get.to(() => AddInvoicePage(
                                            invoceNum: saleInvTotalNum,
                                            user: customer,
                                            tableName: 'saleInvoices',
                                          ));
                                    },
                                    child: const Text(" فاتورة مبيعات")),
                                OutlinedButton(
                                    onPressed: () {
                                      // Get.to(()=>AddreceiptPage(
                                      //   receiptNum: receiptTotalNum,
                                      //   user: customer,tableName: 'receipts',),);
                                      showAddReceiptDialog(context, customer,
                                          null, 'receipts', receiptTotalNum);
                                    },
                                    child: const Text(" سند قبض")),
                                OutlinedButton(
                                    onPressed: () {
                                      if (!check(customer)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text('dsdsd')));
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddRuturnsPage(
                                                    user: customer,
                                                    returnsNum:
                                                        saleReturnsTotalNum,
                                                    tableName: 'saleReturns',
                                                    productsfromdb:
                                                        productsFromDb,
                                                  )),
                                        );
                                      }
                                    },
                                    child: const Text(" مردود مبيعات ")),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchBar(
              constraints: BoxConstraints(maxWidth: 340),
              leading: Icon(Icons.search),
              hintText: 'بحث باسم العميل',
              onChanged: (q) {
                filterCustomers(q);
              },
            ),
            FloatingActionButton(
              onPressed: () {
                showAddCustomerDialog(context, 2);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool check(User user) {
    return user.saleReturns.keys.every((key) {
      Invoice invoice = Invoice.fromMap(user.saleReturns[key]);
      print(invoice.date.toDate());
      print(DateTime.now());
      return f.dateFormat(invoice.date.toDate()) !=
          f.dateFormat(DateTime.now());
    });
  }



  Widget employeeListWidget(filteredCustomers, context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                filteredCustomers.length,
                (index) {
                  final customer = filteredCustomers[index];
                  final double balancenum = customer.onHim - customer.forHim;
                  return Card(
                    shadowColor: Colors.teal,
                    borderOnForeground: true,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    color: balancenum.isNegative
                        ? Colors.green.shade100
                        : balancenum == 0
                            ? Colors.white
                            : Colors.red.shade100,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDaitelsPage(
                                    customer: customer,
                                    saleInvTotalNum: saleInvTotalNum,
                                    buyInvTotalNum: buyInvTotalNum,
                                    receiptTotalNum: receiptTotalNum,
                                    billTotalNum: buyInvTotalNum,
                                    buyReturnsTotalNum: buyReturnsTotalNum,
                                    saleReturnsTotalNum: saleReturnsTotalNum,
                                  )),
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                  child: Text(
                                      "  اسم الموظف : ${customer.name}   ")),
                              PopupMenuButton(
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Text('انشاء تقرير'),
                                            onTap: () async {
                                              DateTimeRange? v =
                                                  await showDateRangePicker(
                                                      context: context,
                                                      firstDate: DateTime(2022),
                                                      lastDate: DateTime(2030));
                                              if (v != null) {
                                                databaseHelper.showReport(
                                                    customer,
                                                    v.start.subtract(
                                                        Duration(days: 1)),
                                                    v.end.add(
                                                        Duration(days: 1)));
                                              }
                                            }),
                                      ]),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(onHim),
                              Text(forHim),
                              Text(
                                balance,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(" ${f.currency(customer.onHim)}"),
                              Text("${f.currency(customer.forHim)}"),
                              Text(
                                '${f.currency(balancenum)}${balancenum.isNegative ? ' له ' : " عليه "}'
                                    .replaceAll('-', ' '),
                              ),
                            ],
                          ),
                          Text(
                              '${Tafqeet.convert(balancenum.toInt().toString().replaceAll('-', ''))} ريال '),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      showAddReceiptDialog(context, customer,
                                          null, 'receipts', receiptTotalNum);
                                    },
                                    child: const Text("ترحيل راتب")),
                                OutlinedButton(
                                    onPressed: () {
                                      // Get.to(()=>AddreceiptPage(
                                      //   receiptNum: receiptTotalNum,
                                      //   user: customer,tableName: 'receipts',),);
                                      showAddReceiptDialog(context, customer,
                                          null, 'bills', billTotalNum);
                                    },
                                    child: const Text(" سند صرف")),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchBar(
              constraints: BoxConstraints(maxWidth: 340),
              leading: Icon(Icons.search),
              hintText: 'بحث باسم العميل',
              onChanged: (q) {
                filterCustomers(q);
              },
            ),
            FloatingActionButton(
              onPressed: () {
                showAddCustomerDialog(context, 4);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double getCashTotal(Map<String, dynamic> bills) {
    double total = 0.0;

    for (String key in bills.keys) {
      Map<String, dynamic> bill = bills[key];

      if (bill.containsKey('amount') && bill['amount'] is num) {
        total += bill['amount'] ?? 0.0;
      }
    }

    return total;
  }

  Widget CustomerReceiptsPag(User customer, Map<String, dynamic> receiptType,
      tableName, receiptNum, context, cashbox) {
    Map<String, dynamic> receipts = receiptType;
    List<Receipt> receipt = [];
    for (String key in receipts.keys) {
      receipt.add(Receipt.fromMap(receipts[key]));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.teal,),borderRadius: BorderRadius.circular(10),color: Colors.teal),

            child: Column(
              children: [
                Center(child: Text("الصناديق",style: TextStyle(color: Colors.white),),),


                  Column(
                    children: List.generate(cashbox.length, (index) {
                      final cashlist = cashbox[index];
                      final billstatol = getCashTotal(cashlist.bills);
                      final receipttatol = getCashTotal(cashlist.receipts);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(border: Border.all(color: Colors.teal,),borderRadius: BorderRadius.circular(10),color: Colors.white),

                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cashlist.name),
                                Text(
                                    " صافي الصندوق : ${f.currency(receipttatol - billstatol)}"),


                              ],
                            ),
                          ),
                        ),
                      );
                    }),


                  ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      
                          Card(
                            child: OutlinedButton(
                                                  
                                onPressed: () {
                                                  
                                },
                                                  
                                child: const Text("توريد مبلغ")),
                          ),
                          Card(
                            child: OutlinedButton(
                                onPressed: () {
                                                  
                                },
                                child: const Text("  استلام مبلغ ")),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
    SizedBox(height: 20,),
    Container(

    decoration: BoxDecoration(border: Border.all(color: Colors.teal,),borderRadius: BorderRadius.circular(10),color: Colors.grey),
    child:
          Column(
            children: [
              Center(child: Text('المصروفات',style: TextStyle(color: Colors.white),),),
             Container(
               height: 300,
               child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                        children: List.generate(receipt.length, (index) {
                      final c = receipt[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(

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
                                                  databaseHelper.archiveReceipt(
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
                                                  databaseHelper.removeDoc(
                                                      customer.id, tableName, c.id);

                                                  // db.deleteFromUser(widget.customer.id, c.id);
                                                },
                                              ),
                                            PopupMenuItem(
                                              child: Text('اصدار فاتورة'),
                                              onTap: () async {},
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
                        ),
                      );
                    })),
                  ),
             ),

  Card(
                child: OutlinedButton(
                  onPressed: () {
                    showAddReceiptDialog(
                        context, customer, null, tableName, receiptNum);
                  },
                  child: const Text('اضافة مصروف'),
                ),
              ),
            ],
          ),  ),
              SizedBox(height: 20,),
              Container(

                decoration: BoxDecoration(border: Border.all(color: Colors.teal,),borderRadius: BorderRadius.circular(10),color: Colors.grey),
                child:
                Column(
                  children: [
                    Center(child: Text('المخزون',style: TextStyle(color: Colors.white),),),
                    Container(
                      height: 300,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                            children: List.generate(receipt.length, (index) {
                              final c = receipt[index];

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(

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
                                                      databaseHelper.archiveReceipt(
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
                                                      databaseHelper.removeDoc(
                                                          customer.id, tableName, c.id);

                                                      // db.deleteFromUser(widget.customer.id, c.id);
                                                    },
                                                  ),
                                                PopupMenuItem(
                                                  child: Text('اصدار فاتورة'),
                                                  onTap: () async {},
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
                                ),
                              );
                            })),
                      ),
                    ),

                    Card(
                      child: OutlinedButton(
                        onPressed: () {
                          showAddReceiptDialog(
                              context, customer, null, tableName, receiptNum);
                        },
                        child: const Text('اضافة مصروف'),
                      ),
                    ),
                  ],
                ),  ),
        ]),
      ),
    );
  }
}
// Future<void> _showNotification(String title,id) async {
//   // Display the notification using the local notification plugin
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//     'your_channel_id',
//     'Your Channel Name',
//     channelDescription: 'Your Channel Description',
//
//
//     icon: '@mipmap/ic_launcher',
//   );
//   const NotificationDetails platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     id,
//     'New Post $id',
//     title,
//     platformChannelSpecifics,
//   );
// }
