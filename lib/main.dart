import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// -----------------------------------------------------------------------------
// 0. FUNCIÓN MAIN
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// 1. MODELO DE DATOS
// -----------------------------------------------------------------------------
class Movie {
  final String id;
  final String title;
  final String year;
  final String director;
  final String genre;
  final String synopsis;
  final String imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    required this.genre,
    required this.synopsis,
    required this.imageUrl,
  });

  // Método para crear un objeto Movie desde un DocumentSnapshot de Firestore
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? 'Sin Título',
      year: data['year'] ?? 'N/A',
      director: data['director'] ?? 'Desconocido',
      genre: data['genre'] ?? 'General',
      synopsis: data['synopsis'] ?? 'Sin sinopsis disponible',
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/100x150/000000/FFFFFF?text=NO_IMG',
    );
  }

  // Método para crear un Mapa para subir o actualizar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'director': director,
      'genre': genre,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
    };
  }
}

// -----------------------------------------------------------------------------
// 2. SERVICIO DE FIREBASE (CRUD)
// -----------------------------------------------------------------------------
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = 'movies';

  // C - Crear (Add)
  Future<void> addMovie(Movie movie) {
    return _db.collection(collectionName).add(movie.toMap());
  }

  // R - Leer (Get Stream)
  Stream<List<Movie>> getMovies() {
    return _db.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // U - Actualizar (Update)
  Future<void> updateMovie(Movie movie) {
    return _db.collection(collectionName).doc(movie.id).update(movie.toMap());
  }

  // D - Eliminar (Delete)
  Future<void> deleteMovie(String movieId) {
    return _db.collection(collectionName).doc(movieId).delete();
  }
}

// -----------------------------------------------------------------------------
// 3. WIDGET PRINCIPAL Y NAVEGACIÓN
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      // StreamBuilder para manejar el estado de autenticación
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return CatalogScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. PANTALLA 1: HOME/LOGIN/REGISTRO
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isLogin = true;

  Future<void> _handleAuth() async {
    setState(() => _message = '');
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() {
          _message = 'Registro exitoso. ¡Inicia sesión!';
          _isLogin = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Error de autenticación');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.movie_filter, size: 80, color: Colors.blue.shade900),
              const SizedBox(height: 20),
              const Text('Bienvenido al Catálogo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLogin ? Colors.blue.shade900 : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(_isLogin ? 'INGRESAR' : 'REGISTRARSE'),
                ),
              ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_message, style: TextStyle(color: _message.contains('exitoso') ? Colors.green : Colors.red)),
                ),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _message = '';
                }),
                child: Text(_isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Ingresa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. PANTALLA 2: CATÁLOGO DE PELÍCULAS
// -----------------------------------------------------------------------------
class CatalogScreen extends StatelessWidget {
  CatalogScreen({super.key});

  // CORRECCIÓN: Eliminado 'const' para evitar errores
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Películas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const AdminScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _firestoreService.getMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          
          final movies = snapshot.data ?? [];
          if (movies.isEmpty) return const Center(child: Text('No hay películas registradas.'));

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieCard(movie: movies[index]),
          );
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => DetailScreen(movie: movie))),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: movie.id,
                child: Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(movie.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. PANTALLA 3: DESCRIPCIÓN DE LA PELÍCULA (DETALLE)
// -----------------------------------------------------------------------------
class DetailScreen extends StatelessWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(movie.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Hero(
                tag: movie.id,
                child: Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, size: 100)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Año: ${movie.year}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    _detailRow(Icons.person, 'Director', movie.director),
                    _detailRow(Icons.category, 'Género', movie.genre),
                    const Divider(height: 30),
                    const Text('Sinopsis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(movie.synopsis, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de Edición
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditMovieScreen(movie: movie)));
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade900),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 7. PANTALLA 4: ADMINISTRACIÓN (CREAR Y BORRAR)
// -----------------------------------------------------------------------------
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();

  void _addMovie() async {
    if (_formKey.currentState!.validate()) {
      final newMovie = Movie(
        id: '',
        title: _titleCtrl.text,
        year: _yearCtrl.text,
        director: _dirCtrl.text,
        genre: _genreCtrl.text,
        synopsis: _synopsisCtrl.text,
        imageUrl: _imgCtrl.text,
      );
      await _firestoreService.addMovie(newMovie);
      _formKey.currentState!.reset();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Película agregada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: const TabBar(
            tabs: [Tab(icon: Icon(Icons.add), text: 'Agregar película'), Tab(icon: Icon(Icons.delete), text: 'Eliminar película')],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(_titleCtrl, 'Título', Icons.title),
                    _input(_yearCtrl, 'Año', Icons.calendar_today, isNum: true),
                    _input(_dirCtrl, 'Director', Icons.person),
                    _input(_genreCtrl, 'Género', Icons.category),
                    _input(_imgCtrl, 'URL Imagen', Icons.image),
                    _input(_synopsisCtrl, 'Sinopsis', Icons.description, lines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addMovie,
                      icon: const Icon(Icons.save),
                      label: const Text('GUARDAR PELÍCULA'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            StreamBuilder<List<Movie>>(
              stream: _firestoreService.getMovies(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final m = snapshot.data![index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(m.imageUrl), onBackgroundImageError: (_,__) => {}),
                      title: Text(m.title),
                      subtitle: Text(m.year),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deleteMovie(m.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String lbl, IconData i, {bool isNum = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: lbl, prefixIcon: Icon(i), border: const OutlineInputBorder()),
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: lines,
        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 8. PANTALLA 5: EDITAR PELÍCULA (UPDATE)
// -----------------------------------------------------------------------------
class EditMovieScreen extends StatefulWidget {
  final Movie movie;
  const EditMovieScreen({super.key, required this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _dirCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _synopsisCtrl;
  late TextEditingController _imgCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.movie.title);
    _yearCtrl = TextEditingController(text: widget.movie.year);
    _dirCtrl = TextEditingController(text: widget.movie.director);
    _genreCtrl = TextEditingController(text: widget.movie.genre);
    _synopsisCtrl = TextEditingController(text: widget.movie.synopsis);
    _imgCtrl = TextEditingController(text: widget.movie.imageUrl);
  }

  void _updateMovie() async {
    if (_formKey.currentState!.validate()) {
      final updated = Movie(
        id: widget.movie.id,
        title: _titleCtrl.text,
        year: _yearCtrl.text,
        director: _dirCtrl.text,
        genre: _genreCtrl.text,
        synopsis: _synopsisCtrl.text,
        imageUrl: _imgCtrl.text,
      );
      await _firestoreService.updateMovie(updated);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Película actualizada')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar: ${widget.movie.title}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_titleCtrl, 'Título', Icons.title),
              _input(_yearCtrl, 'Año', Icons.calendar_today, isNum: true),
              _input(_dirCtrl, 'Director', Icons.person),
              _input(_genreCtrl, 'Género', Icons.category),
              _input(_imgCtrl, 'URL Imagen', Icons.image),
              _input(_synopsisCtrl, 'Sinopsis', Icons.description, lines: 3),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _updateMovie,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR CAMBIOS'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String lbl, IconData i, {bool isNum = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: lbl, prefixIcon: Icon(i), border: const OutlineInputBorder()),
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: lines,
        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}