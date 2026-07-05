import 'package:flutter/material.dart';

enum OnboardingIllustration {
  attendance,
  homework,
  timetable,
  fees,
  connect,
}

class OnboardingItem {
  final String title;
  final String description;
  final OnboardingIllustration illustration;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.illustration,
    required this.accentColor,
  });
}
