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
    Product(name: "Litchi", price: 9.99, vatInPercent: 19),
    Product(name: "Coklet", price: 0.30, vatInPercent: 19),
    Product(name: "Mango", price: 26.43, vatInPercent: 19),
    Product(name: "Banana", price: 5.99, vatInPercent: 7),
  ];
  int num = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Fruit Managment"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: ((context, index) {
                          final currentProduct = products[index];
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: Text(currentProduct.name)),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          setState(
                                              () => currentProduct.amount++);
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
                  children: [const Text("VAT"), Text("${getVat()} Taka")],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("Total"), Text("${getTotal()} Taka")],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final data =
                        await pdfInvoiceService.createInvoice(products);
                    pdfInvoiceService.savePDfFile("invoice_$num", data);
                    num++;
                  },
                  child: const Text("Create Invoice"),
                ),
              ],
            ),
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
