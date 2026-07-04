class TaxModel {
  final String id;
  final String name;
  final double rate;
  final bool isActive;
  final DateTime createdAt;

  TaxModel({
    required this.id,
    required this.name,
    required this.rate,
    this.isActive = true,
    required this.createdAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['TaxID'] as String? ?? json['id'] as String,
      name: json['TaxName'] as String? ?? json['name'] as String,
      rate: (json['TaxRate'] as num?)?.toDouble() ?? (json['rate'] as num?)?.toDouble() ?? 0,
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaxName': name,
      'TaxRate': rate,
      'IsActive': isActive,
    };
  }

  TaxModel copyWith({
    String? id,
    String? name,
    double? rate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TaxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
