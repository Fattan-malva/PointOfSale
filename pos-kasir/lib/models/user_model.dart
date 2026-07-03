/// User Model - Domain Model untuk User
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'manager', 'cashier', 'customer'
  final String? branchId;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.branchId,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['UserID'] ?? json['id']) as String,
      email: (json['Username'] ?? json['email'] ?? '') as String,
      name: (json['FullName'] ?? json['name']) as String,
      role: (json['RoleName'] ?? json['role'] ?? '') as String,
      branchId: json['BranchID'] ?? json['branchId'] as String?,
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'branchId': branchId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method untuk immutability
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? branchId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
