import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cocktail.dart';

class HttpHelper {
  final String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';

  // 1. LISTA (Resumen: Solo trae imagen, nombre e ID)
  // El modelo pondrá "General" y "Mezclar" por defecto para que no falle.
  Future<List<Cocktail>> getCocktailsByCategory() async {
    final url = '$_baseUrl/filter.php?c=Cocktail';
    return _fetchData(url);
  }

  // 2. BÚSQUEDA (Trae detalles completos)
  Future<List<Cocktail>> searchCocktail(String name) async {
    final url = '$_baseUrl/search.php?s=$name';
    return _fetchData(url);
  }

  // 3. NUEVO: DETALLE POR ID (Para completar la info al hacer clic)
  Future<Cocktail?> getCocktailById(String id) async {
    final url = '$_baseUrl/lookup.php?i=$id';
    List<Cocktail> result = await _fetchData(url);
    if (result.isNotEmpty) {
      return result.first; // Devolvemos el cóctel con TODA la info
    }
    return null;
  }

  // Método auxiliar genérico
  Future<List<Cocktail>> _fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Si no hay tragos, devuelve lista vacía
        if (jsonResponse['drinks'] == null) {
          return [];
        }
        final List<dynamic> drinksList = jsonResponse['drinks'];
        return drinksList.map((item) => Cocktail.fromJson(item)).toList();

        // // Decodifica directamente como Lista porque el JSON empieza con corchete [
        // final List<dynamic> list = json.decode(response.body); 

        // // Ya no buscas ['drinks'], mapeas directo
        // return list.map((i) => Cocktail.fromJson(i)).toList();

      }
      return [];
    } catch (e) {
      print("Error API: $e");
      return [];
    }
  }
}