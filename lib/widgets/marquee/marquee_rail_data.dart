import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/home_primary_cta_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_practice_provider.dart';
import '../../providers/last_study_resume_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/user_stats_provider.dart';
import '../../theme/engrowth_theme.dart';

/// コンテンツカテゴリ（色分けで直感的に識別）
enum MarqueeCategory {
  conversation,
  sentence,
  pattern,
  progress,
  word,
  favorite,
  review,
  study,
  account,
  goal,
}

/// Marqueeレールの1タブ
class MarqueeRailItem {
  final String label;
  final String? route;
  final String? analyticsSource;
  final MarqueeCategory category;

  const MarqueeRailItem({
    required this.label,
    this.route,
    this.analyticsSource,
    this.category = MarqueeCategory.conversation,
  });
}

/// カテゴリ別のタブ背景色（タブのみ色分け、テキストは統一）
class MarqueeCategoryColors {
  static Color tabBackground(MarqueeCategory cat, bool isDark) {
    switch (cat) {
      case MarqueeCategory.conversation:
        return isDark
            ? const Color(0xFF4A2C2A)
            : const Color(0xFFFFEBEE);
      case MarqueeCategory.sentence:
        return isDark
            ? const Color(0xFF3D3520)
            : const Color(0xFFFFF8E1);
      case MarqueeCategory.pattern:
        return isDark
            ? const Color(0xFF1E3A3A)
            : const Color(0xFFE0F2F1);
      case MarqueeCategory.progress:
        return isDark
            ? const Color(0xFF1E2A3A)
            : const Color(0xFFE3F2FD);
      case MarqueeCategory.word:
        return isDark
            ? const Color(0xFF2E2A3A)
            : const Color(0xFFF3E5F5);
      case MarqueeCategory.favorite:
        return isDark
            ? const Color(0xFF3D2A3A)
            : const Color(0xFFFCE4EC);
      case MarqueeCategory.review:
        return isDark
            ? const Color(0xFF3D3520)
            : const Color(0xFFFFF3E0);
      case MarqueeCategory.study:
        return isDark
            ? const Color(0xFF1E3A2A)
            : const Color(0xFFE8F5E9);
      case MarqueeCategory.account:
      case MarqueeCategory.goal:
        return isDark
            ? EngrowthColors.primary.withOpacity(0.25)
            : EngrowthColors.primary.withOpacity(0.12);
    }
  }
}

/// 認証状態: 未ログイン / 登録直後(7日以内) / 継続
enum _MarqueeUserStage {
  guest,
  newUser,
  returning,
}

