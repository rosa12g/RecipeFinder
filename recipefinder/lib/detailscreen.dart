import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class detailscreen extends StatefulWidget {
  final int recipeId;

  const detailscreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<detailscreen> {
  late Map<String, dynamic> _recipeDetails = {};

//api
  Future<void> _fetchRecipeDetails() async {
    final String apiKey = '930f4b1df76f4e988765a6976a3fc096'; 
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _recipeDetails = json.decode(response.body);
      });
    } else {
      
      setState(() {
        _recipeDetails = {};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: _recipeDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
              
                  Text(
                    _recipeDetails['title'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                 
                  Image.network(_recipeDetails['image']),
                  const SizedBox(height: 16),
                 
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(
                      _recipeDetails['extendedIngredients'].length,
                      (index) {
                        var ingredient = _recipeDetails['extendedIngredients'][index];
                        return Text('${ingredient['original']}');
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
               
                  const Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_recipeDetails['instructions'] ?? 'No instructions available.'),
                  const SizedBox(height: 16),
                
                  Text('Servings: ${_recipeDetails['servings']}'),
                  Text('Ready in ${_recipeDetails['readyInMinutes']} minutes'),
                ],
              ),
            ),
    );
  }
}
