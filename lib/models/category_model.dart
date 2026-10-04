class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'book',
    this.colorHex = '#4F46E5',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? 'book',
      colorHex: json['colorHex']?.toString() ?? '#4F46E5',
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_hex': colorHex,
    };
  }

  factory CategoryModel.fromSupabaseJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconName: (json['icon_name'] ?? json['iconName'])?.toString() ?? 'book',
      colorHex: (json['color_hex'] ?? json['colorHex'])?.toString() ?? '#4F46E5',
    );
  }
}

class CategoryProgressModel {
  final CategoryModel category;
  final int totalWords;
  final int learnedWords;
  final int progressPercent;

  CategoryProgressModel({
    required this.category,
    required this.totalWords,
    required this.learnedWords,
    required this.progressPercent,
  });
}
