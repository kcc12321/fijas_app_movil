import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/country_list.dart'; // Importamos tu pantalla principal

void main() async {
  // 1. "Pone el freno de mano"
  // Flutter necesita inicializar sus canales nativos antes de llamar a código asíncrono
  // como SharedPreferences. Sin esto, la app crashea al inicio.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lee la memoria del celular
  // Pregunta: "¿La última vez se quedó en oscuro o claro?"
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false; // Si es nuevo, empezamos en claro (false)

  // 3. Arranca la UI pasándole el dato
  runApp(MyApp(isDarkDefault: isDark));
}

// Esta variable es como una ANTENA DE RADIO.
// Cualquier widget que la esté escuchando se enterará cuando cambie su valor.
// Notificador global para cambiar el tema desde cualquier lado
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  final bool isDarkDefault;

  const MyApp({super.key, required this.isDarkDefault});

  @override
  Widget build(BuildContext context) {
    // 1. Sincronizamos la antena con lo que leímos de la memoria
    themeNotifier.value = isDarkDefault ? ThemeMode.dark : ThemeMode.light;

    // 2. EL ESCUCHA (Listener)
    // Este widget envuelve a toda la app.
    // Cada vez que 'themeNotifier' cambie, este builder se ejecuta de nuevo.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // <-- Aquí conecta la oreja a la antena
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DiplomaticApp',
          // TEMA CLARO
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          // TEMA OSCURO
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark
            ),
          ),
          themeMode: currentMode, // <-- AQUÍ SE APLICA EL CAMBIO
          // Si currentMode es ThemeMode.dark, usa 'darkTheme'.
          // Si es ThemeMode.light, usa 'theme'.
          home: const CountryList(),
        );
      },
    );
  }
}