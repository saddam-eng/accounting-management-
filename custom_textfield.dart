import 'package:flutter/material.dart';

Widget customTextField(
    {label, hint, controller, isDesc = false, isnumber = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      style: const TextStyle(color: Colors.black),
      controller: controller,
      maxLines: isDesc ? 4 : 1,
      keyboardType: isnumber
          ? const TextInputType.numberWithOptions(signed: false)
          : TextInputType.text,
      decoration: InputDecoration(
          constraints: const BoxConstraints(maxWidth: 130, minWidth: 100),
          label: Text("$label"),
          border: OutlineInputBorder(
              gapPadding: 8,
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(
              gapPadding: 20,
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black)),
          hintText: ' ادخل $label'),
    ),
  );
}

Widget customTextFieldd({hint,controller,isDesc=false,isnumber=false,isPass=false}){
  return Card(
    child: TextFormField(
      obscureText: isPass,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء ادخال $hint';
        }
        return null;
      },

      controller: controller,
      maxLines: isDesc?4:1,
      keyboardType: isnumber?TextInputType.number:TextInputType.text,
      decoration: InputDecoration(

          isDense: true,

          label:Text(hint),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Colors.red
              )
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Colors.black
              )
          ),
          hintText: hint
      ),
    ),
  );
}