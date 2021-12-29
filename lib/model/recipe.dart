class Recipe {
  final int recipeId;
  final String name;
  final String description;
  final String configLink;
  final int abv;
  final int ibu;
  final int og;
  final int fg;
  final int ba;
  final double price;

  Recipe({
    required this.recipeId,
    required this.name,
    required this.description,
    required this.configLink,
    required this.abv,
    required this.ibu,
    required this.og,
    required this.fg,
    required this.ba,
    required this.price,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipeId'] ?? -1,
      name: json['name'] as String,
      description: json['description'] as String,
      configLink: json['configLink'] as String,
      abv: json['abv'] ?? -1,
      ibu: json['ibu'] ?? -1,
      og: json['og'] ?? -1,
      fg: json['fg'] ?? -1,
      ba: json['ba'] ?? -1,
      price: json['price'] ?? 0,
    );
  }


}
