class Category {
  final String? id;
  final String title;

  Category({this.id, required this.title});

  Category copyWith({String? id, String? title}) {
    return Category(id: id ?? this.id, title: title ?? this.title);
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], title: json['title'] ?? '');
  }
}
