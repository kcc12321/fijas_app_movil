class ApodItem {
  String date;        // Usaremos la fecha como ID único (PK)
  String title;
  String explanation;
  String url;         // La imagen
  String copyright;   // Atributo extra para cumplir requisitos

  ApodItem({
    required this.date,
    required this.title,
    required this.explanation,
    required this.url,
    required this.copyright,
  });

  // 1. De JSON (API) a Objeto
  factory ApodItem.fromJson(Map<String, dynamic> json) {
    return ApodItem(
      date: json['date'] ?? '',
      title: json['title'] ?? 'Sin título',
      explanation: json['explanation'] ?? 'Sin descripción',
      url: json['url'] ?? '',
      // OJO: Copyright a veces no viene, hay que protegerlo
      copyright: json['copyright'] ?? 'NASA Public Domain',
    );
  }

  // 2. De SQL (Base de Datos) a Objeto
  factory ApodItem.fromMap(Map<String, dynamic> map) {
    return ApodItem(
      date: map['date'],
      title: map['title'],
      explanation: map['explanation'],
      url: map['url'],
      copyright: map['copyright'],
    );
  }

  // 3. De Objeto a Mapa (Para guardar en SQL)
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'title': title,
      'explanation': explanation,
      'url': url,
      'copyright': copyright,
    };
  }
}