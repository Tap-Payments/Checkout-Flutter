import 'package:checkout_flutter/models/models.dart';

class AddressModel {
  AddressType? type;
  CountryModel? country;

  String? line1;
  String? line2;
  String? line3;
  String? line4;
  String? city;
  String? state;
  String? zipCode;
  String? countryGovernorate;
  String? area;
  String? block;
  String? avenue;
  String? street;
  String? buildingHouse;
  String? floor;
  String? apartment;
  String? office;
  String? postalBox;
  String? postalCode;

  AddressModel({
    this.type,
    this.country,
    this.line1,
    this.line2,
    this.line3,
    this.line4,
    this.city,
    this.state,
    this.zipCode,
    this.countryGovernorate,
    this.area,
    this.block,
    this.avenue,
    this.street,
    this.buildingHouse,
    this.floor,
    this.apartment,
    this.office,
    this.postalCode,
    this.postalBox,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    switch (type) {
      case AddressType.Residential:
        data['RESIDENTIAL'] = "RESIDENTIAL";
        break;
      case AddressType.Commercial:
        data['COMMERCIAL'] = "COMMERCIAL";
        break;
      default:
    }

    if (country != null) {
      data['country'] = country!.toJson();
    }

    data['line1'] = line1;
    data['line2'] = line2;
    data['line3'] = line3;
    data['line4'] = line4;
    data['city'] = city;
    data['state'] = state;
    data['zip_code'] = zipCode;
    data['country_governorate'] = countryGovernorate;
    data['area'] = area;
    data['block'] = block;
    data['avenue'] = avenue;
    data['street'] = street;
    data['building'] = buildingHouse;
    data['floor'] = floor;
    data['apartment'] = apartment;
    data['office'] = office;
    data['po_box'] = postalBox;
    data['postal_code'] = postalCode;

    return data;
  }
}
