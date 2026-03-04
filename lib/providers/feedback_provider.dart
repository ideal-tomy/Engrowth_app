import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/analytics_service.dart';
import '../services/feedback_service.dart';
import 'analytics_provider.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  return FeedbackService(analytics);
});
