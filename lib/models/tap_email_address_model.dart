class TapEmailAddressModel {
  String value;

  TapEmailAddressModel({
    required this.value,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['value'] = value;
    return data;
  }
}
