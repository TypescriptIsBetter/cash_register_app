import 'package:cash_register_app/settings/Settings.dart';
import 'package:cash_register_app/utils/PopupMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'CartItem.dart';

class Register extends StatefulWidget {
  final List<CartItem> cartItems = [];

  @override State<StatefulWidget> createState() => _Register();

  double getCartTotal() {
    return cartItems.reduce((a, b) => CartItem("total", a.price + b.price)).price;
  }

}

class _Register extends State<Register> {

  void addCartItem() {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == '-1') return;
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
        showDialog(context: context, builder: (context) => createPopupMessage(context, "Item Not Found", "The item you scanned is unrecognized. Try adding it in settings first."));
      }
    });
  }

  void checkout() {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == '-1') return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('bal-$code')) {
        double balance = prefs.getDouble('bal-$code');
        double total = widget.getCartTotal();
        if (balance >= total) {
          balance -= total;
          prefs.setDouble('bal-$code', balance);
          var balanceFormatted = balance.toStringAsFixed(2); // Double precision errors
          showDialog(context: context, builder: (context) => createPopupMessage(context, "Checkout", "Transaction completed. Your balance is now \$$balanceFormatted."));
          setState(() {
            widget.cartItems.clear();
          });
        } else {
          var balanceFormatted = balance.toStringAsFixed(2);
          showDialog(context: context, builder: (context) => createPopupMessage(context, "Checkout", "Your balance of \$$balanceFormatted is not enough to cover this order."));
        }
      } else {
        showDialog(context: context, builder: (context) => createPopupMessage(context, "Checkout", "Wallet not recognized."));
      }
    });
  }

  void showCheckoutMessage() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Checkout"),
      content: Text("Scan your wallet to pay."),
      actions: [
        OutlinedButton(
          child: new Text("Cancel", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              backgroundColor: MaterialStateProperty.all(Colors.red)
          ),
        ),
        OutlinedButton(
          child: new Text("OK", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
            checkout();
          },
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              backgroundColor: MaterialStateProperty.all(Colors.green)
          ),
        ),
      ],
    ));
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
        child:
          // Massive ternary used here. IMO this is the best way to do it
          // The condition is first, the Align is the true part of the condition,
          // and the column is the false part.
          // EMPTY CART MESSAGE
          (widget.cartItems.length == 0) ?
          Align(
              alignment: Alignment.center,
              child: Text("Cart is empty", textScaleFactor: 2,)
          )
            // CART ITEMS
          : Column(
            children: [
              Flexible(
                child: ListView.separated(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, i) {
                    final item = widget.cartItems[i];
                    return Align(
                      child: item.build(context),
                      alignment: Alignment.center,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                )
              ),
              // CHECKOUT BUTTON
              OutlinedButton(
                onPressed: showCheckoutMessage,
                child: new Text("Checkout: \$" + widget.getCartTotal().toStringAsFixed(2), style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    backgroundColor: MaterialStateProperty.all(Colors.blue)
                ),
              )
            ]
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