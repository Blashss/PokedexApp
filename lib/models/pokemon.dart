import 'dart:convert';
import 'package:http/http.dart' as http;

class Pokemon {
  final int pokedexNum;
  final String name;
  final String imageUrl;
  final String generation;
  final String type;
  final int? captureId;

  Pokemon({required this.pokedexNum,required this.name,required this.imageUrl,required this.generation,required this.type,this.captureId,});

  static Future<Pokemon> fromApi(Map<String, dynamic> data) async {
    final name = data['name'];
    final url = data['url'];
    final id = int.parse(url.split('/')[url.split('/').length - 2]);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    final generation = id <= 151
        ? 'Kanto'
        : id <= 251
        ? 'Johto'
        : id <= 386
        ? 'Hoenn'
        : id <= 493
        ? 'Sinnoh'
        : id <= 649
        ? 'Unova'
        : id <= 721
        ? 'Kalos'
        : id <= 809
        ? 'Alola'
        : 'Desconhecida';
    String type = 'Desconhecido';
    try {
      final res = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
      );
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        type = (jsonData['types'] as List)
            .map(
              (t) =>
                  (t['type']['name'] as String)[0].toUpperCase() +
                  (t['type']['name'] as String).substring(1),
            )
            .join(', ');
      }
    } catch (e) {}
    return Pokemon(
      pokedexNum: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl: imageUrl,
      generation: generation,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pokedexNum': pokedexNum,
      'name': name,
      'imageUrl': imageUrl,
      'generation': generation,
      'pkmType': type,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      captureId: map['id'],
      pokedexNum: map['pokedexNum'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      generation: map['generation'],
      type: map['pkmType'] ?? 'Desconhecido',
    );
  }
}
