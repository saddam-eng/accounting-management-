// import 'package:adminaccountingapp/views/home_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart' as t;
//
// import '../../consts/string.dart';
// import '../../consts/text_format.dart';
// import '../../controllers/databasehelper.dart';
// import '../../models/invoce_model.dart';
// import '../../models/products.dart';
// import '../../models/recipts.dart';
// import '../../models/storage_products.dart';
// import '../../models/users_model.dart';
//
// class AddreceiptPage extends StatefulWidget {
//   final User user;
//   final receiptt;
//   final tableName;
//   final receiptNum;
//
//   const AddreceiptPage({super.key, required this.user,required this.receiptNum, this.receiptt,required this.tableName});
//
//   @override
//   _AddreceiptPageState createState() => _AddreceiptPageState();
// }
//
// class _AddreceiptPageState extends State<AddreceiptPage> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   late var receiptName = "";
//   late var receiptNumber='';
//
//   DatabaseHelper db = DatabaseHelper();
//   FormatText f = FormatText();
//   final invDate= TextEditingController();
//   final amountController = TextEditingController();
//   final descriptionController = TextEditingController();
//
//
//   final priceController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     invDate.text=f.dateFormat(Timestamp.now().toDate());
//
//     receiptNumber = widget.tableName??"";
//     receiptName = widget.user.name;
//     if (widget.receiptt != null) {
//
//
//       //receiptNumber = widget.tableName;
//       invDate.text=f.dateFormat(widget.receiptt.date.toDate());
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.receiptt == null ? '${widget.tableName=='receipts'?'قبض':'صرف'}أضافه سند' : '${widget.tableName=='receipts'?'قبض':'صرف'}تعديل سند'),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Text(widget.user.name),
//                   TextButton.icon(
//                     onPressed: () async {
//                       DateTime? newDate = await showDatePicker(
//                           context: context,
//                           firstDate: DateTime(2022, 1, 1),
//                           lastDate: DateTime(2030, 1, 1));
//                       if (newDate != null) {
//                         invDate.text =f.dateFormat(newDate);
//                         setState(() {});
//                       }
//                     },
//                     icon: const Icon(Icons.calendar_month),
//                     label: Text("${invDate.text}"),
//                   ),
//                 ],
//               ),
//               Card(
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(labelText: 'البيان'),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a name';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(
//                       width: 100,
//                       child: TextFormField(
//                         controller: amountController,
//                         keyboardType: TextInputType.number,
//                         decoration:
//                             const InputDecoration(labelText: 'المبلغ'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a description';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//
//                   ],
//                 ),
//               ),
//
//               ElevatedButton(
//                 onPressed: () {
//
//                   final receipt = Receipt(
//                     id: widget.receiptt?.id ??
//                         DateTime.now().millisecondsSinceEpoch.toString(),
//                     customerId: widget.user.id,
//                     // name: nameController.text,
//                     amount: double.parse(amountController.text), receiptNumber: '', date: Timestamp.fromDate(DateTime.parse(invDate.text)), status: '', sellerName: '', note: '',
//                     // Add other invoice properties as needed
//                   );
//
//                   final db = FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(widget.user.id);
//                   if (widget.receiptt == null) {
//                     db.set({'${widget.tableName}':
//                      receipt.tojosn()},
//                         SetOptions(merge: true));
//                   } else {
//                     // db.set({'invoices':invoice.tojosn()},SetOptions(merge: true));
//
//                     db.set({'${widget.tableName}':
//                     receipt.tojosn()},
//                         SetOptions(merge: true));
//                   }
//
//               Navigator.pop(context);
//                 },
//                 child: Text(widget.receiptt == null ? 'Add' : 'Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
// }
