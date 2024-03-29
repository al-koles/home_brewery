import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:home_brewery/constants.dart';
import 'package:home_brewery/model/recipe.dart';
import 'package:home_brewery/translations/locale_keys.g.dart';

class RecipesTable extends StatefulWidget {
  RecipesTable({
    required this.recipes,
    required this.rowSelected,
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  final List<Recipe> recipes;
  final Function rowSelected;
  int selectedIndex = 0;

  @override
  _RecipesTableState createState() => _RecipesTableState();
}

class _RecipesTableState extends State<RecipesTable> {
  int? sortColumnIndex;
  bool isAsc = false;

  Widget buildDataTable(List<Recipe> recipes) {
    final columns = [LocaleKeys.recipe_name.tr(), 'abv', 'ibu', 'og', 'fg', 'ba', LocaleKeys.price.tr()];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 265,
        //margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: Constants.boxDecoration,
        child: SingleChildScrollView(
          child: DataTable(
            sortAscending: isAsc,
            sortColumnIndex: sortColumnIndex,
            columns: getColumns(columns),
            rows: getRows(recipes),
          ),
        ),
      ),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map(
        (colName) => DataColumn(
          label: Text(colName),
          onSort: (int columnIndex, bool asc) {
            widget.recipes.sort((r1, r2) {
              switch (columnIndex) {
                case 0:
                  return !asc
                      ? r1.name.compareTo(r2.name)
                      : r2.name.compareTo(r1.name);
                case 1:
                  return !asc
                      ? r1.abv.compareTo(r2.abv)
                      : r2.abv.compareTo(r1.abv);
                case 2:
                  return !asc
                      ? r1.ibu.compareTo(r2.ibu)
                      : r2.ibu.compareTo(r1.ibu);
                case 3:
                  return !asc ? r1.og.compareTo(r2.og) : r2.og.compareTo(r1.og);
                case 4:
                  return !asc ? r1.fg.compareTo(r2.fg) : r2.fg.compareTo(r1.fg);
                case 5:
                  return !asc ? r1.ba.compareTo(r2.ba) : r2.ba.compareTo(r1.ba);
                case 6:
                  return !asc
                      ? r1.price.compareTo(r2.price)
                      : r2.price.compareTo(r1.price);
                default:
                  return !asc
                      ? r1.name.compareTo(r2.name)
                      : r2.name.compareTo(r1.name);
              }
            });
            setState(() {
              sortColumnIndex = columnIndex;
              isAsc = asc;
            });
          },
        ),
      )
      .toList();

  List<DataRow> getRows(List<Recipe> recipes) {
    List<DataRow> rows = [];
    for (int i = 0; i < recipes.length; i++) {
      final cells = [
        recipes[i].name,
        recipes[i].abv,
        recipes[i].ibu,
        recipes[i].og,
        recipes[i].fg,
        recipes[i].ba,
        recipes[i].price,
      ];
      rows.add(DataRow(
        cells: getCells(cells),
        selected: widget.selectedIndex == i,
        onSelectChanged: (_) {
          widget.rowSelected(recipes[i], i);
          setState(() {
            widget.selectedIndex = i;
          });
        },
      ));
    }
    return rows;
  }

  List<DataCell> getCells(List<dynamic> cells) =>
      cells.map((cell) => DataCell(Text('$cell'))).toList();

  @override
  Widget build(BuildContext context) {
    return buildDataTable(widget.recipes);
  }
}
