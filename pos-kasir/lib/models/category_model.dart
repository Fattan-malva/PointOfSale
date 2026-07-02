class CategoryModel {
  final String id;
  final String categoryName;
  final String? description;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['CategoryID'] ?? json['id'] ?? '',
      categoryName: json['CategoryName'] ?? '',
      description: json['Description'],
      sortOrder: json['SortOrder'] ?? 0,
      isActive: json['IsActive'] ?? true,
    );
  }
}
