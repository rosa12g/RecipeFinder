import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'detailscreen.dart';

class FavoriteScreen extends StatefulWidget {
  final List<int> favoriteIds;

  const FavoriteScreen({Key? key, required this.favoriteIds}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  // Load full recipe data for each favorite
  Future<void> _loadFavoriteRecipes() async {
    final String apiKey = '930f4b1df76f4e988765a6976a3fc096';
    final List<Map<String, dynamic>> recipes = [];

    for (int id in widget.favoriteIds) {
      final url = Uri.parse('https://api.spoonacular.com/recipes/$id/information?apiKey=$apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> recipe = json.decode(response.body);
        recipes.add({
          'id': recipe['id'],
          'title': recipe['title'],
          'imageUrl': recipe['image'],
          'readyInMinutes': recipe['readyInMinutes'],
        });
      }
    }

    setState(() {
      _favoriteRecipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: _favoriteRecipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _favoriteRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: recipe['imageUrl'],
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                    ),
                    title: Text(recipe['title']),
                    subtitle: Text('Ready in ${recipe['readyInMinutes']} mins'),
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
    );
  }
}
