import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// 初回体験が完了しているか
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return OnboardingService.hasCompletedOnboarding();
});

/// 初回体験を完了としてマークする
final onboardingCompleteNotifierProvider =
    Provider<OnboardingCompleteNotifier>((ref) {
  return OnboardingCompleteNotifier();
});

class OnboardingCompleteNotifier {
  Future<void> markCompleted() async {
    await OnboardingService.setOnboardingCompleted(true);
  }

  Future<void> reset() async {
    await OnboardingService.resetOnboarding();
  }
}
