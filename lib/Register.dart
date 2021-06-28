import 'package:cash_register_app/settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'CartItem.dart';

class Register extends StatefulWidget {
  final List<CartItem> cartItems = [];

  @override State<StatefulWidget> createState() => _Register();

}

class _Register extends State<Register> {

  void addCartItem() {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((value) {
      setState(() async {

        widget.cartItems.add(CartItem(value, 20.01));
      });
    });
  }

  

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cash Register"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings())
                );
              },
              child: Icon(Icons.settings)
            )
          )
        ]
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, i) {
          final item = widget.cartItems[i];
          return item.build(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        child: Icon(Icons.add),
        onPressed: addCartItem,
      ),
    );
  }

}