import 'package:checkout_flutter/models/models.dart';

class DestinationModel {
  TapCurrencyCode? currency;
  String identifier;
  String? descriptionText;
  String? reference;
  double amount;
  TransferModel? transfer;

  DestinationModel({
    required this.amount,
    required this.identifier,
    this.currency,
    this.descriptionText,
    this.reference,
    this.transfer,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['currency'] = currency;
    data['id'] = identifier;
    data['amount'] = amount;
    data['description'] = descriptionText;
    data['reference'] = reference;
    data['transfer'] = transfer;

    return data;
  }
}
