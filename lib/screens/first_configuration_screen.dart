import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Sheet;

import '../main.dart';
import 'choose_sheet_page.dart';
import '../util/google_http_client.dart';

class FirstConfigurationScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _FirstConfigurationState();
}

class _FirstConfigurationState extends State<FirstConfigurationScreen> {

  final _signInStepItem = _SignInStepItem();
  final _chooseSpreadsheetStepItem = _ChooseSpreadsheetStepItem();
  final _enterDataRangeStepItem = _EnterDataRangeStepItem();
  final _configureSheetStepItem = _ConfigureSheetStepItem();

  int currentStepIndex = 0;
  List<_StepItem> stepsItems;

  _StepItem get currentStepItem => stepsItems[currentStepIndex];

  _FirstConfigurationState() {
    stepsItems = [
      _signInStepItem, _chooseSpreadsheetStepItem, _enterDataRangeStepItem, _configureSheetStepItem
    ];
    for (var stepItem in stepsItems) {
      stepItem.finishStep = _onFinishStep;
    }
  }

  @override
  void initState() {
    currentStepItem.onShow();
    super.initState();
  }

  _onFinishStep() {
    _synchronizeDataBetweenSteps();
    setState(() {
      currentStepIndex++;
      currentStepItem.onShow();
    });
  }

  _onCancelStep() {
    setState(() {
      currentStepIndex--;
      currentStepItem.onShow();
    });
  }

  _synchronizeDataBetweenSteps() {
    _enterDataRangeStepItem.spreadsheetFile = _chooseSpreadsheetStepItem.spreadsheetFile;
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("First configuration"),
      ),
      body: Container(
        child: Stepper(
          physics: BouncingScrollPhysics(),
          currentStep: currentStepIndex,
          type: StepperType.vertical,
          steps: stepsItems.map(
              (stepItem) {
              final index = stepsItems.indexOf(stepItem);
              return stepItem.buildStep(context, index == currentStepIndex, index < currentStepIndex);
            }
          ).toList(),
          controlsBuilder: (context, {onStepContinue, onStepCancel}) {
            final continueWidget = currentStepItem.continueWidget(context);
            return Row(
              children: <Widget>[
                if (continueWidget != null) continueWidget,
                if (onStepCancel != null) FlatButton(
                  onPressed: onStepCancel,
                  child: Text('Back'),
                ),
              ],
            );
          },
          onStepCancel: currentStepIndex > 0 ? _onCancelStep : null
        ),
      )
    );
}

abstract class _StepItem {

  VoidCallback finishStep;

  Step buildStep(BuildContext context, bool isCurrent, bool isCompleted);

  Widget continueWidget(BuildContext context) => null;

  void onShow();
}

class _SignInStepItem extends _StepItem {

  GoogleSignInAccount account;

  @override
  Step buildStep(BuildContext context, bool isCurrent, bool isCompleted) =>
    Step(
      title: Text("Sign in"),
      subtitle: account == null ? Text("Log in with your Google account") : Text("Logged as ${account.displayName}"),
      isActive: isCurrent || isCompleted,
      state: isCompleted ? StepState.complete : StepState.indexed,
      content: SizedBox.shrink()
    );

  Widget continueWidget(BuildContext context) =>
    GoogleSignInButton(
      borderRadius: 38 / 2,
      text: "Sign in with Google  ", // with fake padding on right
      onPressed: _signIn
    );

  @override
  void onShow() {
    account = null;
    _configureAuthorization();
    googleSignIn.signOut();
  }

  _signIn() async {
    account = await googleSignIn.signIn();
    _configureAuthorization();
    if (account != null)
      finishStep();
  }

  _configureAuthorization() async {
    if (account == null) {
      httpClient = null;
      httpHeaders = null;
    }
    else {
      httpHeaders = await googleSignIn.currentUser.authHeaders;
      httpClient = GoogleHttpClient(httpHeaders);
    }
  }
}

class _ChooseSpreadsheetStepItem extends _StepItem {

  File spreadsheetFile;

