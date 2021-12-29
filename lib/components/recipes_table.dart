import 'package:flutter/material.dart';
import 'package:home_brewery/model/recipe.dart';

class RecipesTable extends StatefulWidget {
  const RecipesTable({required this.recipes, Key? key}) : super(key: key);

  final List<Recipe> recipes;

  @override
  _RecipesTableState createState() => _RecipesTableState();
}

class _RecipesTableState extends State<RecipesTable> {

  Widget buildDataTable(List<Recipe> recipes) {
    final columns = ['name', 'abv', 'ibu', 'og', 'fg', 'ba', 'price'];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(recipes),
    );
  }

  List<DataColumn> getColumns(List<String> columns) =>
      columns
          .map(
            (colName) =>
            DataColumn(
              label: Text(colName),
            ),
      )
          .toList();

  List<DataRow> getRows(List<Recipe> recipes) =>
      recipes.map((recipe) {
        final cells = [
          recipe.name,
          recipe.abv,
          recipe.ibu,
          recipe.og,
          recipe.fg,
          recipe.ba,
          recipe.price,
        ];
        return DataRow(cells: getCells(cells));
      }).toList();

  List<DataCell> getCells(List<dynamic> cells)=>
      cells.map((cell) => DataCell(
        Text('$cell')
      )).toList();

  @override
  Widget build(BuildContext context) {
    return buildDataTable(widget.recipes);
  }
}
