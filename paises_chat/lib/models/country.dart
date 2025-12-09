class Country {
    String name;
    String id;
    String capital;
    int population;
    String flagUrl;
    bool isFavorite;
    String region;
    List<double> latlng;

  Country(
      {required this.name,
        required this.id,
        required this.capital,
        required this.population,
        required this.flagUrl,
        this.isFavorite = false,
        required this.region,
        required this.latlng,
      });

// Constructor desde la API (OJO AL MAPEADO)
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      // 1. ID: Usamos el código de 3 letras
      id: json['cca3'] ?? 'NO-ID',

      // 2. Name: Entramos al mapa 'name' y sacamos 'common'
      name: json['name']['common'] ?? 'Sin nombre',

      // 3. Capital: Es una lista. Verificamos si existe y si tiene elementos.
      // Si la lista está vacía (ej: Antártida), ponemos "No capital".
      capital: (json['capital'] != null && (json['capital'] as List).isNotEmpty)
          ? json['capital'][0]
          : 'No capital',

      population: json['population'] ?? 0,

      // 4. Flags: Entramos al mapa 'flags' y pedimos la url 'png'
      flagUrl: json['flags']['png'] ?? '',

      // La API no manda favoritos, así que asumimos falso al descargar
      isFavorite: false,

      // La API devuelve 'region': 'Europe', 'Americas', etc.
      region: json['region'] ?? 'Unknown',

      // OJO: Hay que castear a List<double> porque JSON lo ve como dynamic
      latlng: (json['latlng'] as List?)?.map((e) => e as double).toList() ?? [0.0, 0.0],

    );
  }

  // Constructor desde SQLite (Aquí la estructura es plana)
  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'], // En la BD sí se llamará 'id' la columna
      name: map['name'],
      capital: map['capital'],
      population: map['population'],
      flagUrl: map['flagUrl'],
      // Convertimos el 1 o 0 de SQLite a bool
      isFavorite: map['isFavorite'] == 1,
      region: map['region'],
      latlng: List<double>.from(map['latlng']),

    );
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capital': capital,
      'flagUrl': flagUrl,
      'population': population,
      'isFavorite': (isFavorite == true) ? 1 : 0,
      'region': region,
      'latlng': latlng
    };
  }
}