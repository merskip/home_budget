import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, ValueRange;
import 'package:math_expressions/math_expressions.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:home_budget/model/budget_configuration.dart';
import 'package:home_budget/model/entry_metadata.dart';
import 'package:intl/intl.dart';

import 'main.dart';

class AddEntryPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  const AddEntryPage(this.budgetConfiguration, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEntryState();
}

class AddEntryState extends State<AddEntryPage> {

  List<CellMetadata> cellsMetadata;
  Map<CellMetadata, String> userEnteredValues = {};
  Map<CellMetadata, double> calculatedValues = {};
  bool _processingForm = false;

  FocusNode _amountFocusNode = FocusNode();

  Map<CellMetadata, TextEditingController> textEditingControllers = {};

  _onSubmit() async {
    setState(() {
      _processingForm = true;
    });

    final values = cellsMetadata.map(
        (cellMetadata) => calculatedValues[cellMetadata] ?? userEnteredValues[cellMetadata]
    ).toList();

    final valueRequest = ValueRange();
    valueRequest.majorDimension = "ROWS";
    valueRequest.values = [values];

    try {
      await SheetsApi(httpClient).spreadsheets.values.append(
        valueRequest,
        widget.budgetConfiguration.spreadsheetId, widget.budgetConfiguration.dataRange,
        valueInputOption: "USER_ENTERED"
      );

      setState(() {
        Navigator.of(context).pop(true);
      });
    }
    catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);

      setState(() {
        _processingForm = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cellsMetadata = widget.budgetConfiguration.entryMetadata.cellsMetadata.values.toList();
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
        textTheme: Theme.of(context).textTheme,
        brightness: Brightness.light,
        title: Text("Add new an entry"),
      ),
      body: FormKeyboardActions(
        child: ListView.separated(
          controller: ScrollController(),
          padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(),
          itemCount: cellsMetadata.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < cellsMetadata.length) {
              final cellMetadata = cellsMetadata[index];
              return _buildFormItem(context, cellMetadata);
            }
            else {
              return RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text("Add entry"),
                onPressed: !_processingForm ? _onSubmit : null
              );
            }
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
          return _buildTextFormItem(cellMetadata);
        case DisplayType.amount:
          return _buildAmountFormItem(context, cellMetadata);
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
    final value = userEnteredValues.putIfAbsent(cellMetadata, () => "");
    final controller = textEditingControllers.putIfAbsent(cellMetadata, () => TextEditingController(text: value));
    controller.addListener(() => userEnteredValues[cellMetadata] = controller.text);

    return TextField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        border: OutlineInputBorder(),
        prefixIcon: isTitle ? Icon(Icons.title) : null,
      ),
      controller: controller
    );
  }

  _buildAmountFormItem(BuildContext context, CellMetadata cellMetadata) {
    final value = userEnteredValues.putIfAbsent(cellMetadata, () => "");
    final controller = textEditingControllers.putIfAbsent(cellMetadata, () => TextEditingController(text: value));

    controller.addListener(() {
      userEnteredValues[cellMetadata] = controller.text;

      setState(() {
        calculatedValues[cellMetadata] = _calculateExpressionOrNull(controller.text);
      });
    });

    FormKeyboardActions.setKeyboardActions(context, KeyboardActionsConfig(
      nextFocus: false,
      actions: [
        KeyboardAction(
          focusNode: _amountFocusNode,
          closeWidget: Row(
            children: <Widget>[
              _keyboardCharButton("+", controller),
              _keyboardCharButton("-", controller),
              _keyboardCharButton("*", controller),
              _keyboardCharButton("/", controller),
              _keyboardCharButton("(", controller),
              _keyboardCharButton(")", controller),
            ])
        )
      ]
    ));

    return TextField(
      decoration: InputDecoration(
        labelText: cellMetadata.title,
        prefixIcon: Icon(Icons.attach_money),
        suffix: calculatedValues[cellMetadata] != null ? Text("= ${calculatedValues[cellMetadata]} zł") : Text("zł"),
        border: OutlineInputBorder(),
      ),
      textAlign: TextAlign.right,
      focusNode: _amountFocusNode,
      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
      controller: controller
    );
  }

  _keyboardCharButton(String text, TextEditingController controller) =>
    SizedBox(
      width: 48,
      child: FlatButton(
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          setState(() {
            controller.text = controller.text + text;
            controller.selection = TextSelection.collapsed(offset: controller.text.length);
          });
        }
      )
    );

  double _calculateExpressionOrNull(String text) {
    final normalizedText = text.replaceAll(RegExp(r"[^0-9]+$"), ''); // Removing all non-number chars after the last number in string
    return _evaluateComplexExpressionOrNull(text) ?? _evaluateComplexExpressionOrNull(normalizedText);
  }

  double _evaluateComplexExpressionOrNull(String text) {
    try {
      final expression = Parser().parse(text);
      if (expression is Number)
        return null;

      final result = expression.evaluate(EvaluationType.REAL, ContextModel()) as double;
      return (result * 100).round() / 100.0; // Round to 2 decimal places
    }
    catch (_) {
      return null;
    }
  }

  _buildDateFormItem(BuildContext context, CellMetadata cellMetadata) {
    final dateFormat = DateFormat(cellMetadata.dateFormat);
    DateTime enteredDate = userEnteredValues[cellMetadata] != null ? dateFormat.parse(userEnteredValues[cellMetadata]) : DateTime.now();
    userEnteredValues[cellMetadata] = dateFormat.format(enteredDate);

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
    userEnteredValues[cellMetadata] = delegate.groupValue;

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