import 'package:checkout_flutter/models/models.dart';

class TapCustomerModel {
  String? firstName;
  String? middleName;
  String? lastName;
  String? descriptionText;
  String? title;
  String? nationality;
  String? locale;
  String? identifier;
  TapPhoneModel? phoneNumber;
  AddressModel? address;
  Map<String, dynamic>? metadata;
  TapCurrencyCode? currency;
  TapEmailAddressModel? emailAddress;

  TapCustomerModel({
    this.firstName,
    this.middleName,
    this.lastName,
    this.descriptionText,
    this.title,
    this.nationality,
    this.identifier,
    this.locale,
    this.phoneNumber,
    this.address,
    this.currency,
    this.emailAddress,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = identifier;
    data['first_name'] = firstName;
    data['middle_name'] = identifier;
    data['last_name'] = identifier;
    data['description'] = firstName;
    data['title'] = identifier;
    data['nationality'] = firstName;
    data['locale'] = locale;
    data['metadata'] = metadata;
    data['currency'] = currency;

    if (phoneNumber != null) {
      data['phone'] = phoneNumber!.toJson();
    }

    if (emailAddress != null) {
      data['email'] = emailAddress!.toJson();
    }

    return data;
  }
}
