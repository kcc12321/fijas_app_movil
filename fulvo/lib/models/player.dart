class Player {
  int id;
  String name;
  String country;
  int age;
  String position;
  String team;
  String placeOfBirth;
  int goals;
  int number;
  String picture;
  bool isFavorite;

  Player(
      {
        required this.id,
        required this.name,
        required this.country,
        required this.age,
        required this.position,
        required this.team,
        required this.placeOfBirth,
        required this.goals,
        required this.number,
        required this.picture,
        this.isFavorite = false,
      });

// Constructor desde la API (OJO AL MAPEADO)
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      // 1. ID: Pasamos a int
      id: int.tryParse(json['id'].toString()) ?? 0,
      // 2. Name
      name: json['nombre'] ?? 'No hay nombre',

      // 3. Country
      country: json['pais'] ?? 'No hay pais',

      // 4. Edad
      age: int.tryParse(json['edad'].toString()) ?? 0,

      // 5. Position
      position: json['posicion'] ?? 'No hay posicion',

      // 6. Team
      team: json['club_actual'] ?? 'No hay club',

      // 7. Place Of Birth
      placeOfBirth: json['lugar_nacimiento'] ?? 'No hay lugar de nacimiento',

      // 8. Goals
      goals: int.tryParse(json['goles_seleccion'].toString()) ?? 0,

      // 9. Number
      number: int.tryParse(json['numero_camiseta'].toString()) ?? 0,

      // 10. Picture
      picture: json['foto'] ?? '',

      // 11. isFavorite
      isFavorite: false,

    );
  }

  // Constructor desde SQLite (Aquí la estructura es plana)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'], // En la BD sí se llamará 'id' la columna
      name: map['name'],
      country: map['country'],      // Antes decía map['name']
      age: map['age'],              // Antes decía map['name']
      position: map['position'],    // Antes decía map['name']
      team: map['team'],            // Antes decía map['name']
      placeOfBirth: map['placeOfBirth'], // Antes decía map['name']
      goals: map['goals'],          // Antes decía map['name']
      number: map['number'],        // Antes decía map['name']
      picture: map['picture'],      // Antes decía map['name']
      // SQLite guarda 1 para true y 0 para false
      isFavorite: map['isFavorite'] == 1,

    );
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'age': age,
      'position': position,
      'team': team,
      'placeOfBirth': placeOfBirth,
      'goals': goals,
      'number': number,
      'picture': picture,
      'isFavorite': (isFavorite == true) ? 1 : 0,
    };
  }
}