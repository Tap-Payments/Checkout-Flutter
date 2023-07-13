class TapPhoneModel {
  String isdNumber;
  String phoneNumber;

  TapPhoneModel({
    required this.isdNumber,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['country_code'] = isdNumber;
    data['number'] = phoneNumber;
    return data;
  }
}
