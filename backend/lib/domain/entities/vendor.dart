class Vendor {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final DateTime createdAt;

  Vendor({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.taxNumber,
    required this.createdAt,
  });

  Vendor copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? taxNumber,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'tax_number': taxNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      taxNumber: json['tax_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
