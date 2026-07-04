class TableModel {
  final String id;
  final String branchId;
  final String? branchName;
  final String tableCode;
  final String? tableName;
  final int? capacity;
  final bool isActive;
  final DateTime createdAt;

  TableModel({
    required this.id,
    required this.branchId,
    this.branchName,
    required this.tableCode,
    this.tableName,
    this.capacity,
    this.isActive = true,
    required this.createdAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['TableID'] as String? ?? json['id'] as String,
      branchId: (json['BranchID'] as String?) ?? (json['branchId'] as String?) ?? '',
      branchName: json['BranchName'] as String? ?? json['branchName'] as String?,
      tableCode: json['TableCode'] as String? ?? json['tableCode'] as String? ?? '',
      tableName: json['TableName'] as String? ?? json['tableName'] as String?,
      capacity: (json['Capacity'] as num?)?.toInt() ?? (json['capacity'] as num?)?.toInt(),
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
      'BranchID': branchId,
      'TableCode': tableCode,
      'TableName': tableName,
      'Capacity': capacity,
      'IsActive': isActive,
    };
  }

  TableModel copyWith({
    String? id,
    String? branchId,
    String? branchName,
    String? tableCode,
    String? tableName,
    int? capacity,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      tableCode: tableCode ?? this.tableCode,
      tableName: tableName ?? this.tableName,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
