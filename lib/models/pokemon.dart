class Pokemon {
  final int pokedexNum;
  final String name;
  final String imageUrl;
  final String type;

  Pokemon({
    required this.pokedexNum,
    required this.name,
    required this.imageUrl,
    required this.type,
  });

  factory Pokemon.fromApi(Map<String, dynamic> data) {
    final name = data['name'];
    final url = data['url'];
    final id = int.parse(url.split('/')[url.split('/').length - 2]);

    return Pokemon(
      pokedexNum: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      type: 'Desconhecido',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pokedexNum': pokedexNum,
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      pokedexNum: map['pokedexNum'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      type: map['type'],
    );
  }
}
