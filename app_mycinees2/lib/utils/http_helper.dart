import 'package:app_mycinees2/models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class HttpHelper {
  // Configuración de la API
  final String urlKey = 'api_key=3cae426b920b29ed2fb1c0749f258325';
  final String urlBase = 'https://api.themoviedb.org/3/movie';
  final String urlUpcoming = '/upcoming?';
  final String urlSearchBase = 'https://api.themoviedb.org/3/search/movie?'; // Nueva URL para buscar
  final String urlPage = '&page=';

  // 1. OBTENER PELÍCULAS EN CARTELERA
  Future<List<Movie>> getUpcoming(String page) async {
    final String upcoming = urlBase + urlUpcoming + urlKey + urlPage + page;

    // Llamada a la API
    http.Response result = await http.get(Uri.parse(upcoming));

    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      final moviesMap = jsonResponse['results'];

      List<Movie> movies = moviesMap.map<Movie>((i) =>
          Movie.fromJson(i)).toList();

      return movies;
    } else {
      // CORRECCIÓN CRÍTICA: Devolvemos lista vacía en vez de null para no romper la app
      return [];
    }
  }

  // 2. BUSCAR PELÍCULAS (¡Funcionalidad Extra!)
  Future<List<Movie>> findMovies(String title) async {
    // Construimos la URL de búsqueda: Base + Key + Query
    final String query = "&query=$title";
    final String url = urlSearchBase + urlKey + query;

    http.Response result = await http.get(Uri.parse(url));

    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      final moviesMap = jsonResponse['results'];

      List<Movie> movies = moviesMap.map<Movie>((i) =>
          Movie.fromJson(i)).toList();

      return movies;
    } else {
      return [];
    }
  }
}