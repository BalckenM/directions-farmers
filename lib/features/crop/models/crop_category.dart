class CropCategory {
  const CropCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.cropCount,
    required this.description,
  });

  final String id;
  final String name;
  final String icon;
  final String color;
  final int cropCount;
  final String description;

  factory CropCategory.fromJson(Map<String, dynamic> json) => CropCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String,
        cropCount: (json['crop_count'] as num).toInt(),
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'crop_count': cropCount,
        'description': description,
      };
}
