import 'package:flutter/material.dart';

import 'sentence.dart';

/// 学習フロー内の1ステップを表す共通インターフェース。
/// 各ステップは次ステップへ進む際に Bridge ポップアップ用のタイトル等を持てる。
sealed class LearningStep {
  const LearningStep({
    this.bridgeTitle,
    this.bridgeSubtitle,
  });

  final String? bridgeTitle;
  final String? bridgeSubtitle;
}

/// 音声リスニングステップ。TTS 再生完了で自動完了する想定。
class ListeningStep extends LearningStep {
  const ListeningStep({
    required this.storyId,
    String? bridgeTitle,
    String? bridgeSubtitle,
  }) : super(
          bridgeTitle: bridgeTitle,
          bridgeSubtitle: bridgeSubtitle,
        );

  final String storyId;
}

/// スピーキング演習ステップ。録音成功などで完了。
class SpeakingStep extends LearningStep {
  const SpeakingStep({
    required this.storyId,
    required this.mode,
    String? bridgeTitle,
    String? bridgeSubtitle,
  }) : super(
          bridgeTitle: bridgeTitle,
          bridgeSubtitle: bridgeSubtitle,
        );

  final String storyId;
  final String mode; // 'roleA' / 'roleB' / 'both' など
}

/// 解説・インプット用ステップ。一定時間表示後に自動完了させる用途。
class ExplanationStep extends LearningStep {
  const ExplanationStep({
    required this.widgetBuilder,
    required this.showDuration,
    String? bridgeTitle,
    String? bridgeSubtitle,
  }) : super(
          bridgeTitle: bridgeTitle,
          bridgeSubtitle: bridgeSubtitle,
        );

  /// 解説 UI を構築するためのビルダー
  final WidgetBuilder widgetBuilder;

  /// このステップを表示しておく時間（自動完了用）
  final Duration showDuration;
}

/// 節目・ミッション達成ステップ。ボタンタップで完了させる。
class MilestoneStep extends LearningStep {
  const MilestoneStep({
    required this.title,
    this.subtitle,
    String? bridgeTitle,
    String? bridgeSubtitle,
  }) : super(
          bridgeTitle: bridgeTitle,
          bridgeSubtitle: bridgeSubtitle,
        );

  final String title;
  final String? subtitle;
}

/// センテンスベースのパターンスプリント用ステップ。
class PatternListeningStep extends LearningStep {
  const PatternListeningStep({
    required this.sentence,
    String? bridgeTitle,
    String? bridgeSubtitle,
  }) : super(
          bridgeTitle: bridgeTitle,
          bridgeSubtitle: bridgeSubtitle,
        );

  final Sentence sentence;
}


