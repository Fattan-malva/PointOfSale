class BranchModel {
  final String id;
  final String code;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;

  BranchModel({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
    required this.createdAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['BranchID'] as String? ?? json['id'] as String,
      code: (json['BranchCode'] as String? ?? json['code'] as String?) ?? '',
      name: json['BranchName'] as String? ?? json['name'] as String,
      address: json['Address'] as String? ?? json['address'] as String?,
      phone: json['Phone'] as String? ?? json['phone'] as String?,
      email: json['Email'] as String? ?? json['email'] as String?,
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
      'BranchCode': code,
      'BranchName': name,
      'Address': address,
      'Phone': phone,
      'Email': email,
      'IsActive': isActive,
    };
  }

  BranchModel copyWith({
    String? id,
    String? code,
    String? name,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
