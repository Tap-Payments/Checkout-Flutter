class ReceiptModel {
  String? identifier;
  bool email;
  bool sms;

  ReceiptModel({
    this.identifier,
    required this.email,
    required this.sms,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = identifier;
    data['email'] = email;
    data['sms'] = sms;

    return data;
  }
}