  @override
  Step buildStep(BuildContext context, bool isCurrent, bool isCompleted) =>
    Step(
      title: Text("Choose spreadsheet"),
      subtitle: spreadsheetFile != null ? Text("Selected spreadsheet ${spreadsheetFile.name}") : null,
      content: SizedBox.shrink(),
      isActive: isCurrent || isCompleted,
      state: isCompleted ? StepState.complete : StepState.indexed,
    );

  Widget continueWidget(BuildContext context) =>
    RaisedButton(
      child: Text("Select on Google Drive"),
      onPressed: () => _selectSpreadsheet(context)
    );

  @override
  void onShow() {
    spreadsheetFile = null;
  }

  _selectSpreadsheet(BuildContext context) async {
    spreadsheetFile = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChooseSpreadsheetPage()));
    if (spreadsheetFile != null)
      finishStep();
  }
}

class _EnterDataRangeStepItem extends _StepItem {

  File spreadsheetFile;
  Sheet selectedSheet;

  final _sheetsStreamController = StreamController<List<Sheet>>();

  Stream<List<Sheet>> get _sheets => _sheetsStreamController.stream;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode dataRangeFocus = FocusNode();
  String dataRange;

  Future<List<Sheet>> _fetchSheetsList() async {
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(this.spreadsheetFile.id, includeGridData: false);
    return spreadsheet.sheets;
  }

  @override
  void onShow() async {
    _sheetsStreamController.add(null);
    selectedSheet = null;
    dataRange = null;
    final sheets = await _fetchSheetsList();
    _sheetsStreamController.add(sheets);
  }

  @override
  Step buildStep(BuildContext context, bool isCurrent, bool isCompleted) =>
    Step(
      title: Text("Enter data range"),
      content: StreamBuilder(
        stream: _sheets,
        builder: (context, AsyncSnapshot<List<Sheet>> snapshot) {
          final sheets = snapshot.data;
          if (sheets == null) {
            return CircularProgressIndicator();
          }
          else {
            return StatefulBuilder(builder: (context, setState) =>
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _sheetsChips(context, sheets, setState),
                  _dataRangeControl(context)
                ]
              )
            );
          }
        }),
      isActive: isCurrent || isCompleted,
      state: isCompleted ? StepState.complete : StepState.indexed,
    );

  Widget _sheetsChips(BuildContext context, List<Sheet> sheets, StateSetter setState) =>
    Wrap(
      spacing: 8,
      children: sheets.map((sheet) =>
        ChoiceChip(
          label: Text(sheet.properties.title),
          selected: selectedSheet == sheet,
          onSelected: (isSelected) {
            setState(() {
              if (isSelected) {
                selectedSheet = sheet;
                FocusScope.of(context).requestFocus(dataRangeFocus);
              }
              else if (!isSelected && selectedSheet == sheet)
                selectedSheet = null;
            });
          },
        )
      ).toList(),
    );

  Widget _dataRangeControl(BuildContext context) =>
    Form(
      key: _formKey,
      child:
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Data range",
            hintText: "A1:D",
            helperText: "Without header row in A1 format",
            isDense: true,
            prefixIcon: Icon(Icons.grid_on),
          ),
          enabled: selectedSheet != null,
          focusNode: dataRangeFocus,
          autocorrect: false,
          initialValue: dataRange,
          validator: _validateDataRange,
          onSaved: (value) => dataRange = value,
        )
      )
    );

  String _validateDataRange(String value) {
    final a1Regex = RegExp(r"[a-zA-Z]+[0-9]+:[a-zA-Z]+");
    if (!a1Regex.hasMatch(value)) {
      return "Enter range in A1 notation, eg. A1:B";
    }
    return null;
  }

  @override
  Widget continueWidget(BuildContext context) =>
    RaisedButton(
      child: Text("Continue"),
      onPressed: _onContinuePressed
    );

  _onContinuePressed() {
    final form = _formKey.currentState;
    if (selectedSheet != null && form.validate()) {
      finishStep();
    }
  }
}

class _ConfigureSheetStepItem extends _StepItem {

  @override
  Step buildStep(BuildContext context, bool isCurrent, bool isCompleted) =>
    Step(
      title: Text("Configure sheet"),
      content: SizedBox.shrink(),
      isActive: isCurrent || isCompleted,
      state: isCompleted ? StepState.complete : StepState.indexed,
    );

  @override
  void onShow() {
    // TODO: implement onShow
  }
}