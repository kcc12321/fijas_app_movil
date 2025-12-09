import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/player.dart'; // Asegúrate de importar tu modelo

class HttpHelper {
  final String urlBase = 'https://dev.formandocodigo.com/famous_players.php';

  Future<List<Player>> getPlayers(String position) async {
    final String url = '$urlBase?posicion=$position';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Mapeamos cada elemento al modelo Player
        List<Player> players = jsonList.map((json) => Player.fromJson(json)).toList();

        return players;
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