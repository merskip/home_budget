import 'package:flutter/material.dart';
import 'package:home_budget/model/budget_configuration.dart';
import 'package:home_budget/model/entry_metadata.dart';
import 'package:intl/intl.dart';

class AddEntryPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  const AddEntryPage(this.budgetConfiguration, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEntryState();
}

class AddEntryState extends State<AddEntryPage> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: Theme
          .of(context)
          .iconTheme,
        textTheme: Theme
          .of(context)
          .textTheme,
        title: Text("Add new an entry"),
      ),
      body: Form(
        key: _formKey,
        child: ListView.separated(
          padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(),
          itemCount: widget.budgetConfiguration.entryMetadata.cellsMetadata.length,
          itemBuilder: (BuildContext context, int index) {
            final cellMetadata = widget.budgetConfiguration.entryMetadata.cellsMetadata[index.toString()];
            return _buildFormItem(context, cellMetadata);
          },
          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16)
        )
      )
    );

  _buildFormItem(BuildContext context, CellMetadata cellMetadata) {
    if (cellMetadata.valueValidation == ValueValidation.none) {
      switch (cellMetadata.displayType) {
        case DisplayType.text:
        case DisplayType.title:
        case DisplayType.amount:
          return _buildAmountFormItem(cellMetadata);
        case DisplayType.date:
          return _buildDateFormItem(context, cellMetadata);
        case DisplayType.category:
          return _buildTextFormItem(cellMetadata);
      }
    }
    else if (cellMetadata.valueValidation == ValueValidation.oneOfList) {
      return _buildComboBoxFormItem(cellMetadata);
    }
  }

  _buildTextFormItem(CellMetadata cellMetadata) =>
    TextFormField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        border: OutlineInputBorder(),
      )
    );

  _buildAmountFormItem(CellMetadata cellMetadata) =>
    TextFormField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        border: OutlineInputBorder(),
        suffixText: "zł",
      ),
      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true)
    );

  _buildDateFormItem(BuildContext context, CellMetadata cellMetadata) =>
    InkWell(
      onTap: () async {
        final monthBeforeNowDate = DateTime.now().add(Duration(days: -30));
        final monthAfterNowDate = DateTime.now().add(Duration(days: 30));
        final selectedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: monthBeforeNowDate, lastDate: monthAfterNowDate);
        print(selectedDate);
      },

      child: AbsorbPointer(child: TextFormField(
        decoration: InputDecoration(
          labelText: cellMetadata.title,
          border: OutlineInputBorder(),
        ),
        initialValue: DateFormat(cellMetadata.dateFormat).format(DateTime.now()),
      ))
    );

  _buildComboBoxFormItem(CellMetadata cellMetadata) {
    final values = cellMetadata.validationValues;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(cellMetadata.title),
        if (values.length > 6) _dropdownButton(cellMetadata, values.length, (index) => values[index]),
        if (values.length <= 6 && values.length > 3) _verticalRadioGroup(cellMetadata, values.length, (index) => values[index]),
        if (values.length <= 3) _horizontalRadioGroup(cellMetadata, values.length, (index) => values[index]),
      ],
    );
  }

  Widget _horizontalRadioGroup<T>(T groupValue, int valueCount, String Function(int index) valueBuilder) =>
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: List.generate(valueCount, (index) {
          final value = valueBuilder(index);
          return InkWell(
            customBorder: ContinuousRectangleBorder(),
            child: Row(
              children: <Widget>[
                Radio(
                  value: value,
                  groupValue: groupValue,
                  onChanged: null
                ),
                Text(value),
                SizedBox(width: 8)
              ],
            ),
            onTap: () {},
          );
        }).toList()
      )
    );

  Widget _verticalRadioGroup<T>(T groupValue, int valueCount, String Function(int index) valueBuilder) =>
    Column(
      children: List.generate(valueCount, (index) {
        final value = valueBuilder(index);
        return InkWell(
          child: Row(
            children: <Widget>[
              Radio(
                value: value,
                groupValue: groupValue,
                onChanged: null
              ),
              Text(value)
            ],
          ),
          onTap: () {},
        );
      }).toList()
    );

  Widget _dropdownButton<T>(T groupValue, int valueCount, String Function(int index) valueBuilder) =>
    DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        items: List.generate(valueCount, (index) {
          final value = valueBuilder(index);
          return DropdownMenuItem(
            value: value,
            child: Text(value)
          );
        }), onChanged: (value) {},
      )
    );
}