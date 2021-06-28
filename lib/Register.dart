import 'package:cash_register_app/settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CartItem.dart';

class Register extends StatefulWidget {
  final List<CartItem> cartItems = [];

  @override State<StatefulWidget> createState() => _Register();

}

class _Register extends State<Register> {

  void addCartItem() {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) {
      // Couldn't find it in documentation but -1 is returned on failure
      if (code == "-1") return;
      setState(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey("item-$code")) {
          List<String> itemInfo = prefs.getString("item-$code").split('|');
          String itemName = itemInfo[0];
          double itemPrice = itemInfo[1] as double;
          widget.cartItems.add(CartItem(itemName, itemPrice));
        } else {
          showDialog(context: context, builder: (context) => AlertDialog(
            title: Text("Item Not Found"),
            content: Column(
              children: [
                Text("The item you scanned is unrecognized. Try adding it in settings first.")
              ],
            ),
            actions: [
              OutlinedButton(
                child: new Text("OK", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    backgroundColor: MaterialStateProperty.all(Colors.blue)
                ),
              )
            ],
          ));
        }
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