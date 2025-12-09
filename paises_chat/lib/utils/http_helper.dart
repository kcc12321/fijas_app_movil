import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/country.dart'; // Asegúrate de importar tu modelo

class HttpHelper {
  // Configuración de la API
  // final String urlKey = 'api_key=3cae426b920b29ed2fb1c0749f258325';
  // final String urlBase = 'https://api.themoviedb.org/3/movie';
  // final String urlUpcoming = '/upcoming?';
  // final String urlSearchBase = 'https://api.themoviedb.org/3/search/movie?'; // Nueva URL para buscar
  // final String urlPage = '&page=';
  final String urlBase = 'https://restcountries.com/v3.1/all?fields=name,capital,flags,population,cca3,region,latlng';
  final String searchUrl = 'https://restcountries.com/v3.1/name/';

  Future<List<Country>> getCountries() async {
    try {
      final response = await http.get(Uri.parse(urlBase));

      if (response.statusCode == 200) {
        // TRAMPA DEL EXAMEN:
        // RestCountries devuelve una LISTA directa '[...]', no un Mapa.
        // Por eso decodificamos directamente como List<dynamic>
        final List<dynamic> jsonList = json.decode(response.body);

        // Mapeamos cada elemento al modelo Country
        List<Country> countries = jsonList.map((json) => Country.fromJson(json)).toList();

        return countries;
      } else {
        // Si falla el servidor (error 404, 500), devolvemos lista vacía para no cerrar la app
        return [];
      }
    } catch (e) {
      // Si no hay internet o explota el parseo, devolvemos lista vacía
      print("Error en HttpHelper: $e");
      return [];
    }
  }


  Future<List<Country>> findCountries(String name) async {
    // Construimos la URL de búsqueda: Base + Key + Query
    final String query = name;
    final String url = searchUrl + query;

    http.Response result = await http.get(Uri.parse(url));

    if (result.statusCode == HttpStatus.ok) {
      // No es un mapa, así que lo decodificamos como List<dynamic>
      final List<dynamic> jsonList = json.decode(result.body);

      // Mapeamos la lista directamente
      List<Country> countries = jsonList.map((i) =>
          Country.fromJson(i)).toList();

      return countries;
    } else {
      return [];
    }
  }
}


// Peliculas
// {
// "page": 1,
// "results": [ ... ]  <-- Tienes que entrar aquí
// }
//
// Paises
// [  <-- ¡Entras directo aquí!
// { "name": "Peru"... },
// { "name": "Chile"... }
// ]