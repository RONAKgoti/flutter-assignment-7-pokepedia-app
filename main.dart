import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokepedia',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();

  void goToHome() {
    final name = nameController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonListScreen(
          userName: name.isEmpty ? 'Trainer' : name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Poképedia',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 220,
                child: Lottie.asset('assets/lottie/pokemon.json'),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your trainer name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: goToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Enter Poképedia',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  final String userName;

  const PokemonListScreen({super.key, required this.userName});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonList = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pokemonList = data['results'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load Pokémon data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'No internet or something went wrong.';
        isLoading = false;
      });
    }
  }

  String getPokemonId(String url) {
    final parts = url.split('/');
    return parts[parts.length - 2];
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        title: Text('Poképedia - Hi ${widget.userName}'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchPokemon,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pokemonList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final pokemon = pokemonList[index];
          final name = pokemon['name'];
          final url = pokemon['url'];
          final id = getPokemonId(url);
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.catching_pokemon,
                      size: 60,
                      color: Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  capitalize(name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '#$id',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}