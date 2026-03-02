import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tutorial.dart';
import '../services/tutorial_service.dart';

final tutorialServiceProvider = Provider<TutorialService>((ref) => TutorialService());

/// 最初のチュートリアル（display_order 昇順の先頭）のセッション
final firstTutorialSessionProvider = FutureProvider<TutorialSession?>((ref) async {
  final service = ref.read(tutorialServiceProvider);
  final tutorial = await service.getFirstTutorial();
  if (tutorial == null) return null;
  return service.getTutorialSession(tutorial.id);
});
