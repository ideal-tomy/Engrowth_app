import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_step.dart';
import '../widgets/common/engrowth_popup.dart';

/// 学習フロー内で発生するイベント
sealed class LearningFlowEvent {
  const LearningFlowEvent();
}

/// Bridge ポップアップを表示するイベント
class LearningFlowShowBridge extends LearningFlowEvent {
  const LearningFlowShowBridge({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
}

/// フロー全体が完了したことを通知するイベント
class LearningFlowCompleted extends LearningFlowEvent {
  const LearningFlowCompleted();
}

/// 学習ステップの進行を管理するコントローラ。
class LearningFlowController extends StateNotifier<int> {
  LearningFlowController(this._steps) : super(0);

  final List<LearningStep> _steps;
  final _eventController = StreamController<LearningFlowEvent>.broadcast();

  Stream<LearningFlowEvent> get events => _eventController.stream;

  LearningStep get currentStep => _steps[state];

  bool get isLastStep => state >= _steps.length - 1;

  /// 現在のステップが完了したときに呼ぶ。
  /// Bridge タイトルがあれば Bridge ポップアップを表示するイベントを流し、
  /// なければ即座に次のステップへ進める。
  void onStepCompleted() {
    if (isLastStep) {
      _eventController.add(const LearningFlowCompleted());
      return;
    }

    final next = _steps[state + 1];
    if (next.bridgeTitle != null) {
      _eventController.add(
        LearningFlowShowBridge(
          title: next.bridgeTitle!,
          subtitle: next.bridgeSubtitle,
        ),
      );
    } else {
      goToNextStep();
    }
  }

  /// Bridge 演出が終わったあとに呼ばれ、実際に次ステップへ進める。
  void goToNextStep() {
    if (isLastStep) {
      _eventController.add(const LearningFlowCompleted());
      return;
    }
    state = state + 1;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}

/// Widget から簡便に Bridge を扱うためのヘルパ。
Future<void> showBridgePopupIfNeeded(
  BuildContext context,
  LearningFlowController controller,
  LearningFlowShowBridge event,
) async {
  await EngrowthPopup.show<void>(
    context,
    variant: EngrowthPopupVariant.bridge,
    title: event.title,
    subtitle: event.subtitle,
  );
  controller.goToNextStep();
}

