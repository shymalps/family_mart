class CategoryFamily {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  CategoryFamily({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryFamily.fromJson(Map<String, dynamic> json) {
    return CategoryFamily(
      id: json['id'] as int? ?? 0, // Handle null case with default value
      name: json['name'] as String? ?? '', // Handle null case with default value
      createdAt: json['created_at'] as String? ?? '', // Handle null case
      updatedAt: json['updated_at'] as String? ?? '', // Handle null case
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}