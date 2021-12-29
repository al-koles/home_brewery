
import 'dart:convert';

import 'package:home_brewery/constants.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:http/http.dart' as http;

class ApiManager{

  static Future<List<Recipe>> getRecipes() async {
    List<Recipe> recipes = [];
    var uri = Uri.parse('${Constants.baseUrl}/GetRecipes');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body.toString());
      for (var u in jsonData) {
        final modelType = Recipe.fromJson(u);
        recipes.add(modelType);
      }
    } else{
      print('failed to load data');
      //throw Exception('Failed to load recipes');
    }
    return recipes;
  }
}