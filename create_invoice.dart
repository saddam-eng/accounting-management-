import 'dart:typed_data';

import 'package:adminaccountingapp/consts/string.dart';
import 'package:adminaccountingapp/consts/text_format.dart';
import 'package:adminaccountingapp/models/products.dart';
import 'package:adminaccountingapp/models/report_model.dart';
import 'package:adminaccountingapp/services/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:number_to_word_arabic/number_to_word_arabic.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart' as t;

Future<Uint8List> createInvoice(
  PdfPageFormat pageFormat,
  List<dynamic> o, {
  date,
  name,
  address,
  phone,
  required username,
}) async {
  FormatText f = FormatText();
  var t = 0.0;
  final products = List.generate(o.length, (i) {


    return Products(
        "${i+1}",
        o[i].name,
        double.parse(o[i].price.toString()),
        double.parse(o[i].quantity.toString()),
        o[i].price*o[i].quantity,
        o[i].unit.toString()


        );
  });
  final invoice = CreateInvoice(
    products: products,
    customerName: name,
    phone: phone,

    date: date,
    type: address,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,
    username: username,
  );
  return await invoice.buildPdf(pageFormat);
}

class CreateInvoice {
  CreateInvoice({
    required this.products,
    required this.customerName,
    required this.date,
    required this.username,
    required this.type,
    required this.phone,
    required this.baseColor,
    required this.accentColor,
  });

  final List<Products> products;
  final String customerName;
  final String date;
  final String type;
  final String phone;
  final String username;
  final PdfColor baseColor;
  final PdfColor accentColor;
  static const _darkColor = PdfColors.black;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

  double get _total => products.fold(
      0.0,
      (previousValue, element) =>
          previousValue += element.total);

  String? _bgShape;
  String? _si;
late final logoImage;
  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();
    logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          pw.Font.ttf(await rootBundle.load("assets/fonts/m.ttf")),
          pw.Font.ttf(await rootBundle.load("assets/fonts/m.ttf")),
          pw.Font.ttf(await rootBundle.load("assets/fonts/m.ttf")),
        ),

        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [

              pw.Container(

                decoration: pw.BoxDecoration(border: pw.Border.all(color: baseColor)),

                child:    pw.Row(children: [
                       pw.Text("اسم العميل:",
                                style: const pw.TextStyle(
                                  ))
                        ,
                        pw.SizedBox(width: 10),
                        pw.Container(
                          width: 150,
                          child: pw.Text(username),
                        ),
                        pw.Text("رقم الفاتورة :",
                                style: const pw.TextStyle(
                                ))
                     ,
                        pw.SizedBox(width: 10),
                        pw.Container(
                          width: 50,
                          child: pw.Text(customerName),
                        ),
                      pw.Text(" تاريخ الفاتورة :",
                                style: const pw.TextStyle(
                                   ))
                        ,
                        pw.SizedBox(width: 10),
                        pw.Container(
                          width: 65,
                          child: pw.Text(date),
                        )
                      ]),

          ),

          pw.SizedBox(height: 10),

          _contentTable(context),
          pw.SizedBox(height: 10),
          _contentHeader(context),

          pw.SizedBox(height: 10),
          _contentFooter(context),
          pw.SizedBox(height: 10),
          //  _termsAndConditions(context),
        ],

      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$type',
                    style: pw.TextStyle(
                      color: baseColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.max,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topLeft,
                    padding: const pw.EdgeInsets.only(bottom: 8, right: 30),
                    height: 100,
                    width: 400,
                    child: pw.Image(logoImage),
                  ),
                  pw.Container(
                    color: baseColor,
                    padding: pw.EdgeInsets.only(top: 3),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.Container(color: baseColor, padding: pw.EdgeInsets.only(top: 3)),
        pw.SizedBox(height: 20),

        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
        pw.Container(
          height: 100,
          width: 100,
          child:
              pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [

          ]),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(

      textDirection: pw.TextDirection.rtl,
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),

    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return
        pw.Container(
          width: double.infinity,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: baseColor)),

    child: pw.Center(child:  pw.Text(
            "  الاجمالي : ${Tafqeet.convert(_total.toInt().toString().replaceAll('-', ''))} ريال ${_formatCurrency(_total)}${_total.isNegative ? '  له  ' : "  علية  "} "
                .replaceAll('-', ''),
            style: pw.TextStyle(
                color: PdfColors.black,
                fontStyle: pw.FontStyle.italic,
                fontSize: 13),
          )),



    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Center(
            child: pw.Center(
                child: pw.Text(
              'شكرا لكم ',
              style: pw.TextStyle(
                color: _darkColor,
                fontWeight: pw.FontWeight.bold,
              ),
            )),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['لاجمالي','السعر', 'العدد', 'العبوه', 'اسم الصنف', 'رقم'];

    return pw.TableHelper.fromTextArray(
      tableDirection: pw.TextDirection.rtl,
      border: pw.TableBorder.all(color: PdfColors.teal),
      cellAlignment: pw.Alignment.center,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: baseColor,
      ),
      headerHeight: 25,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(1.5),
        1: const pw.FixedColumnWidth(1),
        2: const pw.FixedColumnWidth(1),
        3: const pw.FixedColumnWidth(1),
        4: const pw.FixedColumnWidth(3),
        5: const pw.FixedColumnWidth(0.5),
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: accentColor,
            width: .5,
          ),
        ),
      ),

      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => products[row].getIndex(col),
        ),
      ),

    );
  }
}

String _formatCurrency(double amount) {
  return t.NumberFormat.currency(symbol: "", decimalDigits: 0).format(amount);
}

class Products {
  const Products(
    this.sku,
    this.productName,
    this.price,
    this.quantity,
    this.total,
    this.uint,
  );

  final String sku;
  final String productName;
  final String uint;
  final double price;
  final double quantity;
  final double total;



  String getIndex(int index) {
    switch (index) {
      case 0:
        return '${_formatCurrency(total)}'
            .replaceAll('-', '');
      case 1:
        return _formatCurrency(price);
      case 2:
        return  quantity.toString();

      case 3:
        return uint =='1'
    ? 'حبة':uint == '12'?
    'ك12': 'ك10 ';
        case 4:
        return productName;
      case 5:
        return sku;
    }
    return '';
  }
}
