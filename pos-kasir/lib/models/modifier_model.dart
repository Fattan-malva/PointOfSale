class ModifierModel {
  final String id;
  final String modifierName;
  final bool isRequired;
  final int maxSelection;
  final List<ModifierOptionModel> options;

  ModifierModel({
    required this.id,
    required this.modifierName,
    this.isRequired = false,
    this.maxSelection = 1,
    this.options = const [],
  });

  factory ModifierModel.fromJson(Map<String, dynamic> json) {
    return ModifierModel(
      id: json['ModifierID'] ?? json['id'] ?? '',
      modifierName: json['ModifierName'] ?? '',
      isRequired: json['IsRequired'] ?? false,
      maxSelection: json['MaxSelection'] ?? 1,
      options:
          (json['Options'] as List<dynamic>?)
              ?.map((o) => ModifierOptionModel.fromJson(o))
              .toList() ??
          [],
    );
  }
}

class ModifierOptionModel {
  final String id;
  final String optionName;
  final double additionalPrice;

  ModifierOptionModel({
    required this.id,
    required this.optionName,
    this.additionalPrice = 0,
  });

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) {
    return ModifierOptionModel(
      id: json['ModifierOptionID'] ?? json['id'] ?? '',
      optionName: json['OptionName'] ?? '',
      additionalPrice: (json['AdditionalPrice'] ?? 0).toDouble(),
    );
  }
}
