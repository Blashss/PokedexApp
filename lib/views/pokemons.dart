import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/services/database_helper.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import '../widgets/pokemon_item.dart';

class Pokemons extends StatefulWidget {
  final User currentUser;
  const Pokemons({super.key, required this.currentUser});

  @override
  State<Pokemons> createState() => _PokemonsState();
}

class _PokemonsState extends State<Pokemons> {
  late Future<List<Pokemon>> _futurePokemons;

  final List<String> _selectedTypes = [];
  String? _selectedRegion;

  bool _isSearching = false;
  String _searchQuery = '';

  final regions = [
    'Todas as Regiões',
    'Kanto',
    'Johto',
    'Hoenn',
    'Sinnoh',
    'Unova',
    'Kalos',
    'Alola',
  ];

  final types = [
    'Normal',
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dark',
    'Dragon',
    'Steel',
    'Fairy',
  ];

  @override
  void initState() {
    super.initState();
    _futurePokemons = _loadPokemons();
  }

  Future<List<Pokemon>> _loadPokemons() async {
    final dbPokemons = await DatabaseHelper.instance.getAllPokemonsFromDB();
    
    if (dbPokemons.isNotEmpty) {
      return dbPokemons;
    }

    final apiPokemons = await fetchPokemons();
    await DatabaseHelper.instance.saveAllPokemons(apiPokemons);
    return apiPokemons;
  }

  Future<List<Pokemon>> fetchPokemons() async {
    final res = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=807'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final results = data['results'] as List;

      final pokemons = await Future.wait(
        results.map((item) => Pokemon.fromApi(item)),
      );

      return pokemons;
    }
    throw Exception('Falha ao carregar Pokémons');
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filtrar Pokémons"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Tipos:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: types.map((type) {
                        final isSelected = _selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Região:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: regions.map((region) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Radio<String>(
                            value: region,
                            groupValue: _selectedRegion,
                            onChanged: (String? value) {
                              setDialogState(() {
                                _selectedRegion = value;
                              });
                            },
                          ),
                          title: Text(region),
                          onTap: () {
                            setDialogState(() {
                              _selectedRegion = region;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedRegion = null;
                      _selectedTypes.clear();
                    });
                  },
                  child: const Text("Limpar Tudo"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text("Aplicar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _matchesFilters(Pokemon p) {
    final matchesRegion = _selectedRegion == null ||
        _selectedRegion == 'Todas as Regiões' ||
        p.generation == _selectedRegion;

    final pokemonTypes = p.type
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .toList();

    final matchesTypes = _selectedTypes.isEmpty ||
        _selectedTypes.every((t) => pokemonTypes.contains(t.toLowerCase()));

    final matchesSearch = _searchQuery.isEmpty ||
        p.name.toLowerCase().contains(_searchQuery);

    return matchesRegion && matchesTypes && matchesSearch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar Pokémon...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text("Pokédex"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = '';
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _futurePokemons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon encontrado.'));
          }

          final filtered = snapshot.data!.where(_matchesFilters).toList();

          return Column(
            children: [
              if (_selectedTypes.isNotEmpty ||
                  (_selectedRegion != null &&
                      _selectedRegion != 'Todas as Regiões'))
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtros: '
                          '${_selectedTypes.isNotEmpty ? _selectedTypes.join(', ') : ''}'
                          '${_selectedTypes.isNotEmpty && _selectedRegion != null && _selectedRegion != 'Todas as Regiões' ? ' • ' : ''}'
                          '${_selectedRegion != null && _selectedRegion != 'Todas as Regiões' ? _selectedRegion! : ''}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return PokemonItem(
                      pokemon: filtered[index],
                      currentUser: widget.currentUser,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
