import 'package:flutter/material.dart';
// Importamos las librerías de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

// ... (Tus imports y la función main permanecen iguales) ...

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ NUEVO: Usamos FutureBuilder para manejar el estado de la inicialización de Firebase
    return FutureBuilder(
      // La inicialización se realiza en el main, aquí solo comprobamos
      future: Future.value(
        null,
      ), // Solo para fines de estructura, ya que se inicializó en main
      builder: (context, snapshot) {
        // Si el snapshot estuviera pendiente, mostraría un spinner, pero como se inicializó en main, no lo hará.
        // El verdadero punto de control es manejar los errores que podrían haber ocurrido durante el main.

        // Si hay algún error nativo que impidió la inicialización
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error de Inicialización de Firebase: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        // Si no hay errores, procedemos con la aplicación normal
        return MaterialApp(
          title: 'Actividad 3.7 Integración de base de datos',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
            useMaterial3: true,
          ),
          home: WelcomeScreen(),
        );
      },
    );
  }
}

// ----------------------------------------
// PANTALLA DE BIENVENIDA CON FIREBASE
// ----------------------------------------

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  // Referencia a Firestore para facilitar la lectura
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 1. FONDO (Sin cambios)
          Container(
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

          // 2. CONTENIDO PRINCIPAL: Icono, Título y Mensaje de Bienvenida de Firestore
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ICONO Y NOMBRE DE LA APLICACIÓN (Sin cambios)
                const Icon(
                  Icons.movie_filter,
                  size: 80,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Movie App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),

                // LECTOR DE DATOS DE FIREBASE
                FutureBuilder<DocumentSnapshot>(
                  // Hacemos una única llamada para obtener el documento
                  future:
                      firestore
                          .collection('app_config')
                          .doc('welcome_message')
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Mientras carga
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    } else if (snapshot.hasError) {
                      // Si hay un error de conexión o permisos
                      return const Text(
                        'Error al conectar con la DB.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 18),
                      );
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      // Si los datos llegan correctamente
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final message = data?['message'] ?? 'Mensaje por defecto';

                      return Text(
                        message, // <-- Mensaje traído de Firestore
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }

                    // Si el documento no existe
                    return const Text(
                      'Configuración de mensaje no encontrada.',
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
