import 'dart:io';

import 'package:flutter/services.dart';
import 'package:invoice/model/model.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomRow {
  final String itemName;
  final String itemPrice;
  final String amount;
  final String total;
  final String vat;

  CustomRow(this.itemName, this.itemPrice, this.amount, this.total, this.vat);
}

class PdfInvoiceService {
  Future<Uint8List> createHelloWorld() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> createInvoice(List<Product> soldProduct) async {
    final pdf = pw.Document();
    final List<CustomRow> elements = [
      CustomRow("Item Name", "Item Price", "Amount", "Total", "Vat"),
      for (var product in soldProduct)
        CustomRow(
            product.name,
            product.price.toString(),
            product.amount.toString(),
            (product.price * product.amount).toStringAsFixed(2),
            (product.vatInPercent * product.price).toStringAsFixed(2)),
      CustomRow(
        "Sub Total",
        "",
        "",
        "",
        "${getSubTotal(soldProduct)} Taka",
      ),
      CustomRow(
        "Vat",
        "",
        "",
        "",
        "${vatTotal(soldProduct)} Taka",
      ),
      CustomRow(
        "Vat Total",
        "",
        "",
        "",
        "${(double.parse(getSubTotal(soldProduct)) + double.parse(vatTotal(soldProduct))).toStringAsFixed(2)} Taka",
      )
    ];
    final image = (await rootBundle.load("assets/flutter_explained_logo.jpg"))
        .buffer
        .asUint8List();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: ((pw.Context context) {
          return pw.Column(children: [
            pw.Image(pw.MemoryImage(image),
                width: 150, height: 150, fit: pw.BoxFit.cover),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text("Customer Name"),
                    pw.Text("Customer Address"),
                    pw.Text("Customer City"),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text("Max Weber"),
                    pw.Text("Weird Street Name 1"),
                    pw.Text("77662 Not my City"),
                    pw.Text("Vat-id: 123456"),
                    pw.Text("Invoice-Nr: 00001")
                  ],
                )
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Text(
                "Dear Customer, thanks for buying at Flutter Explained, feel free to see the list of items below."),
            pw.SizedBox(height: 25),
            itemColumn(elements),
            pw.SizedBox(height: 25),
            pw.Text("Thanks for your trust, and till the next time."),
            pw.SizedBox(height: 25),
            pw.Text("Kind regards,"),
            pw.SizedBox(height: 25),
            pw.Text("Max Weber")
          ]);
        })));

    return pdf.save();
  }

  String getSubTotal(List<Product> soldProducts) {
    return soldProducts
        .fold(
            0.0,
            (previousValue, element) =>
                previousValue + (element.amount + element.price))
        .toStringAsFixed(2);
  }

  String vatTotal(List<Product> soldproduct) {
    return soldproduct
        .fold(
            0.0,
            (previousValue, next) =>
                previousValue + ((next.price) / 100 * next.vatInPercent))
        .toStringAsFixed(2);
  }

  pw.Expanded itemColumn(List<CustomRow> elements) {
    return pw.Expanded(
        child: pw.Column(children: [
      for (var element in elements)
        pw.Row(children: [
          pw.Expanded(
              child: pw.Text(element.itemName, textAlign: pw.TextAlign.left)),
          pw.Expanded(
              child: pw.Text(element.itemPrice, textAlign: pw.TextAlign.right)),
          pw.Expanded(
              child: pw.Text(element.amount, textAlign: pw.TextAlign.right)),
          pw.Expanded(
              child: pw.Text(element.total, textAlign: pw.TextAlign.right)),
          pw.Expanded(
              child: pw.Text(element.vat, textAlign: pw.TextAlign.right)),
        ])
    ]));
  }

  Future<void> savePDfFile(String filename, Uint8List bytelist) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$filename.pdf";
    final file = File(filePath);
    await file.writeAsBytes(bytelist);
    await OpenFile.open(filePath);
  }
}
