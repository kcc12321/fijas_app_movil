class Cocktail {
  String id;
  String name;
  String image;
  String category;
  String instructions;
  String ingredients; // Aquí concatenaremos "Vodka, Limón, Sal"
  bool isFavorite;

  Cocktail({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.instructions,
    required this.ingredients,
    this.isFavorite = false,
  });

  // 1. De JSON (API) a Objeto
  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      id: json['idDrink'] ?? '0',
      name: json['strDrink'] ?? 'Sin nombre',
      image: json['strDrinkThumb'] ?? '',
      category: json['strCategory'] ?? 'General',
      instructions: json['strInstructions'] ?? 'Mezclar y servir.',

      // TRUCO PRO: Juntar ingredientes manuales en un solo String
      ingredients: _getIngredientsFrom(json),

      isFavorite: false, // La API no sabe si es favorito
    );
  }

  // Método privado para limpiar el desastre de strIngredient1, 2, 3...
  static String _getIngredientsFrom(Map<String, dynamic> json) {
    List<String> result = [];
    // La API tiene hasta 15 ingredientes posibles
    for (int i = 1; i <= 15; i++) {
      String? ingredient = json['strIngredient$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        result.add(ingredient);
      }
    }
    return result.join(", "); // Devuelve "Ron, Coca Cola, Limón"
  }

  // 2. De SQL (Base de Datos) a Objeto
  factory Cocktail.fromMap(Map<String, dynamic> map) {
    return Cocktail(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      category: map['category'],
      instructions: map['instructions'],
      ingredients: map['ingredients'],
      isFavorite: true, // Si viene de la BD, ES favorito seguro
    );
  }

  // 3. De Objeto a Mapa (Para guardar en SQL)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'instructions': instructions,
      'ingredients': ingredients,
    };
  }
}