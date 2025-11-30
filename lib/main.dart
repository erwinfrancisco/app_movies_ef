import 'package:flutter/material.dart';
import 'rick_morty_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 3.6 Peticiones HTTP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}

// -----------------------
// PANTALLA DE BIENVENIDA
// -----------------------
class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final RickMortyService service = RickMortyService();
  final int characterCount = 5; // Límite de 5 personajes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actividad 3.6 Peticiones HTTP',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: FutureBuilder<List<Character>>(
        // Llama a la función asíncrona para obtener 5 personajes
        future: service.fetchCharacters(characterCount),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Cargando
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            // Error
            return Center(
              child: Text(
                'Error al cargar: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            // Datos Recibidos - Mostrar Lista
            final characters = snapshot.data!;

            // Usamos ListView.builder para mostrar la lista de personajes
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];

                // Widget de tarjeta para mostrar cada personaje
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    // Imagen del personaje (Usamos CircleAvatar con NetworkImage)
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(character.imageUrl),
                    ),
                    // Nombre del personaje
                    title: Text(
                      character.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Estado (Vivo, Muerto, Desconocido)
                    subtitle: Text(
                      'Estado: ${character.status}',
                      style: TextStyle(
                        color:
                            character.status == 'Alive'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            );
          }
          // Retorno por defecto
          return const Center(child: Text('No hay datos disponibles.'));
        },
      ),
    );
  }
}
