import 'package:checkout_flutter/models/models.dart';

class TaxModel {
  String title;
  String? description;
  AmountModificatorModel amount;

  TaxModel({
    required this.title,
    this.description,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['title'] = title;
    data['description'] = description;
    if (amount != null) {
      data['amount'] = amount!.toJson();
    }

    return data;
  }
}
