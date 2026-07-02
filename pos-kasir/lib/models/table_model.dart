class TableModel {
  final String id;
  final String tableName;
  final int capacity;
  final String status;
  final String? section;

  TableModel({
    required this.id,
    required this.tableName,
    this.capacity = 0,
    this.status = 'Available',
    this.section,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['TableID'] ?? json['id'] ?? '',
      tableName: json['TableName'] ?? '',
      capacity: json['Capacity'] ?? 0,
      status: json['Status'] ?? 'Available',
      section: json['Section'],
    );
  }

  bool get isAvailable => status == 'Available';
}
