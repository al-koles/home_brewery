// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
  "all_recipes": "All recipes",
  "my_recipes": "My recipes",
  "save_button": "Save",
  "buy_button": "Buy",
  "recipe_name": "name",
  "price": "price"
};
static const Map<String,dynamic> uk = {
  "all_recipes": "Усі рецепти",
  "my_recipes": "Мої рецепти",
  "save_button": "Зберегти",
  "buy_button": "Купити",
  "recipe_name": "назва",
  "price": "ціна"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "uk": uk};
}
