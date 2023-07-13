import 'package:checkout_flutter/models/models.dart';

class ShippingModel {
  String name;
  String? descriptionText;
  double amount;
  TapCurrencyCode currency;
  String? recipientName;
  AddressModel? address;
  ShippingProviderModel? provider;

  ShippingModel({
    this.descriptionText,
    required this.currency,
    required this.amount,
    this.address,
    required this.name,
    this.provider,
    this.recipientName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['name'] = name;
    data['description'] = descriptionText;
    data['amount'] = amount;
    data['currency'] = currency;
    data['recipient_name'] = recipientName;

    if (address != null) {
      data['address'] = address!.toJson();
    }

    if (provider != null) {
      data['provider'] = provider!.toJson();
    }

    return data;
  }
}
