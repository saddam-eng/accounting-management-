import 'package:flutter/material.dart';

import '../consts/string.dart';
import '../controllers/databasehelper.dart';
import '../models/users_model.dart';

Future showAddCustomerDialog(context, type) {
  DatabaseHelper databaseHelper = DatabaseHelper();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        scrollable: true,
        title: Text(type == 1
            ? addSupplier
            : type == 2
                ? addCustomer
                : 'اضافة موظف'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: name),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: phone),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: address),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: email),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              showDialog(context: context, builder: (c)=>AlertDialog(
                backgroundColor: Colors.transparent,
                title: Center(child: CircularProgressIndicator()),));
              databaseHelper.signupMothod(
                  email: emailController.text,
                  password: phoneController.text,
                  name: nameController.text,
                  context: context,
                  phone: phoneController.text,
                  address: addressController.text,
                  type: "$type");

              //  Navigator.of(context).pop();
            },
            child: const Text("اضافه"),
          ),
        ],
      );
    },
  );
}