/// 状態別の固定文言セット（10個ずつ）
class _MarqueeCopySets {
  static const guest = [
    MarqueeRailItem(label: '30秒会話を試す', route: '/scenario-learning', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '3分会話を体験', route: '/story-training', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '人気センテンスを見る', route: '/sentences', category: MarqueeCategory.sentence),
    MarqueeRailItem(label: 'すぐ使える英語5選', route: '/sentences', category: MarqueeCategory.sentence),
    MarqueeRailItem(label: '旅行英語から始める', route: '/conversations', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '仕事英語を練習する', route: '/conversations', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint', category: MarqueeCategory.pattern),
    MarqueeRailItem(label: '学習の進み方を見る', route: '/progress', category: MarqueeCategory.progress),
    MarqueeRailItem(label: '単語を検索', route: '/words', category: MarqueeCategory.word),
    MarqueeRailItem(label: '無料で成長を保存', route: '/account', category: MarqueeCategory.account),
  ];

  static const newUser = [
    MarqueeRailItem(label: '今日の目標を開始', route: '/conversations', category: MarqueeCategory.goal),
    MarqueeRailItem(label: '30秒会話を始める', route: '/scenario-learning', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '3分会話を始める', route: '/story-training', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '前回の続きから再開', route: '/study', category: MarqueeCategory.study),
    MarqueeRailItem(label: '本日の復習', route: '/review', category: MarqueeCategory.review),
    MarqueeRailItem(label: '単語を3つだけ覚える', route: '/words', category: MarqueeCategory.word),
    MarqueeRailItem(label: '人気フレーズを保存', route: '/sentences', category: MarqueeCategory.sentence),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint', category: MarqueeCategory.pattern),
    MarqueeRailItem(label: '学習進捗を確認', route: '/progress', category: MarqueeCategory.progress),
    MarqueeRailItem(label: 'お気に入りで学習', route: '/favorites', category: MarqueeCategory.favorite),
  ];

  static const returning = [
    MarqueeRailItem(label: '前回の続きから再開', route: '/study', category: MarqueeCategory.study),
    MarqueeRailItem(label: '本日の復習', route: '/review', category: MarqueeCategory.review),
    MarqueeRailItem(label: '30秒会話（時短）', route: '/scenario-learning', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: '3分会話（集中）', route: '/story-training', category: MarqueeCategory.conversation),
    MarqueeRailItem(label: 'お気に入りで復習', route: '/favorites', category: MarqueeCategory.favorite),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint', category: MarqueeCategory.pattern),
    MarqueeRailItem(label: 'センテンス一覧', route: '/sentences', category: MarqueeCategory.sentence),
    MarqueeRailItem(label: '学習進捗を見る', route: '/progress', category: MarqueeCategory.progress),
    MarqueeRailItem(label: '単語検索', route: '/words', category: MarqueeCategory.word),
    MarqueeRailItem(label: '会話トレーニング', route: '/conversation-training', category: MarqueeCategory.conversation),
  ];
}

/// タップ後60秒抑制用
final _marqueeTapSuppressionProvider =
    StateNotifierProvider<_MarqueeTapSuppressionNotifier, _SuppressionState>(
        (ref) => _MarqueeTapSuppressionNotifier());

class _SuppressionState {
  final String? suppressedKey;
  final DateTime? suppressedAt;

  const _SuppressionState({this.suppressedKey, this.suppressedAt});

  bool isSuppressed(String key) {
    if (suppressedKey != key || suppressedAt == null) return false;
    return DateTime.now().difference(suppressedAt!).inSeconds < 60;
  }
}

class _MarqueeTapSuppressionNotifier extends StateNotifier<_SuppressionState> {
  _MarqueeTapSuppressionNotifier() : super(const _SuppressionState());

