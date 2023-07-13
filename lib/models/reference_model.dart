class ReferenceModel {
  String? acquirer;
  String? gatewayReference;
  String? paymentReference;
  String? trackingNumber;
  String? transactionNumber;
  String? orderNumber;
  String? gosellID;

  ReferenceModel({
    this.acquirer,
    this.gatewayReference,
    this.gosellID,
    this.orderNumber,
    this.paymentReference,
    this.trackingNumber,
    this.transactionNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['acquirer'] = acquirer;
    data['gateway'] = gatewayReference;
    data['payment'] = paymentReference;
    data['track'] = trackingNumber;
    data['transaction'] = transactionNumber;
    data['order'] = orderNumber;
    data['gosell_id'] = gosellID;

    return data;
  }
}
