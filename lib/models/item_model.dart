import 'package:checkout_flutter/models/models.dart';

class ItemModel {
  String? title;
  String? itemDescription;
  String? productID;
  String? fulfillmentService;
  String? category;
  String? itemCode;
  String? tags;
  String? accountCode;
  VendorModel? vendor;
  bool? requiresShipping;
  double? price;
  List<AmountModificatorModel>? discount;
  List<TaxModel>? taxes;
  double totalAmount;
  double quantity;
  TapCurrencyCode? currency;

  ItemModel({
    this.title,
    this.currency,
    this.accountCode,
    this.category,
    this.discount,
    this.fulfillmentService,
    this.itemCode,
    this.itemDescription,
    this.price,
    this.productID,
    required this.quantity,
    this.requiresShipping,
    this.tags,
    this.taxes,
    required this.totalAmount,
    this.vendor,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['title'] = title;
    data['currency'] = currency;
    data['accountCode'] = accountCode;
    data['category'] = category;
    data['fulfillmentService'] = fulfillmentService;
    data['itemCode'] = itemCode;
    data['itemDescription'] = itemDescription;
    data['price'] = price;
    data['productID'] = productID;
    data['quantity'] = quantity;
    data['requiresShipping'] = requiresShipping;
    data['totalAmount'] = totalAmount;
    data['tags'] = tags;
    if (taxes != null) {
      data['taxes'] = taxes!.map((v) => v.toJson()).toList();
    }
    if (discount != null) {
      data['discount'] = discount!.map((v) => v.toJson()).toList();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }

    return data;
  }
}
