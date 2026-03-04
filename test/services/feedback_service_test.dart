import 'package:engrowth_app/services/feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackService', () {
    test('instantiates with null analytics without throwing', () {
      expect(() => FeedbackService(null), returnsNormally);
    });

    test('selection() does not throw when analytics is null', () {
      final service = FeedbackService(null);
      expect(() => service.selection(), returnsNormally);
      expect(() => service.selection(trigger: 'test_trigger'), returnsNormally);
    });

    test('light() does not throw when analytics is null', () {
      final service = FeedbackService(null);
      expect(() => service.light(), returnsNormally);
    });

    test('medium() does not throw when analytics is null', () {
      final service = FeedbackService(null);
      expect(() => service.medium(), returnsNormally);
    });

    test('error() does not throw when analytics is null', () {
      final service = FeedbackService(null);
      expect(() => service.error(), returnsNormally);
    });

    test('rapid same-trigger calls do not throw', () {
      final service = FeedbackService(null);
      expect(() {
        service.selection(trigger: 'rapid_test');
        service.selection(trigger: 'rapid_test');
        service.selection(trigger: 'rapid_test');
      }, returnsNormally);
    });
  });
}
