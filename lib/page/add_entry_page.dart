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

  Map<CellMetadata, String> userEnteredValues = {};

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
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        physics: BouncingScrollPhysics(),
        itemCount: widget.budgetConfiguration.entryMetadata.cellsMetadata.length,
        itemBuilder: (BuildContext context, int index) {
          final cellMetadata = widget.budgetConfiguration.entryMetadata.cellsMetadata[index.toString()];
          return _buildFormItem(context, cellMetadata);
        },
        separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16)
      )
    );

  _buildFormItem(BuildContext context, CellMetadata cellMetadata) {
    if (cellMetadata.valueValidation == ValueValidation.none) {
      switch (cellMetadata.displayType) {
        case DisplayType.text:
        case DisplayType.title:
          return _buildTextFormItem(cellMetadata);
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

  _buildTextFormItem(CellMetadata cellMetadata) {
    final isTitle = cellMetadata.displayType == DisplayType.title;
    final value = userEnteredValues[cellMetadata] ?? "";
    final controller = TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length)));
    controller.addListener(() {
      userEnteredValues[cellMetadata] = controller.text;
    });

    return TextField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        border: OutlineInputBorder(),
        prefixIcon: isTitle ? Icon(Icons.title) : null,
      ),
      autofocus: isTitle,
      controller: controller
    );
  }

  _buildAmountFormItem(CellMetadata cellMetadata) {
    final value = userEnteredValues[cellMetadata] ?? "";
    final controller = TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length)));
    controller.addListener(() {
      userEnteredValues[cellMetadata] = controller.text;
    });

    return TextField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        prefixIcon: Icon(Icons.attach_money),
        suffixText: " zł ",
        border: OutlineInputBorder(),
      ),
      textAlign: TextAlign.right,
      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
      controller: controller
    );
  }

  _buildDateFormItem(BuildContext context, CellMetadata cellMetadata) {
    final dateFormat = DateFormat(cellMetadata.dateFormat);
    DateTime enteredDate = userEnteredValues[cellMetadata] != null ? dateFormat.parse(userEnteredValues[cellMetadata]) : DateTime.now();

    final controller = TextEditingController(text: dateFormat.format(enteredDate));
    return InkWell(
      onTap: () async {
        final monthBeforeNowDate = DateTime.now().add(Duration(days: -30));
        final monthAfterNowDate = DateTime.now().add(Duration(days: 30));
        final selectedDate = await showDatePicker(context: context, initialDate: enteredDate, firstDate: monthBeforeNowDate, lastDate: monthAfterNowDate);
        if (selectedDate != null) {
          userEnteredValues[cellMetadata] = dateFormat.format(selectedDate);
          controller.text = dateFormat.format(selectedDate);
          enteredDate = selectedDate;
        }
      },

      child: AbsorbPointer(child: TextFormField(
        decoration: InputDecoration(
          labelText: cellMetadata.title,
          prefixIcon: Icon(Icons.today),
          border: OutlineInputBorder(),
        ),
        controller: controller,
      ))
    );
  }

  _buildComboBoxFormItem(CellMetadata cellMetadata) {
    final values = cellMetadata.validationValues;
    final delegate = _ComboBoxDelegate(
      itemCount: values.length,
      groupValue: userEnteredValues[cellMetadata] ?? values.first,
      value: (index) => values[index],
      onSelected: (value) {
        setState(() {
          userEnteredValues[cellMetadata] = value;
        });
      }
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(cellMetadata.title),
        if (values.length > 6) _dropdownButton(delegate),
        if (values.length <= 6 && values.length > 3) _verticalRadioGroup(delegate),
        if (values.length <= 3) _horizontalRadioGroup(delegate),
      ],
    );
  }

  Widget _horizontalRadioGroup(_ComboBoxDelegate<String> delegate) =>
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: List.generate(delegate.itemCount, (index) {
          final value = delegate.value(index);
          return InkWell(
            customBorder: OutlineInputBorder(),
            child: Row(
              children: <Widget>[
                Radio(
                  value: value,
                  groupValue: delegate.groupValue,
                  onChanged: (_) {}
                ),
                Text(delegate.value(index)),
                SizedBox(width: 8)
              ],
            ),
            onTap: () => delegate.onSelected(value),
          );
        }).toList()
      )
    );

  Widget _verticalRadioGroup(_ComboBoxDelegate<String> delegate) =>
    Column(
      children: List.generate(delegate.itemCount, (index) {
        final value = delegate.value(index);
        return InkWell(
          customBorder: OutlineInputBorder(),
          child: Row(
            children: <Widget>[
              Radio(
                value: value,
                groupValue: delegate.groupValue,
                onChanged: (_) {}
              ),
              Text(value)
            ],
          ),
          onTap: () => delegate.onSelected(value),
        );
      }).toList()
    );

  Widget _dropdownButton(_ComboBoxDelegate<String> delegate) =>
    InkWell(
      customBorder: OutlineInputBorder(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          items: List.generate(delegate.itemCount, (index) {
            return DropdownMenuItem(
              value: delegate.value(index),
              child: Text(delegate.value(index))
            );
          }),
          value: delegate.groupValue,
          onChanged: (value) => delegate.onSelected(value),
        )
      )
    );
}

class _ComboBoxDelegate<T> {

  final int itemCount;
  final T groupValue;
  final T Function(int index) value;

  final void Function(T value) onSelected;

  _ComboBoxDelegate({@required this.itemCount, @required this.groupValue, @required this.value, this.onSelected});
}