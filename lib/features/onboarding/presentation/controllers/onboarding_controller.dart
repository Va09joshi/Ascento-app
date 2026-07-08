import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/onboarding/domain/models/onboarding_item.dart';

class OnboardingState {
  final int currentIndex;
  final List<OnboardingItem> items;
  final bool isLastPage;

  const OnboardingState({
    this.currentIndex = 0,
    required this.items,
    this.isLastPage = false,
  });

  OnboardingState copyWith({
    int? currentIndex,
    List<OnboardingItem>? items,
    bool? isLastPage,
  }) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      items: items ?? this.items,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  final StorageService _storageService;

  OnboardingController(this._storageService)
      : super(OnboardingState(items: _staticOnboardingSlides)) {
    _checkInitialState();
  }

  // Load standard static slides for school management
  static final List<OnboardingItem> _staticOnboardingSlides = [
    const OnboardingItem(
      title: 'Smart Attendance',
      description: 'Ditch the paper registers! Clock in student presence instantly with AI-driven digital roll-calls and auto-notify parents in real time.',
      illustration: OnboardingIllustration.attendance,
      accentColor: AppColors.primary,
    ),
    const OnboardingItem(
      title: 'Homework Tracking',
      description: 'Set daily educational worksheets, track student problem-solving rates, and reward digital star badges for error-free home assignments.',
      illustration: OnboardingIllustration.homework,
      accentColor: AppColors.secondary,
    ),
    const OnboardingItem(
      title: 'Timetable Management',
      description: 'Organize abacus classes, schedule teacher timetables, track classroom hours, and resolve class clashes automatically.',
      illustration: OnboardingIllustration.timetable,
      accentColor: AppColors.info,
    ),
    const OnboardingItem(
      title: 'Fees & Exams',
      description: 'Review digital student fee statuses, manage invoices, schedule academic grading tests, and deliver abacus certification records.',
      illustration: OnboardingIllustration.fees,
      accentColor: AppColors.primary,
    ),
    const OnboardingItem(
      title: 'Parent-Teacher Connect',
      description: 'Bridge school activities and families. Message parent portals, schedule review sessions, and celebrate child milestones together.',
      illustration: OnboardingIllustration.connect,
      accentColor: AppColors.secondary,
    ),
  ];

  void _checkInitialState() {
    state = state.copyWith(
      isLastPage: state.currentIndex == state.items.length - 1,
    );
  }

  // Update Page index from PageView changes
  void handlePageChanged(int index) {
    state = state.copyWith(
      currentIndex: index,
      isLastPage: index == state.items.length - 1,
    );
  }

  // Complete onboarding sequence and persist state
  Future<void> completeOnboarding(VoidCallback onDone) async {
    await _storageService.setOnboardingCompleted(true);
    onDone();
  }
}

// Global Onboarding Controller Provider
final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return OnboardingController(storageService);
});
