import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detailscreen.dart';
import 'fav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooksy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _recipes = [];
  List<int> _favoriteRecipeIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
   //fav
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteRecipeIds = prefs.getStringList('favorites')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favoriteRecipeIds.map((e) => e.toString()).toList());
  }

  void _toggleFavorite(int recipeId) {
    setState(() {
      if (_favoriteRecipeIds.contains(recipeId)) {
        _favoriteRecipeIds.remove(recipeId); 
      } else { 
        _favoriteRecipeIds.add(recipeId);
      }
      _saveFavorites(); 
    });
  }


  Future<void> _fetchRecipes() async {
    final String apiKey = '930f4b1df76f4e988765a6976a3fc096';
    final String ingredients = _controller.text;

    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredients&apiKey=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> recipeList = json.decode(response.body);
      setState(() {
        _recipes = recipeList;
      });
    } else {
      setState(() {
        _recipes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
             
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(favoriteIds: _favoriteRecipeIds),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Ingredients (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchRecipes,
              child: const Text('Find Recipes'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  final isFavorite = _favoriteRecipeIds.contains(recipe['id']);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl:
                            'https://spoonacular.com/recipeImages/${recipe['id']}-312x231.jpg',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                      ),
                      title: Text(recipe['title']),
                      subtitle: Text('Ready in ${recipe['readyInMinutes']} mins'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          _toggleFavorite(recipe['id']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => detailscreen(
                              recipeId: recipe['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
