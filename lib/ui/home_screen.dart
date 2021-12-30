import 'package:flutter/material.dart';
import 'package:home_brewery/api/rest_api.dart';
import 'package:home_brewery/components/recipes_table.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:home_brewery/model/recipe_config_paragraph.dart';

import '../components/custom_icons.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final bool isLogged = false;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum MenuItems { all, my }

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Recipe>> _recipes = ApiManager.getRecipes();

  MenuItems _menuItem = MenuItems.all;
  Recipe? selectedRecipe;

  @override
  void initState() {
    _recipes.then((value) {
      setState(() {
        selectedRecipe = value[0];
      });
    });
    super.initState();
  }

  void menuItemChanged(MenuItems? value) {
    setState(() {
      if (value != null) {
        _menuItem = value;
        switch (value) {
          case MenuItems.all:
            _recipes = ApiManager.getRecipes();
            break;
          case MenuItems.my:
            print('fill with my recipes');
            break;
        }
      }
    });
  }

  Widget menuBar() {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        left: 30,
        bottom: 30,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 5,
      ),
      decoration: Constants.boxDecoration,
      width: 200,
      child: Column(
        children: [
          RadioListTile(
            title: const Text(
              'All recipes',
            ),
            value: MenuItems.all,
            groupValue: _menuItem,
            onChanged: menuItemChanged,
          ),
          RadioListTile(
              title: const Text(
                'My recipes',
              ),
              value: MenuItems.my,
              groupValue: _menuItem,
              onChanged: menuItemChanged),
        ],
      ),
    );
  }

  Widget buildRecipeInfo() => Container(
        decoration: Constants.boxDecoration,
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(30),
        height: 250,
        alignment: Alignment.topLeft,
        child: selectedRecipe == null
            ? const CircularProgressIndicator()
            : ListView(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      selectedRecipe!.name,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Text(
                    'Description: ${selectedRecipe!.description}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  FutureBuilder<List<RecipeConfigParagraph>>(
                    future:
                        ApiManager.getRecipeConfig(selectedRecipe!.recipeId, context),
                    builder: (context, snapshot) {
                      if(snapshot.hasError){
                        return const SizedBox();
                      }
                      if (snapshot.hasData) {
                        return Text(snapshot.data!.map((p) =>
                          '\nTime: ${p.time} minutes.\n${p.text}'
                        ).join("\n\n"));
                      }else{
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
      );

  Widget buildTable() => FutureBuilder<List<Recipe>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recipes = snapshot.data as List<Recipe>;
            return RecipesTable(
              recipes: recipes,
              rowSelected: (Recipe recipe) {
                setState(() {
                  selectedRecipe = recipe;
                });
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );

  Widget buildHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {},
              child: Row(
                children: const [
                  Icon(
                    CustomIcons.logo,
                    size: 50,
                    color: Colors.white,
                  ),
                  Text(
                    'Home\nbrewery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                  widget.isLogged
                      ? Container(
                          color: Colors.blueAccent,
                          width: 100,
                          height: 30,
                        )
                      : Container(),
                ],
              ),
            )
          ],
        ),
      );

  Widget buildBody() => Expanded(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            color: Color(0xFFFFF16A),
          ),
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              menuBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildRecipeInfo(),
                      buildTable(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(255, 252, 212, 100),
        alignment: Alignment.center,
        child: Container(
          color: const Color.fromRGBO(38, 17, 0, 100),
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              buildHeader(),
              buildBody(),
            ],
          ),
        ),
      ),
    );
  }
}
