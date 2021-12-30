import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_brewery/api/auth.dart';
import 'package:home_brewery/api/rest_api.dart';
import 'package:home_brewery/components/recipes_table.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:home_brewery/model/recipe_config_paragraph.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../components/custom_icons.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.isLogged, Key? key}) : super(key: key);

  final bool isLogged;

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

  Future<void> toast({required String message, required Color color}) async {
    await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool login = true;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  _openPopup(context) {
    Alert(
        closeIcon: const Icon(FontAwesomeIcons.windowClose),
        context: context,
        title: login ? "LOGIN" : "REGISTER",
        content: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () {
                  login = !login;
                  Navigator.pop(context);
                  _openPopup(context);
                },
                child: Text(
                  login
                      ? 'Not registered yet? Register?'
                      : 'Already registered? Log in?',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              try {
                if (login) {
                  await AuthService().signInWithEmail(
                      emailController.text.trim(), passController.text.trim());
                } else {
                  await AuthService().createUserWithEmail(
                      emailController.text.trim(), passController.text.trim());
                }
                await toast(message: "It's ok", color: Colors.green);
                Navigator.pop(context);
              } on FirebaseAuthException catch (e) {
                await toast(message: e.message.toString(), color: Colors.red);
              } catch (e) {
                await toast(message: 'somethins went wrong', color: Colors.red);
              }
            },
            child: Text(
              login ? "LOGIN" : "REGISTER",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
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
            if (widget.isLogged) {
            } else {
              _openPopup(context);
            }
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
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 5,
      ),
      decoration: Constants.boxDecoration,
      width: 200,
      height: 545,
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
                    future: ApiManager.getRecipeConfig(
                        selectedRecipe!.recipeId, context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox();
                      }
                      if (snapshot.hasData) {
                        return Text(snapshot.data!
                            .map((p) => '\nTime: ${p.time} minutes.\n${p.text}')
                            .join("\n\n"));
                      } else {
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
              onTap: () {
                if (widget.isLogged) {
                } else {
                  _openPopup(context);
                }
              },
              child: Row(
                children: [
                  widget.isLogged
                      ? TextButton(
                          onPressed: () async {
                            try {
                              await AuthService().signOut();
                              await toast(
                                  message: 'You logged out',
                                  color: Colors.green);
                            } catch (e) {
                              await toast(message: 'Error', color: Colors.red);
                            }
                          },

                          child: const Text('Log out'),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 10,),
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  widget.isLogged
                      ? Text(
                          AuthService().currentUser!.email!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(),
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
