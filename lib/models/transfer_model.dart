import 'package:checkout_flutter/models/models.dart';

class TransferModel {
  TapCurrencyCode? currency;
  String? identifier;
  double? reversedAmount;
  List<String>? reversalIdentifiers;
  double? amount;

  TransferModel({
    this.currency,
    this.identifier,
    this.amount,
    this.reversalIdentifiers,
    this.reversedAmount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['currency'] = currency;
    data['id'] = identifier;
    data['amount'] = amount;
    data['reversed_amount'] = reversedAmount;
    data['reversal_id'] = reversalIdentifiers;

    return data;
  }
}
