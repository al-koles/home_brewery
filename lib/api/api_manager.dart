import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_brewery/model/recipe_config_paragraph.dart';
import 'package:xml/xml.dart';
import 'package:home_brewery/constants.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  static Future<List<Recipe>> getRecipes({String? clientId}) async {
    List<Recipe> recipes = [];
    var uri = Uri.parse(
        '${Constants.baseUrl}/${clientId == null ? 'Recipes/GetRecipes' : ('ClientRecipes/GetAvailableRecipesForClientId/' + clientId)}');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body.toString());
      for (var u in jsonData) {
        final modelType = Recipe.fromJson(u);
        recipes.add(modelType);
      }
    } else {
      print('failed to load data');
      //throw Exception('Failed to load recipes');
    }
    return recipes;
  }

  static Future<List<Recipe>> getRecipesOfClientId(String clientId) async {
    List<Recipe> recipes = [];
    var uri = Uri.parse(
        '${Constants.baseUrl}/ClientRecipes/GetRecipesOfClientId/$clientId');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body.toString());
      for (var u in jsonData) {
        final modelType = Recipe.fromJson(u);
        recipes.add(modelType);
      }
    } else {
      print('failed to load data of client');
      //throw Exception('Failed to load recipes');
    }
    return recipes;
  }

  static Future<List<RecipeConfigParagraph>> getRecipeConfig(
      int id, BuildContext context) async {
    String xmlStr = await DefaultAssetBundle.of(context)
        .loadString('assets/recipes/$id.xml');
    final document = XmlDocument.parse(xmlStr);

    final paragraphs = document.findAllElements('p');
    return paragraphs
        .map(
          (p) => RecipeConfigParagraph(
            text: p.findElements('text').first.text,
            time: int.parse(p.findElements('time').first.text),
          ),
        )
        .toList();
  }

  static Map<String, String> headers = {
    "Content-type": "application/json",
    "Accept": "application/json"
  };

  static Future<http.Response> postUser(Map<String, dynamic> client) async {
    var uri = Uri.parse('${Constants.baseUrl}/Clients/PostClient');
    return http.post(uri, body: jsonEncode(client), headers: headers);
  }

  static Future<http.Response> postClientRecipe(
      Map<String, dynamic> clientRecipe) async {
    var uri = Uri.parse('${Constants.baseUrl}/ClientRecipes/PostClientRecipe');
    return http.post(uri, body: jsonEncode(clientRecipe), headers: headers);
  }

  static Future<http.Response> deleteClientRecipe(
      String clientId, int recipeId) {
    var uri = Uri.parse(
        '${Constants.baseUrl}/ClientRecipes/DeleteClientRecipe/$clientId, ${recipeId.toString()}');
    return http.delete(uri,
        body:
            jsonEncode({"clientId": clientId, "recipeId": recipeId.toString()}),
        headers: headers);
  }
}
