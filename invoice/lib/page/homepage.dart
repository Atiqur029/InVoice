import 'package:flutter/material.dart';
import 'package:invoice/model/model.dart';
import 'package:invoice/pdfinoiceservice.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PdfInvoiceService pdfInvoiceService = PdfInvoiceService();
  List<Product> products = [
    Product(name: "memberShip", price: 9.99, vatInPercent: 19),
    Product(name: "Nails", price: 0.30, vatInPercent: 19),
    Product(name: "Hammer", price: 26.43, vatInPercent: 19),
    Product(name: "Hamburger", price: 5.99, vatInPercent: 7),
  ];
  int num = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: ((context, index) {
                        final currentProduct = products[index];
                        return Row(children: [
                          Expanded(child: Text(currentProduct.name)),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  "Price:${currentProduct.price.toStringAsFixed(2)} Taka"),
                              Text(
                                  "VAT ${currentProduct.vatInPercent.toStringAsFixed(0)} %"),
                            ],
                          )),
                          Expanded(
                              child: Row(
                            children: [
                              Expanded(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() => currentProduct.amount++);
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          )),
                          Expanded(
                            child: Text(
                              currentProduct.amount.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                setState(() => currentProduct.amount--);
                              },
                              icon: const Icon(Icons.remove),
                            ),
                          )
                        ]);
                      }))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text("VAT"), Text("${getVat()} €")],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text("Total"), Text("${getTotal()} €")],
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = await pdfInvoiceService.createInvoice(products);
                  pdfInvoiceService.savePDfFile("invoice_$num", data);
                  num++;
                },
                child: const Text("Create Invoice"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getTotal() => products
      .fold(0.0,
          (double prev, element) => prev + (element.price * element.amount))
      .toStringAsFixed(2);

  getVat() => products
      .fold(
          0.0,
          (double prev, element) =>
              prev +
              (element.price / 100 * element.vatInPercent * element.amount))
      .toStringAsFixed(2);
}
