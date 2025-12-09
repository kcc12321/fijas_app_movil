// To parse this JSON data, do
//
//     final pokemon = pokemonFromJson(jsonString);

import 'dart:convert';

Pokemon pokemonFromJson(String str) => Pokemon.fromJson(json.decode(str));

String pokemonToJson(Pokemon data) => json.encode(data.toJson());

class Pokemon {
  int id;
  String name;
  String image;
  String types;
  int weight;
  int height;
  bool isCaptured;

  Pokemon({
    required this.id,
    required this.name,
    required this.image,
    required this.types,
    required this.weight,
    required this.height,
    this.isCaptured = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
    id: json["id"],
    name: json["name"],
    // Imagen Oficial HD
    image: json['sprites']['other']['official-artwork']['front_default'] ??
        json['sprites']['front_default'] ?? '',
    // MEJORA: Unimos todos los tipos con una coma
    types: (json['types'] as List)
        .map((item) => item['type']['name'].toString())
        .join(', '), // Ej: "fire, flying"
    weight: json["weight"],
    height: json["height"],
    isCaptured: false

  );

  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    // La lista solo nos da: { "name": "...", "url": "https://.../1/" }

    // 1. Extraemos el ID de la URL
    final url = json['url'] as String;
    // La URL termina en /id/, así que partimos el string y sacamos el penúltimo pedazo
    final idString = url.split('/')[6];
    final id = int.parse(idString);

    return Pokemon(
      id: id,
      name: json['name'],
      // 2. Construimos la imagen manualmente (Truco del examen)
      image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",

      // 3. Rellenamos lo que no viene en la lista con valores temporales
      types: '???',
      weight: 0,
      height: 0,
      isCaptured: false,
    );
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      types: map['types'],
      weight: map['weight'],
      height: map['height'],
      isCaptured: true, // Si viene de la BD, ES favorito seguro
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'types': types,
      'weight': weight,
      'height': height,
    };
  }




  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "types": types,
    "weight": weight,
    "height": height,
  };
}
