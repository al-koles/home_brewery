import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_brewery/api/api_manager.dart';
import 'package:home_brewery/ui/home_screen.dart';
import 'package:provider/provider.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);
    print('1user == null ${user == null}');
    var recipes = ApiManager.getRecipes(clientId: user?.uid);
    return HomeScreen(user: user, theRecipes: recipes,);
  }
}
