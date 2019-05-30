import 'package:flutter/material.dart';
import 'package:home_budget/data/budget_sheet_config.dart';

class EntryCellConfigurationPage extends StatefulWidget {

  final ColumnDescription cellMetadata;

  const EntryCellConfigurationPage(this.cellMetadata, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EntryCellConfigurationState();
}

class EntryCellConfigurationState extends State<EntryCellConfigurationPage> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController;
  TextEditingController _dateFormatController;
  DisplayType _selectedDisplayType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.cellMetadata.title);
    _dateFormatController = TextEditingController(text: widget.cellMetadata.dateFormat);
    _selectedDisplayType = widget.cellMetadata.displayType;
  }

  _onBackPressed(BuildContext context) {
    final newCellMetadata = ColumnDescription(
      _titleController.text,
      _selectedDisplayType,
      widget.cellMetadata.valueValidation,
      _dateFormatController.text,
      widget.cellMetadata.validationValues
    );
    Navigator.pop(context, newCellMetadata);
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("Configuration of ${widget.cellMetadata.title}"),
        leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: () => _onBackPressed(context),
        )
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: "Title"),
              controller: _titleController
            ),
            Row(
              children: <Widget>[
                Text("Display type: "),
                DropdownButton(
                  items: DisplayType.values.map((displayType) {
                    return DropdownMenuItem(value: displayType, child: Text(displayType.toString()));
                  }).toList(),
                  value: this._selectedDisplayType,
                  onChanged: (displayType) {
                    setState(() {
                      this._selectedDisplayType = displayType;
                    });
                  }
                )
              ]
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "date format"),
              controller: _dateFormatController
            ),
            Text("Value validation: ${widget.cellMetadata.valueValidation.toString()}"),
            if (widget.cellMetadata.validationValues != null) Text("Validation values:\n- " + widget.cellMetadata.validationValues?.join("\n- "))
          ]
        )
      )
    );

}