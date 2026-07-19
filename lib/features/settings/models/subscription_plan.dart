enum SubscriptionPlan {
  solo,
  pro,
}

extension SubscriptionPlanLabel on SubscriptionPlan {
  String get label {
    switch (this) {
      case SubscriptionPlan.solo:
        return 'Solo';
      case SubscriptionPlan.pro:
        return 'Pro';
    }
  }

  bool get canEditReportStructure => this == SubscriptionPlan.pro;
}
