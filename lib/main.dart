import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 3.5 Home screen - App de Películas',
      theme: ThemeData(
        // Paleta de color azul para el tema principal
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ----------------------
// PANTALLA DE BIENVENIDA
// ----------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // ---------------------
          //   IMAGEN DE FONDO
          // ----------------------
          Container(
            // Ocupa el 100% del ancho y alto disponibles
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // -------------------------
          //    CONTENIDO PRINCIPAL
          // --------------------------
          Center(
            child: Column(
              // Alinea el contenido al centro de la pantalla verticalmente
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ICONO DE LA APLICACIÓN
                const Icon(
                  Icons.movie_filter, // Icono de película
                  size: 80,
                  color:
                      Colors
                          .amberAccent, // Un color que resalte en el fondo azul
                ),

                const SizedBox(height: 16), // Espacio vertical
                // NOMBRE DE LA APLICACIÓN
                const Text(
                  'App Movies',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto blanco para contraste
                    letterSpacing: 2, // Espaciado entre letras
                  ),
                ),

                const SizedBox(height: 40), // Espacio vertical
                // MENSAJE DE BIENVENIDA
                const Text(
                  'Hello World',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70, // Un blanco más sutil
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
