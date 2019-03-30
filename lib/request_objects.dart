class PaymentDataRequest {

  final String publishableKey;
  final String merchantName;
  final String country;
  final String currencyCode;
  final List<PaymentItem> items;

  PaymentDataRequest({
    this.publishableKey,
    this.merchantName,
    this.country,
    this.currencyCode,
    this.items});

  Map toJson() => {"publishableKey":publishableKey, "merchantName":merchantName, "country":country, "currencyCode":currencyCode, "items":items};
}

class PaymentItem {
  final String label;
  final double amount;

  PaymentItem({
  this.label,
  this.amount});

  Map toJson() => {"label":label, "amount":amount};
}