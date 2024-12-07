import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notebook_app/service/AppService.dart';
import 'package:notebook_app/widgets/ListCard.dart';

class ListsTab extends StatelessWidget {
  final List<dynamic> lists;
  final Function(String id) onDelete;
  final Function(String id) onEdit;
  final Function(String id, bool value) onChanged;
  final int crossCount;
  bool isChecked;

  ListsTab({
    super.key,
    required this.lists,
    required this.onDelete,
    required this.onEdit,
    required this.crossCount,
    required this.onChanged,
    required this.isChecked,
  });

  Map<String, Color> colorNames = {
    //renk keyleri ve renk valuelerinden oluşan bir map yaptık
    "red": Colors.red,
    "blue": Colors.blue,
    "green": Colors.green,
    "yellow": Colors.yellow,
    "black": Colors.black,
    "white": Colors.white,
    "orange": Colors.orange,
    "grey": Colors.grey,
    "purple": Colors.purple,
    "cyan": Colors.cyan,
  };

  //burada da bu keyler girildiğinde karşılığındaki renk valuesini veren/döndüren/return eden bir mapper var
  Color parseColorByName(String colorName) {
    return colorNames[colorName.toLowerCase()] ??
        Colors.transparent; // Bulamazsa şeffaf döner
  }

  @override
  Widget build(BuildContext context) {
    int cross = crossCount;

    return MasonryGridView.builder(
      padding: EdgeInsets.only(bottom: 90),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        Color color = parseColorByName(list['color']);
        return ListCard(
          id: list['id'].toString(),
          listItem: list['list'],
          isChecked: list['isChecked'],
          onDelete: onDelete,
          onCheckboxChanged: onChanged,
          onEdit: onEdit,
          cardColor:
              color, //burada diğer metodlar gibi yapmayacağız; çünkü renk verisini işleyip widgetlerde kullanılır hale getirmeliyiz.
        );
      },
    );
  }
}
