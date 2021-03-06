import 'package:flutter/material.dart';

class CartItem {
  final String itemName;
  final double price;

  /// Creates a CartItem
  /// @param itemName The name of the item
  /// @param price The item price
  CartItem(this.itemName, this.price);

  Widget build(BuildContext context) {
    return
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$itemName', textScaleFactor: 2,),
            // Hide double imprecision
            Text('\$' + price.toStringAsFixed(2), textScaleFactor: 2,)
          ],
        )
      );
  }

}