  void recordTap(MarqueeRailItem item) {
    final key = '${item.label}|${item.route ?? ""}';
    state = _SuppressionState(suppressedKey: key, suppressedAt: DateTime.now());
  }
}

/// 表示するタブ一覧（2固定 + 3〜4動的、ローテーション）
/// タップ後60秒は同一タブを非表示
final marqueeRailItemsProvider = Provider<List<MarqueeRailItem>>((ref) {
  final stage = _resolveStage(ref);
  final base = _getBaseSet(stage);
  final dynamicItems = _getDynamicItems(ref, stage);
  final suppression = ref.watch(_marqueeTapSuppressionProvider);

  final raw = [...dynamicItems.take(2), ...base.take(6)];
  final filtered = raw
      .where((i) => !suppression.isSuppressed('${i.label}|${i.route ?? ""}'))
      .toList();
  return filtered.isNotEmpty ? filtered : raw;
});

_MarqueeUserStage _resolveStage(Ref ref) {
  final authStage = ref.watch(authStageProvider);
  if (authStage == AuthStage.anonymous) return _MarqueeUserStage.guest;

  final statsAsync = ref.watch(userStatsProvider);
  final stats = statsAsync.valueOrNull;
  if (stats == null) return _MarqueeUserStage.returning;
  final daysSinceFirst = DateTime.now().difference(stats.createdAt).inDays;
  return daysSinceFirst < 7 ? _MarqueeUserStage.newUser : _MarqueeUserStage.returning;
}

List<MarqueeRailItem> _getBaseSet(_MarqueeUserStage stage) {
  switch (stage) {
    case _MarqueeUserStage.guest:
      return _MarqueeCopySets.guest;
    case _MarqueeUserStage.newUser:
      return _MarqueeCopySets.newUser;
    case _MarqueeUserStage.returning:
      return _MarqueeCopySets.returning;
  }
}

List<MarqueeRailItem> _getDynamicItems(Ref ref, _MarqueeUserStage stage) {
  final items = <MarqueeRailItem>[];

  if (stage != _MarqueeUserStage.guest) {
    final resume = ref.watch(lastStudyResumeProvider);
    if (resume.sentenceId != null) {
      items.add(MarqueeRailItem(
        label: '前回の続きから再開',
        route: '/study?sentenceId=${resume.sentenceId}',
        analyticsSource: 'marquee_resume',
        category: MarqueeCategory.study,
      ));
    }

    final turnsAsync = ref.watch(todayConversationTurnsProvider);
    final turns = turnsAsync.valueOrNull ?? 0;
    if (turns < dailyConversationGoalTurns) {
      final remaining = dailyConversationGoalTurns - turns;
      items.add(MarqueeRailItem(
        label: '今日の目標まであと$remainingターン',
        route: '/conversations',
        analyticsSource: 'marquee_goal',
        category: MarqueeCategory.goal,
      ));
    }

    final reviewCount = ref.watch(reviewCountProvider);
    if (reviewCount > 0) {
      items.add(MarqueeRailItem(
        label: '本日の復習（$reviewCount件）',
        route: '/review',
        analyticsSource: 'marquee_review',
        category: MarqueeCategory.review,
      ));
    }
  }

  return items;
}

/// B08: marquee_tap → learning_entry_started 接続用（60秒ウィンドウ）
class MarqueeTapContext {
  final String tapId;
  final String? targetRoute;
  final DateTime tappedAt;

  const MarqueeTapContext({
    required this.tapId,
    required this.targetRoute,
    required this.tappedAt,
  });

  bool isWithin60Seconds() =>
      DateTime.now().difference(tappedAt).inSeconds <= 60;
}

final lastMarqueeTapContextProvider =
    StateNotifierProvider<LastMarqueeTapContextNotifier, MarqueeTapContext?>(
        (ref) => LastMarqueeTapContextNotifier());

class LastMarqueeTapContextNotifier extends StateNotifier<MarqueeTapContext?> {
  LastMarqueeTapContextNotifier() : super(null);

  void record(String tapId, String? targetRoute) {
    state = MarqueeTapContext(
      tapId: tapId,
      targetRoute: targetRoute,
      tappedAt: DateTime.now(),
    );
  }

  MarqueeTapContext? consumeIfRecent() {
    final ctx = state;
    if (ctx == null || !ctx.isWithin60Seconds()) return null;
    state = null;
    return ctx;
  }
}

String _generateTapId() =>
    'mt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

/// タップ時の抑制・計測用
final marqueeRailTapProvider =
    StateNotifierProvider<MarqueeRailTapNotifier, void>((ref) {
  return MarqueeRailTapNotifier(ref);
});

class MarqueeRailTapNotifier extends StateNotifier<void> {
  MarqueeRailTapNotifier(this._ref) : super(null);

  final Ref _ref;

  void onTap(MarqueeRailItem item) {
    _ref.read(homePrimaryCtaProvider.notifier).maybeRecordRecognized('marquee');
    _ref.read(_marqueeTapSuppressionProvider.notifier).recordTap(item);
    final tapId = _generateTapId();
    final targetRoute = item.route;
    _ref.read(lastMarqueeTapContextProvider.notifier).record(tapId, targetRoute);
    _ref.read(analyticsServiceProvider).logEvent(
          eventType: 'marquee_tap',
          eventProperties: {
            'tap_id': tapId,
            'target_route': targetRoute ?? '',
            if (item.analyticsSource != null) 'source': item.analyticsSource,
            'label': item.label,
          },
        );
  }
}