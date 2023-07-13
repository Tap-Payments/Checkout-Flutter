class ShippingProviderModel {
  String id;
  String name;

  ShippingProviderModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
