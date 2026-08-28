import 'package:flutter/material.dart';

enum OnboardingGoal {
  quran(Icons.menu_book_rounded),
  prayer(Icons.mosque_rounded),
  duas(Icons.volunteer_activism_rounded),
  dhikr(Icons.touch_app_rounded),
  names(Icons.auto_awesome_rounded),
  all(Icons.eco_rounded);

  const OnboardingGoal(this.icon);

  final IconData icon;
}

abstract final class OnboardingStorage {
  static const completed = 'onboardingCompleted';
  static const legacyCompleted = 'nurr_onboarding_seen_v2';
  static const goals = 'nurr_onboarding_goals';
  static const locationChoice = 'nurr_onboarding_location_choice';
  static const manualLocation = 'nurr_onboarding_manual_location';
}
