import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/models/subscription_plan.dart';
import 'android_billing_card.dart';
import 'apple_billing_card.dart';
import 'stripe_billing_card.dart';

class PlatformBillingCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String? missionId;

  const PlatformBillingCard({super.key, required this.plan, this.missionId});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidBillingCard(plan: plan, missionId: missionId);
    }
    if (Platform.isWindows) {
      return StripeBillingCard(plan: plan, missionId: missionId);
    }
    if (Platform.isIOS) {
      return AppleBillingCard(plan: plan, missionId: missionId);
    }
    return const Card(
      color: Color(0xFFFFF7ED),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Le paiement Apple sera disponible après le lot d’intégration iPhone/iPad.',
        ),
      ),
    );
  }
}
