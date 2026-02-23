class CategoryModel {
  String name;
  String type;

  CategoryModel({
    required this.name, 
    required this.type
  });

  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(name: "Mes Entrées", type: "entrée"),
      CategoryModel(name: "Mes Plats", type: "plat"),
      CategoryModel(name: "Mes Desserts", type: "dessert"),
    ];
  }
}