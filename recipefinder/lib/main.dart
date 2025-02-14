import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
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

  // Fetch recipes from Spoonacular API
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
