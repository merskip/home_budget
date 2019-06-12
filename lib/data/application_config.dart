
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/budget_sheet_config.dart';
import '../main.dart';

part 'application_config.g.dart';

@JsonSerializable()
class ApplicationConfig {

  final List<BudgetSheetConfig> budgetSheetsConfigs;
  final int defaultConfigIndex;

  BudgetSheetConfig get defaultBudgetSheetConfig => budgetSheetsConfigs[defaultConfigIndex];

  ApplicationConfig(this.budgetSheetsConfigs, this.defaultConfigIndex);

  static Future<ApplicationConfig> readFromPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      final json = preferences.getString(prefsApplicationConfig);
      if (json != null) return ApplicationConfig.fromJson(jsonDecode(json));
    } catch (e) {
      print(e);
      preferences.remove(prefsApplicationConfig);
    }
    return null;
  }

  saveToPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(prefsApplicationConfig, jsonEncode(toJson()));
  }

  factory ApplicationConfig.fromJson(Map<String, dynamic> json) => _$ApplicationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationConfigToJson(this);
}