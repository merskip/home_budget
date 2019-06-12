import 'package:flutter/material.dart';
import '../data/budget_sheet_config.dart';

class ColumnDescriptionListTile extends StatelessWidget {

  final ColumnDescription columnDescription;
  final Widget trailing;

  const ColumnDescriptionListTile({Key key, this.columnDescription, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
    ListTile(
      isThreeLine: true,
      leading: Icon(DisplayTypeHelper.getIcon(columnDescription.displayType)),
      title: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(columnDescription.title)
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text([
          "Column ${columnDescription.range}",
          _getDisplayedAsText(columnDescription),
          if (columnDescription.exampleValue != null) "Example: ${columnDescription.exampleValue}"
        ].join("\n"))),
      trailing: trailing,
    );

  String _getDisplayedAsText(ColumnDescription columnDescription) {
    final displayTypeTitle = DisplayTypeHelper.getTitle(columnDescription.displayType).toLowerCase();
    if (columnDescription.valueValidation == ValueValidation.oneOfList)
      return "Combo box with $displayTypeTitle";
    else
      return "Displayed as $displayTypeTitle";
  }
}