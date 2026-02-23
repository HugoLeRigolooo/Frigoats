class PlatsModel {
  int? id;
  String name;
  String duration;
  String type;
  String photo;
  double prix;
  List<String> ingredients;

  PlatsModel({
    this.id,
    required this.name,
    required this.duration,
    required this.type,
    required this.photo,
    required this.prix,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'type': type,
      'photo': photo,
      'prix': prix,
      'ingredients': ingredients.join(", ")
    };
  }

  factory PlatsModel.fromMap(Map<String, dynamic> map) {
    return PlatsModel(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      type: map['type'],
      photo: map['photo'],
      prix: map['prix'],
      ingredients: map['ingredients'] != null ? (map['ingredients'] as String).split(", ").map((e) => e.trim()).toList() : [],
    );
  }
}