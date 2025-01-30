import 'dart:typed_data';

import 'package:adminaccountingapp/consts/string.dart';
import 'package:adminaccountingapp/consts/text_format.dart';
import 'package:adminaccountingapp/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart' as t;

Future<Uint8List> generateInvoice(
  PdfPageFormat pageFormat,
  List<Report> o, {
  date,
  name,
  address,
  phone,
  required username,
}) async {
  FormatText f = FormatText();
  var t = 0.0;
  final products = List.generate(o.length, (i) {
    t = t + o[i].onHim - o[i].forHim;

    return Productd(
        "${i + 1}",
        "${f.dateFormat(o[i].id.toDate())}",
        o[i].description,
        double.parse(o[i].onHim.toString()),
        double.parse(o[i].forHim.toString()),
        t);
  });
  final invoice = ReportInvoice(
    products: products,
    customerName: name,
    phone: phone,
    date: date,
    customerAddress: address,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,
    username: username,
  );
  return await invoice.buildPdf(pageFormat);
}

class ReportInvoice {
  ReportInvoice({
    required this.products,
    required this.customerName,
    required this.date,
    required this.username,
    required this.customerAddress,
    required this.phone,
    required this.baseColor,
    required this.accentColor,
  });

  final List<Productd> products;
  final String customerName;
  final String date;
  final String customerAddress;
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
          previousValue += element.price - element.quantity);


  late final logoImage;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();
    logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: 300,
                child: pw.Row(children: [
                  pw.Container(
                      width: 60,
                      color: baseColor,
                      child: pw.Text(" اسم العميل: ",
                          style: const pw.TextStyle(color: PdfColors.white))),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 300,
                    child: pw.Text(customerName),
                  ),
                  pw.Container(
                      width: 60,
                      color: baseColor,
                      child: pw.Text("  الهاتف:   ",
                          style: const pw.TextStyle(color: PdfColors.white))),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 300,
                    child: pw.Text(phone),
                  )
                ]),
              ),
            ],
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
                  child: pw.Column(children: [
                    pw.Text(
                      'كشف حساب تفصيلي ',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    pw.Text(
                      '$date',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ]),
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
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            color: baseColor,
          ),
          pw.Row(
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
              pw.Text(
                '  تاريخ  التقرير  ${t.DateFormat('yyyy-MM-dd  hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
              pw.Container(
                height: 100,
                width: 100,
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(username),
                    ]),
              ),
            ],
          )
        ]);
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
    final number = int.tryParse(_total.toString());
    return pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: baseColor)),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              child: pw.Text(
                "  الاجمالي : ${Tafqeet.convert(_total.toInt().toString().replaceAll('-', ''))} ريال ${_formatCurrency(_total)}${_total.isNegative ? '  له  ' : "  علية  "} "
                    .replaceAll('-', ''),
                style: pw.TextStyle(
                    color: PdfColors.black,
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 13),
              ),
            ),
          ],
        ));
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
    const tableHeaders = ['الرصيد', 'دائن', 'مدين', 'البيان', 'التاريخ', ""];

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
        3: const pw.FixedColumnWidth(3),
        4: const pw.FixedColumnWidth(1),
        5: const pw.FixedColumnWidth(0.3),
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

class Productd {
  const Productd(
    this.no,
    this.sku,
    this.productName,
    this.price,
    this.quantity,
    this.total,
  );

  final String sku;
  final String no;
  final String productName;
  final double price;
  final double quantity;
  final double total;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return '${_formatCurrency(total)}${total.isNegative ? '  له   ' : "  علية  "} '
            .replaceAll('-', '');
      case 1:
        return _formatCurrency(quantity);
      case 2:
        return _formatCurrency(price);

      case 3:
        return productName;
      case 4:
        return sku;
      case 5:
        return no;
    }
    return '';
  }
}

String convertNumberToArabic(int number) {
  final formatArabic = NumberFormat.currency(locale: 'ar', symbol: '');
  final arabicText = formatArabic.format(number);

  // Convert the integer part to words
  final integerWords = _convertNumberToWords(number);

  // Combine the integer words and the fractional part
  final result = '$integerWords ';
  return result;
}

String _convertNumberToWords(int number) {
  List<String> arabicUnits = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة'
  ];
  List<String> arabicTens = [
    '',
    'عشرة',
    'عشرون',
    'ثلاثون',
    'أربعون',
    'خمسون',
    'ستون',
    'سبعون',
    'ثمانون',
    'تسعون'
  ];
  List<String> arabicHundreds = [
    '',
    'مئة',
    'مئتان',
    'ثلاثمائة',
    'أربعمائة',
    'خمسمائة',
    'ستمائة',
    'سبعمائة',
    'ثمانمائة',
    'تسعمائة'
  ];
  List<String> arabicThousands = [
    '',
    'ألف',
    'ألفان',
    'ثلاثة آلاف',
    'أربعة آلاف',
    'خمسة آلاف',
    'ستة آلاف',
    'سبعة آلاف',
    'ثمانية آلاف',
    'تسعة آلاف'
  ];
  List<String> arabicMillions = [
    '',
    'مليون',
    'مليونان',
    'ثلاثة ملايين',
    'أربعة ملايين',
    'خمسة ملايين',
    'ستة ملايين',
    'سبعة ملايين',
    'ثمانية ملايين',
    'تسعة ملايين'
  ];
  List<String> arabicBillions = [
    '',
    'مليار',
    'ملياران',
    'ثلاثة مليارات',
    'أربعة مليارات',
    'خمسة مليارات',
    'ستة مليارات',
    'سبعة مليارات',
    'ثمانية مليارات',
    'تسعة مليارات'
  ];

  if (number < 10) {
    return arabicUnits[number];
  } else if (number < 100) {
    return arabicTens[number ~/ 10] +
        (number % 10 > 0 ? ' ' + _convertNumberToWords(number % 10) : '');
  } else if (number < 1000) {
    return arabicHundreds[number ~/ 100] +
        (number % 100 > 0 ? ' ' + _convertNumberToWords(number % 100) : '');
  } else if (number < 1000000) {
    return arabicThousands[number ~/ 1000] +
        (number % 1000 > 0 ? ' ' + _convertNumberToWords(number % 1000) : '');
  } else if (number < 1000000000) {
    return arabicMillions[number ~/ 1000000] +
        (number % 1000000 > 0
            ? ' ' + _convertNumberToWords(number % 1000000)
            : '');
  } else {
    return arabicBillions[number ~/ 1000000000] +
        (number % 1000000000 > 0
            ? ' ' + _convertNumberToWords(number % 1000000000)
            : '');
  }
}
