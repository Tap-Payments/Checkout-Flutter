class VendorModel {
  String? id;
  String? name;

  VendorModel({
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
