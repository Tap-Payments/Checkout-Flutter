import 'package:checkout_flutter/models/models.dart';

class AuthorizeActionModel {
  AuthorizeActionType type;
  int timeInHours;

  AuthorizeActionModel({
    required this.type,
    required this.timeInHours,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['time'] = timeInHours;
    switch (type) {
      case AuthorizeActionType.Capture:
        data['type'] = "CAPTURE";
        break;
      case AuthorizeActionType.Void:
        data['type'] = "VOID";
        break;
      default:
    }

    return data;
  }
}
