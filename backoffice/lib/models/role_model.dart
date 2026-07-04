class RoleModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['RoleID'] as String? ?? json['id'] as String,
      name: json['RoleName'] as String? ?? json['name'] as String,
      description: json['Description'] as String? ?? json['description'] as String?,
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RoleName': name,
      'Description': description,
      'IsActive': isActive,
    };
  }
}
