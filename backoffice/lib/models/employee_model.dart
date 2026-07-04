class EmployeeModel {
  final String id;
  final String fullName;
  final String username;
  final String? roleId;
  final String? roleName;
  final String? branchId;
  final String? branchName;
  final bool isActive;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.roleId,
    this.roleName,
    this.branchId,
    this.branchName,
    this.isActive = true,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['UserID'] as String? ?? json['id'] as String,
      fullName: json['FullName'] as String? ?? json['fullName'] as String? ?? json['name'] as String,
      username: json['Username'] as String? ?? json['username'] as String,
      roleId: json['RoleID'] as String? ?? json['roleId'] as String?,
      roleName: json['RoleName'] as String? ?? json['roleName'] as String? ?? json['role'] as String?,
      branchId: json['BranchID'] as String? ?? json['branchId'] as String?,
      branchName: json['BranchName'] as String? ?? json['branchName'] as String?,
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
      'FullName': fullName,
      'Username': username,
      'RoleID': roleId,
      'BranchID': branchId,
      'IsActive': isActive,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? roleId,
    String? roleName,
    String? branchId,
    String? branchName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
