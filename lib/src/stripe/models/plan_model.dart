class PlanModel {
  final String id;
  final String currency;
  final int unitAmount;
  final String productId;
  final String interval;
  final int intervalCount;
  final String name; // Adicionar
  final String description; // Adicionar

  PlanModel({
    required this.id,
    required this.currency,
    required this.unitAmount,
    required this.productId,
    required this.interval,
    required this.intervalCount,
    required this.name,
    required this.description,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final recurring = json['recurring'] as Map<String, dynamic>;
    final product = json['product'] as Map<String, dynamic>;

    return PlanModel(
      id: json['id'],
      currency: json['currency'],
      unitAmount: json['unit_amount'],
      productId: json['product'] is String ? json['product'] : product['id'],
      interval: recurring['interval'],
      intervalCount: recurring['interval_count'],
      name: product['name'] ?? 'Plano',
      description: product['description'] ?? '',
    );
  }

  String get formattedPrice {
    final value = unitAmount / 100; // Converte centavos para reais
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}
