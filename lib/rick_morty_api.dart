import 'dart:convert';
import 'package:http/http.dart' as http;

// Clase para almacenar los personajes
class Character {
  final int id;
  final String name;
  final String status;
  final String imageUrl;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.imageUrl,
  });

  
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      imageUrl: json['image'],
    );
  }
}

// Peticiones HTTP
class RickMortyService {
  static const String baseUrl = 'https://rickandmortyapi.com/api/character/';

  
  Future<List<Character>> fetchCharacters(int count) async {
  
    final ids = List.generate(count, (index) => index + 1).join(','); 
    
    final response = await http.get(Uri.parse('$baseUrl$ids'));

    if (response.statusCode == 200) {

      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar los personajes. Código: ${response.statusCode}');
    }
  }
}