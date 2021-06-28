import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings extends StatefulWidget {

  @override State<StatefulWidget> createState() => _Settings();

}

class _Settings extends State<Settings> {

  void addItem(BuildContext context) {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == "-1") return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      TextEditingController itemNameField;
      TextEditingController itemPriceField;
      // Prefill info if already exists
      if (prefs.containsKey("item-$code")) {
        String itemInfo = prefs.getString("item-$code");
        String itemName = itemInfo.split("|")[0];
        String itemCost = itemInfo.split("|")[1];
        itemNameField = TextEditingController(text: itemName);
        itemPriceField = TextEditingController(text: itemCost);
      } else {
        itemNameField = TextEditingController();
        itemPriceField = TextEditingController();
      }
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("Update item"),
          content: IntrinsicHeight(
            child: Column(
              children: [
                Text("Item name: "),
                TextField(controller: itemNameField,),
                Text("Item price: "),
                TextField(controller: itemPriceField)
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              child: new Text("Cancel", style: TextStyle(color: Colors.white),),
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                backgroundColor: MaterialStateProperty.all(Colors.red)
              ),
            ),
            OutlinedButton(
              child: new Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Prevent it from interfering with the storage mechanism
                String itemName = itemNameField.text.replaceAll("|", "");
                String itemPrice = itemPriceField.text;
                prefs.setString("item-$code", "$itemName|$itemPrice");
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  backgroundColor: MaterialStateProperty.all(Colors.green)
              ),
            )
          ],
        );
      });
    });
  }

  void removeItem(BuildContext context) {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == "-1") return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String message = "Item doesn't exist.";
      if (prefs.containsKey("item-$code")) {
        prefs.remove("item-$code");
        message = "Item deleted.";
      }
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(message),
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
    });
  }

  void getBal(BuildContext context) {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == "-1") return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String message = "$code has a balance of \$0.00";
      if (prefs.containsKey("bal-$code")) {
        double balance = prefs.getDouble("bal-$code");
        String balanceFormatted = balance.toStringAsFixed(2);
        message = "$code has a balance of \$$balanceFormatted";
      }
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Account balance"),
        content: Text(message),
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
    });
  }

  void setBal(BuildContext context) {
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE).then((code) async {
      if (code == "-1") return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      TextEditingController balanceField;
      // Prefill info if already exists
      if (prefs.containsKey("bal-$code")) {
        String balance = prefs.getDouble("bal-$code").toStringAsFixed(2);
        balanceField = TextEditingController(text: balance);
      } else {
        balanceField = TextEditingController();
      }
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("Update balance"),
          content: IntrinsicHeight(
            child: Column(
              children: [
                Text("New balance: "),
                TextField(controller: balanceField,),
              ],
            )
          ),
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
                prefs.setDouble("bal-$code", double.parse(balanceField.text));
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  backgroundColor: MaterialStateProperty.all(Colors.green)
              ),
            )
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () => Navigator.pop(context)
        )
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: "Items",
            tiles: [
              SettingsTile(
                title: "Add/Modify item",
                leading: Icon(Icons.add),
                onTap: () => addItem(context),
              ),
              SettingsTile(
                title: "Remove item",
                leading: Icon(Icons.remove),
                onTap: () => removeItem(context),
              )
            ]
          ),
          SettingsSection(
              title: "Balance",
              tiles: [
                SettingsTile(
                  title: "Get balance",
                  leading: Icon(Icons.account_balance_wallet),
                  onTap: () => getBal(context),
                ),
                SettingsTile(
                  title: "Set balance",
                  leading: Icon(Icons.account_balance),
                  onTap: () => setBal(context),
                )
              ]
          )
        ],
      )
    );
  }

}