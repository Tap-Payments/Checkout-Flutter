class SecretKeyModel {
  String? sandbox;
  String? production;

  SecretKeyModel({
    required this.sandbox,
    required this.production,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['sandbox'] = sandbox;
    data['production'] = production;
    return data;
  }
}
