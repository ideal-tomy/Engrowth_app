import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_practice_provider.dart';
import '../../providers/last_study_resume_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/user_stats_provider.dart';

/// Marqueeレールの1タブ
class MarqueeRailItem {
  final String label;
  final String? route;
  final String? analyticsSource;

  const MarqueeRailItem({
    required this.label,
    this.route,
    this.analyticsSource,
  });
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
    MarqueeRailItem(label: '30秒会話を試す', route: '/scenario-learning'),
    MarqueeRailItem(label: '3分会話を体験', route: '/story-training'),
    MarqueeRailItem(label: '人気センテンスを見る', route: '/sentences'),
    MarqueeRailItem(label: 'すぐ使える英語5選', route: '/sentences'),
    MarqueeRailItem(label: '旅行英語から始める', route: '/conversations'),
    MarqueeRailItem(label: '仕事英語を練習する', route: '/conversations'),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint'),
    MarqueeRailItem(label: '学習の進み方を見る', route: '/progress'),
    MarqueeRailItem(label: '単語を検索', route: '/words'),
    MarqueeRailItem(label: '無料で成長を保存', route: '/account'),
  ];

  static const newUser = [
    MarqueeRailItem(label: '今日の目標を開始', route: '/conversations'),
    MarqueeRailItem(label: '30秒会話を始める', route: '/scenario-learning'),
    MarqueeRailItem(label: '3分会話を始める', route: '/story-training'),
    MarqueeRailItem(label: '前回の続きから再開', route: '/study'),
    MarqueeRailItem(label: '本日の復習', route: '/review'),
    MarqueeRailItem(label: '単語を3つだけ覚える', route: '/words'),
    MarqueeRailItem(label: '人気フレーズを保存', route: '/sentences'),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint'),
    MarqueeRailItem(label: '学習進捗を確認', route: '/progress'),
    MarqueeRailItem(label: 'お気に入りで学習', route: '/favorites'),
  ];

  static const returning = [
    MarqueeRailItem(label: '前回の続きから再開', route: '/study'),
    MarqueeRailItem(label: '本日の復習', route: '/review'),
    MarqueeRailItem(label: '30秒会話（時短）', route: '/scenario-learning'),
    MarqueeRailItem(label: '3分会話（集中）', route: '/story-training'),
    MarqueeRailItem(label: 'お気に入りで復習', route: '/favorites'),
    MarqueeRailItem(label: 'パターンスプリント', route: '/pattern-sprint'),
    MarqueeRailItem(label: 'センテンス一覧', route: '/sentences'),
    MarqueeRailItem(label: '学習進捗を見る', route: '/progress'),
    MarqueeRailItem(label: '単語検索', route: '/words'),
    MarqueeRailItem(label: '会話トレーニング', route: '/conversation-training'),
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
      ));
    }

    final reviewCount = ref.watch(reviewCountProvider);
    if (reviewCount > 0) {
      items.add(MarqueeRailItem(
        label: '本日の復習（$reviewCount件）',
        route: '/review',
        analyticsSource: 'marquee_review',
      ));
    }
  }

  return items;
}

/// タップ時の抑制・計測用
final marqueeRailTapProvider =
    StateNotifierProvider<MarqueeRailTapNotifier, void>((ref) {
  return MarqueeRailTapNotifier(ref);
});

class MarqueeRailTapNotifier extends StateNotifier<void> {
  MarqueeRailTapNotifier(this._ref) : super(null);

  final Ref _ref;

  void onTap(MarqueeRailItem item) {
    _ref.read(_marqueeTapSuppressionProvider.notifier).recordTap(item);
    _ref.read(analyticsServiceProvider).logEvent(
          eventType: 'marquee_tap',
          eventProperties: {
            if (item.analyticsSource != null) 'source': item.analyticsSource,
            'label': item.label,
          },
        );
  }
}