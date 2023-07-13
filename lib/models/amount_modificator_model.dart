import 'package:checkout_flutter/models/models.dart';

class AmountModificatorModel {
  AmountModificationModelType? type;
  String? value;
  String minFee;
  String maxFee;

  AmountModificatorModel({
    this.type,
    this.value,
    required this.minFee,
    required this.maxFee,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['value'] = value;
    data['minimum_fee'] = minFee;
    data['maximum_fee'] = maxFee;

    switch (type) {
      case AmountModificationModelType.Percentage:
        data['type'] = "percentage";
        break;
      case AmountModificationModelType.Fixed:
        data['type'] = "fixed";
        break;
      default:
    }

    return data;
  }
}
