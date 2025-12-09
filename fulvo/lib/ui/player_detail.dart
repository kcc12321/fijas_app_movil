import 'package:flutter/material.dart';
import 'package:fulvo/models/player.dart'; // Ajusta tu nombre de proyecto
import '../utils/db_helper.dart';

class PlayerDetail extends StatefulWidget {
  final Player player;
  const PlayerDetail(this.player, {super.key});

  @override
  _PlayerDetailState createState() => _PlayerDetailState();
}

class _PlayerDetailState extends State<PlayerDetail> {
  late DbHelper dbHelper;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    checkFavorite();
  }

  void checkFavorite() async {
    bool result = await dbHelper.isFavorite(widget.player.id);
    if(mounted) {
      setState(() {
        isFavorite = result;
      });
    }
  }

  // --- LÓGICA DEL MODAL DE CONFIRMACIÓN (Requerimiento Examen) ---
  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFavorite ? "Eliminar de Favoritos" : "Agregar a Favoritos"),
        content: Text(isFavorite
            ? "¿Deseas eliminar a ${widget.player.name} de tu lista?"
            : "¿Deseas agregar a ${widget.player.name} a tu lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar sin hacer nada
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerramos el diálogo primero
              toggleFavorite();       // Ejecutamos la acción
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.deletePlayer(widget.player.id);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminado de favoritos")));
    } else {
      await dbHelper.insertPlayer(widget.player);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregado a favoritos")));
    }
    setState(() {
      isFavorite = !isFavorite;
      widget.player.isFavorite = isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.player.name)),

      floatingActionButton: FloatingActionButton(
        backgroundColor: isFavorite ? Colors.red : Colors.grey,
        // CORRECCIÓN: Ahora llamamos al diálogo, no a la acción directa
        onPressed: showConfirmationDialog,
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. IMAGEN (Corregido para ocupar todo el ancho)
            Hero(
              tag: 'poster_${widget.player.id}',
              child: SizedBox( // Usamos SizedBox para forzar dimensiones
                width: double.infinity, // Ocupa todo el ancho
                height: 300,
                child: Image.network(
                  widget.player.picture,
                  fit: BoxFit.cover, // Cubre todo el espacio sin bordes blancos
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              ),
            ),

            // 2. INFORMACIÓN DETALLADA (Etiquetas Corregidas)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        widget.player.name,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Etiquetas correctas para Fútbol
                      _buildInfoRow(Icons.flag, "País", widget.player.country),
                      const Divider(),
                      _buildInfoRow(Icons.sports_soccer, "Posición", widget.player.position),
                      const Divider(),
                      _buildInfoRow(Icons.shield, "Club Actual", widget.player.team),
                      const Divider(),
                      _buildInfoRow(Icons.cake, "Edad", "${widget.player.age} años"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar fuera de la clase
Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.indigo, size: 28),
        const SizedBox(width: 15),
        Expanded( // Expanded evita overflow si el texto es muy largo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    ),
  );
}