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

Future<Uint8List> createReceipt(
  PdfPageFormat pageFormat, {
  date,
  name,
  num,
  amount,
      type

}) async {
  FormatText ff = FormatText();


  final invoice = CreateInvoice(
    customerName: name,
    num: num,
    date: date,
    type: type,
    amount:amount
,    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,

  );
  return await invoice.buildPdf(pageFormat);
}

class CreateInvoice {
  CreateInvoice({
    required this.customerName,
    required this.date,
    required this.amount,

    required this.type,
    required this.num,
    required this.baseColor,
    required this.accentColor,
  });

  final String customerName;
  final String date;
  final String type;
  final String num;
  final double amount;

  final PdfColor baseColor;
  final PdfColor accentColor;
  static const _darkColor = PdfColors.black;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

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
              decoration:
                  pw.BoxDecoration(border: pw.Border.all(color: baseColor)),
              child: pw.Column(children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [

                  pw.Text(" التاريخ  :",
                      style: const pw.TextStyle()),
                  pw.SizedBox(width: 10),
                  pw.Container(

                    child: pw.Text(date),
                  ),
                  pw.Text("رقم السند :",
                      style: const pw.TextStyle()),
                  pw.Container(

                    child: pw.Text(num),
                  ),
                      pw.Text("المبلغ :",
                          style: const pw.TextStyle()),
                  pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: baseColor)),


                    child: pw.Text(_formatCurrency(amount)),
                  ),

                ]),
                pw.Row(children: [
                  pw.Text(" استلمت من السيد : ",
                      style: const pw.TextStyle()),
                  pw.SizedBox(width: 10),
                  pw.Container(

                    child: pw.Text(customerName),
                  ),


                ]),
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: baseColor)),

                  child: pw.Center(child:  pw.Text(
                    "  ميلع وقدرة : ${Tafqeet.convert(amount.toInt().toString().replaceAll('-', ''))} ريال   "
                        .replaceAll('-', ''),
                    style: pw.TextStyle(
                        color: PdfColors.black,
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 13),
                  )),



                ),
                pw.SizedBox(width: 10),
              ])),
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
                    ' سند $type',
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
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.end, children: []),
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
}

String _formatCurrency(double amount) {
  return t.NumberFormat.currency(symbol: "", decimalDigits: 0).format(amount);
}
