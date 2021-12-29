import 'package:flutter/material.dart';
import 'package:home_brewery/api/rest_api.dart';
import 'package:home_brewery/components/recipes_table.dart';
import 'package:home_brewery/model/recipe.dart';

import '../custom_icons.dart';

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
      ),
      constraints: const BoxConstraints(
        maxHeight: 500,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: Color(0xFFFFFACE),
      ),
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
              Container(
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
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    color: Color(0xFFFFF16A),
                  ),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      menuBar(),
                      Expanded(
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          children: [
                            FutureBuilder<List<Recipe>>(
                              future: _recipes,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  final recipes = snapshot.data as List<Recipe>;
                                  print(recipes.toString());
                                  return RecipesTable(recipes: recipes);
                                }
                                else{
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                            Container(
                              color: Colors.white,
                              width: 400,
                              height: 150,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
