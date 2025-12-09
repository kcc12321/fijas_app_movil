import 'package:flutter/material.dart';

import '../models/country.dart';
import '../utils/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class CountryDetail extends StatefulWidget {
  final Country country;
  // Usamos const para mejorar rendimiento
  const CountryDetail(this.country, {super.key});

  @override
  _CountryDetailState createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
  late DbHelper dbHelper;
  String path = "";
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    checkFavorite();
  }

  // Consulta a la Base de Datos
  void checkFavorite() async {
    bool result = await dbHelper.isFavorite(widget.country.id);
    setState(() {
      isFavorite = result;
    });
  }

  Future<void> _openMap() async {
    // Verificamos que tengamos coordenadas válidas
    if (widget.country.latlng.isEmpty) return;

    final lat = widget.country.latlng[0];
    final lng = widget.country.latlng[1];

    // Usamos la URL universal de Google Maps
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir el mapa")),
        );
      }
    }
  }

  // Acción del botón flotante
  void toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.deleteCountry(widget.country.id);
    } else {
      await dbHelper.insertCountry(widget.country);
    }
    setState(() {
      isFavorite = !isFavorite;
      // Actualizamos el objeto local para que al volver atrás se sepa
      widget.country.isFavorite = isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos altura para la imagen
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.country.name),
      ),
      // BOTÓN FLOTANTE DE FAVORITOS
      floatingActionButton: FloatingActionButton(
        backgroundColor: isFavorite ? Colors.red : Colors.grey,
        onPressed: toggleFavorite,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              // 1. IMAGEN
              Container(
                padding: const EdgeInsets.all(16),
                child: Hero(
                  tag: 'poster_${widget.country.id}',
                  child: Image.network(
                    widget.country.flagUrl,
                    height: height / 2.5,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),

              // 2. INFORMACIÓN DETALLADA
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre Grande
                        Center(
                          child: Text(
                            widget.country.name ?? "",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildInfoRow(Icons.location_city, "Capital", widget.country.capital),
                        const Divider(),
                        _buildInfoRow(Icons.local_airport, "Region", widget.country.region),
                        const Divider(),
                        _buildInfoRow(Icons.groups, "Población", widget.country.population.toString()), // Corregido: toString()
                        const Divider(),
                        _buildInfoRow(Icons.fingerprint, "Código ID", widget.country.id),

                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map, color: Colors.white),
                            label: const Text("Ver en Mapa", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo, // Color institucional
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            onPressed: _openMap,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    ),
  );
}


