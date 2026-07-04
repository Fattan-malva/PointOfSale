class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final int? sortOrder;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder,
    this.isActive = true,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['CategoryID'] as String? ?? json['id'] as String,
      name: json['CategoryName'] as String? ?? json['name'] as String,
      description: json['Description'] as String? ?? json['description'] as String?,
      sortOrder: (json['SortOrder'] as num?)?.toInt() ?? (json['sortOrder'] as num?)?.toInt(),
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
      'CategoryName': name,
      'Description': description,
      'SortOrder': sortOrder,
      'IsActive': isActive,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
