import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 3.4 Utilización de widgets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LayoutExamplesScreen(),
    );
  }
}

// -----------------------
//          WIDGETS
// -----------------------
class LayoutExamplesScreen extends StatelessWidget {
  const LayoutExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Act. 3.4 Utilización de widgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sección 1: Container y Text
            _buildContainerExample(),
            const SizedBox(height: 30),

            // Sección 2: Row
            _buildSectionTitle('2. Row (Fila)'),
            _buildRowExample(),
            const SizedBox(height: 30),

            // Sección 3: Column
            _buildSectionTitle('3. Column (Columna)'),
            _buildColumnExample(),
            const SizedBox(height: 30),

            // Sección 4: Stack
            _buildSectionTitle('4. Stack (Apilamiento)'),
            _buildStackExample(),
          ],
        ),
      ),
    );
  }

  // --- Funciones de Ayuda para las Secciones ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContainerExample() {
    // ----------------------------------------------------
    // 1. CONTAINER y TEXT
    // El Container sirve para dar estilo, tamaño y relleno
    // ----------------------------------------------------
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. Container y Text'),
        Container(
          height: 100, // Altura específica
          width: 300, // Ancho específico
          margin: const EdgeInsets.all(10.0), // Margen exterior
          padding: const EdgeInsets.all(15.0), // Relleno interior
          decoration: BoxDecoration(
            color: Colors.blueAccent[100], // Color de fondo
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
            border: Border.all(color: Colors.blue, width: 2), // Borde
          ),
          child: const Center(
            // El Widget Text es para mostrar texto simple
            child: Text(
              'Este es un Widget Text dentro de un Container.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowExample() {
    // ----------------------------------------------------
    // 2. ROW (Fila)
    // Muestra los Widgets hijos en una secuencia horizontal
    // ----------------------------------------------------
    return Container(
      color: Colors.blue[100],
      height: 60,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // mainAxisAlignment: Controla cómo se distribuyen los hijos horizontalmente
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // crossAxisAlignment: Controla cómo se alinean los hijos verticalmente
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.star, color: Colors.yellow),
          Text('Elemento 1'),
          Icon(Icons.star, color: Colors.yellow),
          Text('Elemento 2'),
          Icon(Icons.star, color: Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildColumnExample() {
    // ----------------------------------------------------
    // 3. COLUMN (Columna)
    // Muestra los Widgets hijos en una secuencia vertical
    // ----------------------------------------------------
    return Container(
      color: Colors.blue[100],
      width: double.infinity, // Ocupa todo el ancho disponible
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: Controla cómo se distribuyen los hijos verticalmente
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: Controla cómo se alinean los hijos horizontalmente
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text('1. Primer ítem'),
          SizedBox(height: 8), // Espacio entre elementos
          Text('2. Segundo ítem'),
          SizedBox(height: 8),
          Text('3. Tercer ítem, alineado a la izquierda.'),
        ],
      ),
    );
  }

  Widget _buildStackExample() {
    // ----------------------------------------------------
    // 4. STACK (Apilamiento)
    // Apila los Widgets uno encima del otro, como capas
    // ----------------------------------------------------
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          // El primer Widget es el fondo
          Container(height: 120, width: 350, color: Colors.blue[100]),
          // El segundo Widget se superpone
          Positioned(
            top: 20, // Distancia desde el borde superior
            left: 20, // Distancia desde el borde izquierdo
            child: Container(
              color: Colors.green,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Capa de en medio',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // El tercer Widget es la capa superior
          const Positioned(
            bottom: 0, // Distancia desde el borde inferior
            right: 10, // Distancia desde el borde derecho
            child: Icon(Icons.audiotrack, size: 50, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
