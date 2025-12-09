import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/apod_item.dart';

class HttpHelper {
  // URL dada en el examen (Tu código impar)
  final String urlBase = 'https://api.nasa.gov/planetary/apod'
      '?api_key=DEMO_KEY'
      '&start_date=2017-07-08'
      '&end_date=2017-12-10';

  Future<List<ApodItem>> getApodData() async {
    try {
      final response = await http.get(Uri.parse(urlBase));

      if (response.statusCode == 200) {
        // APOD con start_date devuelve una LISTA [...]
        final List<dynamic> jsonList = json.decode(response.body);

        List<ApodItem> items = jsonList.map((json) => ApodItem.fromJson(json)).toList();
        return items;
      } else {
        return [];
      }
    } catch (e) {
      print("Error Http: $e");
      return [];
    }
  }
}