import 'package:flutter/material.dart';
import '../models/apod_item.dart';
import '../utils/http_helper.dart';
import '../utils/db_helper.dart';

class ApodListPage extends StatefulWidget {
  const ApodListPage({super.key});

  @override
  State<ApodListPage> createState() => _ApodListPageState();
}

class _ApodListPageState extends State<ApodListPage> {
  List<ApodItem> items = [];
  // BOLSA DE FAVORITOS: Aquí guardamos las fechas que ya tienen like
  Set<String> favoriteDates = {};

  bool loading = true;
  HttpHelper httpHelper = HttpHelper();
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    // 1. Traer datos de la API (Internet)
    final apiResult = await httpHelper.getApodData();

    // 2. Traer datos de la BD (Local) para saber cuáles ya tienen like
    final dbResult = await dbHelper.getFavorites();

    // Llenamos la bolsa con las fechas de los favoritos
    final savedDates = dbResult.map((e) => e.date).toSet();

    setState(() {
      items = apiResult;
      favoriteDates = savedDates; // Actualizamos la bolsa
      loading = false;
    });
  }

  // Lógica inteligente: Si ya existe, borra; si no, guarda.
  void toggleFavorite(ApodItem item) async {
    final isFav = favoriteDates.contains(item.date);

    if (isFav) {
      // YA ES FAVORITO -> LO BORRAMOS
      await dbHelper.deleteFavorite(item.date);
      setState(() {
        favoriteDates.remove(item.date); // Sacamos de la bolsa visualmente
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminado de favoritos")));
    } else {
      // NO ES FAVORITO -> LO GUARDAMOS
      await dbHelper.insertFavorite(item);
      setState(() {
        favoriteDates.add(item.date); // Metemos a la bolsa visualmente
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardado en favoritos ❤️")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NASA APOD List")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Preguntamos: ¿Esta foto está en la bolsa de favoritos?
          final isFavorite = favoriteDates.contains(item.date);

          return Card(
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item.url,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(item.date, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("© ${item.copyright}",
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    ],
                  ),
                ),

                // BOTÓN CORAZÓN REACTIVO
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    // AQUÍ CAMBIA EL ÍCONO Y EL COLOR SEGÚN EL ESTADO
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.grey,
                        size: 30
                    ),
                    onPressed: () => toggleFavorite(item),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}