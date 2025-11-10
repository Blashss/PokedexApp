class Pokemon {
  final int pokedexNum;
  final String name;
  final String imageUrl;
  final String generation;
  final String type;

  Pokemon({
    required this.pokedexNum, required this.name, required this.imageUrl, required this.generation, required this.type,});

  factory Pokemon.fromApi(Map<String, dynamic> data) {
    final name = data['name'];
    final url = data['url'];
    final id = int.parse(url.split('/')[url.split('/').length - 2]);
    final type = 'Desconhecido';

    return Pokemon(
      pokedexNum: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      generation: id <= 151
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
          : 'Desconhecida',
      type: type,
    );

  }


  Map<String, dynamic> toMap() {
    return {
      'pokedexNum': pokedexNum,
      'name': name,
      'imageUrl': imageUrl,
      'generation': generation,
      'type': type,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      pokedexNum: map['pokedexNum'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      generation: map['generation'],
        type: map['type'] ?? 'Desconhecido'
    );
  }
}
