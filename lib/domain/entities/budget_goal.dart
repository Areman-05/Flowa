import 'package:equatable/equatable.dart';

/// Monthly spending cap the user can track in Insights.
class BudgetGoal extends Equatable {
  const BudgetGoal({required this.monthlyLimit, this.enabled = false});

  final double monthlyLimit;
  final bool enabled;

  double progressFor(double spent) {
    if (monthlyLimit <= 0) {
      return 0;
    }
    return (spent / monthlyLimit).clamp(0, 1);
  }

  bool isOverBudget(double spent) => enabled && spent > monthlyLimit;

  BudgetGoal copyWith({double? monthlyLimit, bool? enabled}) {
    return BudgetGoal(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [monthlyLimit, enabled];
}
