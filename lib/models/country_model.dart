class CountryModel {
  String isoCode;

  CountryModel({
    required this.isoCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['isoCode'] = isoCode;
    return data;
  }
}
