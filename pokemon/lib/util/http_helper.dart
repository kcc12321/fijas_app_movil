import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class HttpHelper {
  final String urlBase = 'https://pokeapi.co/api/v2/pokemon';

  // 1. OBTENER LISTA (Paginada)
  // Recibe 'limit' y 'offset' para cargar de 20 en 20 si quisieras (Puntos extra)
  Future<List<Pokemon>> getPokemonList({int limit = 20, int offset = 0}) async {
    final String url = '$urlBase?limit=$limit&offset=$offset';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> results =jsonResponse['results'];

        // Usamos el constructor especial 'fromListJson'
        return results.map((map) => Pokemon.fromListJson(map)).toList();
      } else {
        return [];
      }
      } catch (e) {
        print("Error fetching list: $e");
        return [];
      }
    }
// 2. OBTENER DETALLE (Por ID o Nombre)
// Esta función completa los datos (Tipos, Peso, Altura)

  Future<Pokemon?> getPokemonDetail(String idOrName) async {
    final String url = '$urlBase/$idOrName';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Usamos el constructor completo 'fromJson'
        return Pokemon.fromJson(jsonResponse);
      } else {
        return null; // Si no existe (404)
      }
    } catch (e) {
      print("Error fetching detail: $e");
      return null;
    }
  }

}