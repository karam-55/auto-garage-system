import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final String id;
  final String name;
  final String? description;
  final double priceSYP;
  final int? estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.priceSYP,
    this.estimatedDurationMinutes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? priceSYP,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceSYP: priceSYP ?? this.priceSYP,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
