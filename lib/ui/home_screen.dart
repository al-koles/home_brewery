import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_brewery/api/auth.dart';
import 'package:home_brewery/api/api_manager.dart';
import 'package:home_brewery/components/recipes_table.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:home_brewery/model/recipe_config_paragraph.dart';
import 'package:home_brewery/translations/locale_keys.g.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

//import 'package:pay/pay.dart';
import '../components/custom_icons.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({required this.user, required this.theRecipes, Key? key})
      : super(key: key);

  final User? user;
  Future<List<Recipe>>? theRecipes;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum MenuItems { all, my }

class _HomeScreenState extends State<HomeScreen> {
  MenuItems _menuItem = MenuItems.all;
  Recipe? selectedRecipe;
  int selectedIndex = 0;

  @override
  void initState() {
    print('user == null ${widget.user == null}');
    widget.theRecipes = ApiManager.getRecipes(
        clientId: widget.user != null ? widget.user!.uid : null);
    widget.theRecipes!.then((value) {
      setState(() {
        selectedIndex = 0;
        if (value.isEmpty) {
          selectedRecipe = null;
        } else {
          selectedRecipe = value[0];
        }
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

  buildLoginAlert(context) {
    Alert(
        closeIcon: const Icon(FontAwesomeIcons.windowClose),
        context: context,
        title: login ? LocaleKeys.login.tr() : LocaleKeys.register.tr(),
        content: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: LocaleKeys.email.tr(),
              ),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: LocaleKeys.password.tr(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () {
                  login = !login;
                  Navigator.pop(context);
                  buildLoginAlert(context);
                },
                child: Text(
                  login
                      ? LocaleKeys.not_registered.tr()
                      : LocaleKeys.already_registered.tr(),
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
                  final User? user = await AuthService().createUserWithEmail(
                      emailController.text.trim(), passController.text.trim());
                  final response = await ApiManager.postUser(
                      {'clientId': user!.uid, 'email': user.email});
                  print('response: $response');
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
              login ? LocaleKeys.login.tr() : LocaleKeys.register.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void menuItemChanged(MenuItems? value) {
    setState(() {
      if (value != null) {
        switch (value) {
          case MenuItems.all:
            widget.theRecipes = ApiManager.getRecipes(
                clientId: AuthService().currentUser != null
                    ? AuthService().currentUser!.uid
                    : null);
            _menuItem = value;
            break;
          case MenuItems.my:
            if (AuthService().currentUser != null) {
              widget.theRecipes = ApiManager.getRecipesOfClientId(
                  AuthService().currentUser!.uid);
              _menuItem = value;
            } else {
              buildLoginAlert(context);
            }
            break;
        }
        widget.theRecipes!.then((value) {
          setState(() {
            selectedIndex = 0;
            print('recipes value: ${value.join(", ")}');
            if (value.isEmpty) {
              print("value is empty");
              selectedRecipe = null;
            } else {
              print('value is full');
              selectedRecipe = value[0];
            }
          });
        });
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              RadioListTile(
                title: const Text(LocaleKeys.all_recipes).tr(),
                value: MenuItems.all,
                groupValue: _menuItem,
                onChanged: menuItemChanged,
              ),
              RadioListTile(
                  title: Text(LocaleKeys.my_recipes.tr()),
                  value: MenuItems.my,
                  groupValue: _menuItem,
                  onChanged: menuItemChanged),
            ],
          ),
          buildSaveButton(),

          // GooglePayButton(
          //   paymentConfigurationAsset: 'gpay.json',
          //   paymentItems: _paymentItems,
          //   style: GooglePayButtonStyle.black,
          //   type: GooglePayButtonType.pay,
          //   // width: 100,
          //   // height: 70,
          //   margin: const EdgeInsets.only(top: 15.0),
          //   onPaymentResult: onGooglePayResult,
          //   loadingIndicator: const Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // ),
        ],
      ),
    );
  }

  // final _paymentItems = [
  //   const PaymentItem(
  //     label: 'Total',
  //     amount: '99.99',
  //     status: PaymentItemStatus.final_price,
  //   )
  // ];

  // void onGooglePayResult(paymentResult) {
  //   debugPrint(paymentResult.toString());
  // }

  Widget buildRecipeInfo() => Container(
        decoration: Constants.boxDecoration,
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(30),
        height: 250,
        alignment: Alignment.topLeft,
        child: selectedRecipe == null
            ? const SizedBox()
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
        future: widget.theRecipes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recipes = snapshot.data as List<Recipe>;
            return RecipesTable(
              recipes: recipes,
              rowSelected: (Recipe recipe, int index) {
                setState(() {
                  selectedRecipe = recipe;
                  selectedIndex = index;
                });
              },
              selectedIndex: selectedIndex,
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
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    context.setLocale(Locale('en'));
                  },
                  child: Text('EN'),
                ),
                TextButton(
                  onPressed: () {
                    context.setLocale(Locale('uk'));
                  },
                  child: Text('UK'),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (AuthService().currentUser != null) {
                } else {
                  buildLoginAlert(context);
                }
              },
              child: Row(
                children: [
                  AuthService().currentUser != null
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
                          child: Text(LocaleKeys.log_out.tr()),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  AuthService().currentUser != null
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

  Widget buildSaveButton() {
    return FutureBuilder(
        future: widget.theRecipes,
        builder: (context, snapshot) {
          return ElevatedButton(
            onPressed: () async {
              if (selectedRecipe != null) {
                if (AuthService().currentUser != null) {
                  if (_menuItem == MenuItems.my) {
                    final response = await ApiManager.deleteClientRecipe(
                        widget.user!.uid, selectedRecipe!.recipeId);
                    print('delete response: ${response.statusCode}');
                    widget.theRecipes =
                        ApiManager.getRecipesOfClientId(widget.user!.uid);
                  } else {
                    //if (selectedRecipe!.price == 0) {
                    final response = await ApiManager.postClientRecipe({
                      'clientId': AuthService().currentUser!.uid,
                      'recipeId': selectedRecipe!.recipeId
                    });
                    print('response: ${response.statusCode}');
                    //} else {
                    //TODO: add payments
                    //}
                    widget.theRecipes = ApiManager.getRecipes(
                        clientId:
                            widget.user != null ? widget.user!.uid : null);
                  }
                  widget.theRecipes!.then((value) {
                    setState(() {
                      selectedIndex = 0;
                      if (value.isEmpty) {
                        selectedRecipe = null;
                      } else {
                        selectedRecipe = value[0];
                      }
                    });
                  });
                } else {
                  buildLoginAlert(context);
                }
              }
            },
            child: selectedRecipe == null
                ? const SizedBox()
                : Text(_menuItem == MenuItems.my
                    ? LocaleKeys.remove.tr()
                    : selectedRecipe!.price == 0
                        ? LocaleKeys.save_button.tr()
                        : LocaleKeys.buy_button.tr()),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print('2user == null ${widget.user == null}');
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
