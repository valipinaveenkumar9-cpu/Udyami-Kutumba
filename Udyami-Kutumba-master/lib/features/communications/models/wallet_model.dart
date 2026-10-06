class WalletModel {
  final String userId;
  final int coins;
  final String? id;

  WalletModel({
    required this.userId,
    required this.coins,
    this.id,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'] ?? '',
      coins: json['coins'] ?? json['balanceCoins'] ?? 0,
      id: json['_id'] ?? json['id'] ?? json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'coins': coins,
    };
  }
}
