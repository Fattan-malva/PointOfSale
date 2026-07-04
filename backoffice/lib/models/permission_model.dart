class PermissionModel {
  final String id;
  final String name;
  final String? description;
  final String? module;
  bool isAssigned;

  PermissionModel({
    required this.id,
    required this.name,
    this.description,
    this.module,
    this.isAssigned = false,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['PermissionID'] as String? ?? json['id'] as String,
      name: json['PermissionName'] as String? ?? json['name'] as String,
      description: json['Description'] as String? ?? json['description'] as String?,
      module: json['Module'] as String? ?? json['module'] as String?,
      isAssigned: json['IsAssigned'] as bool? ?? json['isAssigned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PermissionName': name,
      'Description': description,
      'Module': module,
    };
  }
}
