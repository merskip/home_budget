
import 'package:json_annotation/json_annotation.dart';

import 'package:home_budget/data/budget_sheet_config.dart';
part 'application_config.g.dart';

@JsonSerializable()
class ApplicationConfig {

  final List<BudgetSheetConfig> budgetSheetsConfigs;
  final int defaultConfigIndex;

  BudgetSheetConfig get defaultBudgetSheetConfig => budgetSheetsConfigs[defaultConfigIndex];

  ApplicationConfig(this.budgetSheetsConfigs, this.defaultConfigIndex);

  factory ApplicationConfig.fromJson(Map<String, dynamic> json) => _$ApplicationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationConfigToJson(this);
}