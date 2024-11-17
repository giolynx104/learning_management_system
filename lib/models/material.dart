import 'package:intl/intl.dart';
class Material{
  String class_id;
  int material_id;
  String material_name;
  String? description;
  String? material_link; // Có thể nullable nếu không phải lúc nào cũng có link
  String material_type;
  Material({
    required this.class_id,
    required this.material_id,
    required this.material_name,
    this.description,
    this.material_link,
    required this.material_type
  });
  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      class_id: json['class_id'],
      material_id: json['id'],
      material_name: json['material_name'],
      description: json['description'],
      material_link: json['material_link'],
      material_type: json['material_type'],
    );
  }
}