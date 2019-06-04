import 'package:flutter/material.dart';
import 'package:home_budget/data/budget_sheet_config.dart';

class ColumnConfigurationScreen extends StatefulWidget {

  final ColumnDescription columnDescription;

  const ColumnConfigurationScreen(this.columnDescription, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColumnConfigurationState();
}

class _ColumnConfigurationState extends State<ColumnConfigurationScreen> {

  ColumnDescription columnDescription;

  TextEditingController _titleController;
  TextEditingController _dateFormatController;
  DisplayType _displayType;

  @override
  void initState() {
    super.initState();
    this.columnDescription = widget.columnDescription;
    _titleController = TextEditingController(text: columnDescription.title);
    _dateFormatController = TextEditingController(text: columnDescription.dateFormat);
    _displayType = columnDescription.displayType;
  }

  _onBackPressed(BuildContext context) {
    final updatedColumnDescription = ColumnDescription(
      _titleController.text,
      _displayType,
      columnDescription.range,
      columnDescription.valueValidation,
      _dateFormatController.text,
      columnDescription.validationValues
    );
    Navigator.pop(context, updatedColumnDescription);
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("Column ${columnDescription.range}"),
        leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: () => _onBackPressed(context),
        )
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            _titleControl(),
            SizedBox(height: 8),
            _displayTypeControl(),
            SizedBox(height: 8),
            if (_displayType == DisplayType.date) _dateFormatControl(),
            SizedBox(height: 8),
            _valueValidationPreview()
          ]
        )
      )
    );

  Widget _titleControl() =>
    TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Column title"
      ),
      controller: _titleController
    );

  Widget _displayTypeControl() =>
    Row(children: <Widget>[
      Text("Display as"),
      SizedBox(width: 8),
      DropdownButtonHideUnderline(
        child: DropdownButton(
          value: _displayType,
          items: DisplayType.values.map(
              (displayType) => _displayTypeDropdownMenuItem(displayType)
          ).toList(),
          onChanged: (displayType) {
            setState(() {
              this._displayType = displayType;
            });
          }
        )
      ),
    ]);

  DropdownMenuItem _displayTypeDropdownMenuItem(DisplayType displayType) =>
    DropdownMenuItem(
      value: displayType,
      child: Row(children: [
        Icon(DisplayTypeHelper.getIcon(displayType), color: Colors.grey),
        SizedBox(width: 8),
        Text(DisplayTypeHelper.getTitle(displayType))
      ])
    );

  Widget _dateFormatControl() =>
    TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Date format"
      ),
      controller: _dateFormatController
    );

  Widget _valueValidationPreview() {
    switch (columnDescription.valueValidation) {
      case ValueValidation.oneOfList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("The value is to choose one of:"),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                columnDescription.validationValues.map((value) => "•  $value").join("\n"),
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.6
                ))
            )
          ],
        );
      case ValueValidation.none:
      default:
        return SizedBox.shrink();
    }
  }
}