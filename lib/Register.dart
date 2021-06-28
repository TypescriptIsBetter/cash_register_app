import 'package:cash_register_app/settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'CartItem.dart';

class Register extends StatefulWidget {
  final List<CartItem> cartItems = [];

  @override State<StatefulWidget> createState() => _Register();

}

class _Register extends State<Register> {

  void addCartItem() {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("item-$code")) {
        List<String> itemInfo = prefs.getString("item-$code").split('|');
        developer.log(itemInfo[0] + ' ' + itemInfo[1]);
        String itemName = itemInfo[0];
        double itemPrice = double.parse(itemInfo[1]);
        setState(() {
          widget.cartItems.add(CartItem(itemName, itemPrice));
        });
      } else {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: Text("Item Not Found"),
          content: Text("The item you scanned is unrecognized. Try adding it in settings first."),
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
      body: Padding(
        child: ListView.separated(
          itemCount: (widget.cartItems.length == 0 ? 1 : widget.cartItems.length) + 1,
          itemBuilder: (context, i) {
            if (widget.cartItems.length == 0 && i == 0) {
              return Align(
                  alignment: Alignment.center,
                  child: Text("Cart is empty", textScaleFactor: 2,)
              );
              // Erroring out without length check here. Unsure why.
            } else if (widget.cartItems.length != 0 && i != widget.cartItems.length) {
              final item = widget.cartItems[i];
              return Align(
                child: item.build(context),
                alignment: Alignment.center,
              );
            } else {
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: OutlinedButton(
                    onPressed: () {},
                    child: new Text("Checkout", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        backgroundColor: MaterialStateProperty.all(Colors.blue)
                    ),
                  )
              );
            }
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        child: Icon(Icons.add),
        onPressed: addCartItem,
      ),
    );
  }

}