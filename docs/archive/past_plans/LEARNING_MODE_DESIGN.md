# 学習モード UI/UX設計

## 概要

脳科学的に最適化された学習モードの設計です。「インテリジェント・ヒント・フェード」機能を中心に、効果的な記憶定着を実現します。

## 脳科学的根拠

### 1. 望ましい困難（Desirable Difficulty）
- **2秒の沈黙**: 脳が神経回路を検索する時間
- **想起練習（Retrieval Practice）**: 思い出す努力が記憶を強化
- **適度な負荷**: フロー状態の維持

### 2. 足場かけ（Scaffolding）
- **段階的ヒント**: 最小限の助けで解決に導く
- **自己効力感**: 自分で思い出したという感覚
- **ストレス軽減**: フリーズ状態の回避

### 3. アハ体験とドーパミン
- **報酬システム**: 思い出した瞬間の快感
- **継続意欲**: 次もやりたいという動機付け

## デザイン要件

### 1. 学習モード画面レイアウト

```
┌─────────────────────────────────────┐
│  AppBar                             │
│  - 進捗表示 (3/25)                  │
│  - 設定アイコン                      │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐  │
│  │                             │  │
│  │   画像 (16:9, フルスクリーン)│  │
│  │                             │  │
│  │  [カテゴリタグ] [難易度]    │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  シーン設定                   │  │
│  │  "夕方のオフィス..."          │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  英語例文エリア               │  │
│  │                             │  │
│  │  [ヒントエリア]              │  │
│  │  (フェードイン表示)          │  │
│  │                             │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  日本語例文 (非表示/表示切替)│  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  [答えを見る] [覚えた] [次へ]│  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 2. ヒントシステム

#### 段階的フェードイン

**Phase 1: 初期ヒント（3秒後）**
- **表示**: 先頭1文字または1単語目
- **透明度**: 0.3（薄く）
- **アニメーション**: フェードイン（300ms）
- **効果**: 最小限のトリガー

**Phase 2: 拡張ヒント（6秒後）**
- **表示**: 先頭3単語
- **透明度**: 0.6（中程度）
- **アニメーション**: フェードイン（300ms）
- **効果**: より具体的な手がかり

**Phase 3: 重要単語ハイライト（10秒後）**
- **表示**: キーワードとなる重要単語をハイライト
- **透明度**: 0.8（はっきり）
- **アニメーション**: フェードイン + パルス
- **効果**: 核心的な情報

#### ヒント表示ロジック

```dart
enum HintPhase {
  none,        // ヒントなし
  initial,     // 初期ヒント（3秒）
  extended,    // 拡張ヒント（6秒）
  keywords,    // 重要単語（10秒）
}
```

### 3. インタラクション設計

#### タイマー管理
- **開始**: 例文表示と同時にタイマー起動
- **リセット**: ユーザーがアクションを取ったらリセット
- **一時停止**: 答えを見るボタンを押したら停止

#### ユーザーアクション
- **答えを見る**: ヒントを非表示、完全な例文を表示
- **覚えた**: ヒント使用フラグを記録、次へ進む
- **次へ**: 次の例文へ（ヒント使用ログを保存）

### 4. 視覚的フィードバック

#### ヒント表示時の視覚効果
- **画面の微かな光**: `AnimatedContainer`で背景色を一時的に変化
- **ヒント文字のアニメーション**: フェードイン + スライドイン
- **パルス効果**: 重要単語にパルスアニメーション

#### 触覚的フィードバック（Haptic Feedback）
- **ヒント表示時**: 軽いバイブレーション（`HapticFeedback.lightImpact()`）
- **思い出した時**: 成功バイブレーション（`HapticFeedback.mediumImpact()`）
- **覚えた時**: 強いバイブレーション（`HapticFeedback.heavyImpact()`）

### 5. ヒントカスタマイズ設定

#### 設定項目
- **ヒント表示までの時間**: 2秒 / 5秒 / 10秒 / カスタム
- **ヒントの段階**: 3段階 / 5段階 / カスタム
- **ヒントの透明度**: 薄い / 標準 / 濃い
- **バイブレーション**: ON / OFF

#### 設定画面
```
┌─────────────────────────────────────┐
│  学習設定                            │
├─────────────────────────────────────┤
│  ヒント表示までの時間                │
│  ○ 2秒  ○ 5秒  ● 10秒  ○ カスタム │
│                                     │
│  ヒントの段階                        │
│  ● 3段階  ○ 5段階  ○ カスタム     │
│                                     │
│  ヒントの透明度                      │
│  ○ 薄い  ● 標準  ○ 濃い           │
│                                     │
│  バイブレーション                    │
│  [ON]                               │
└─────────────────────────────────────┘
```

## 技術要件

### 1. データモデル拡張

```dart
class UserProgress {
  final String id;
  final String userId;
  final String sentenceId;
  final bool isMastered;
  final DateTime? lastStudiedAt;
  final int studyCount;
  final Duration totalStudyTime;
  final double masteryLevel;
  
  // ヒント関連の新規フィールド
  final int hintUsageCount;        // ヒント使用回数
  final List<HintPhase> usedHints;  // 使用したヒントの段階
  final bool usedHintToMaster;      // ヒントを使って覚えたか
  final DateTime createdAt;
}

class LearningSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SessionItem> items;  // 学習した例文とヒント使用状況
}

class SessionItem {
  final String sentenceId;
  final Duration thinkingTime;     // 考えていた時間
  final HintPhase? usedHintPhase;  // 使用したヒントの段階
  final bool mastered;
  final DateTime timestamp;
}
```

### 2. 状態管理

```dart
// 学習セッション状態
final learningSessionProvider = StateNotifierProvider<LearningSessionNotifier, LearningSession?>((ref) {
  return LearningSessionNotifier();
});

// ヒント状態
final hintPhaseProvider = StateProvider<HintPhase>((ref) => HintPhase.none);

// タイマー状態
final thinkingTimerProvider = StateProvider<Duration>((ref) => Duration.zero);

// ヒント設定
final hintSettingsProvider = StateProvider<HintSettings>((ref) {
  return HintSettings(
    delaySeconds: 2,
    phases: [3, 6, 10],
    opacity: 0.6,
    hapticEnabled: true,
  );
});
```

### 3. タイマー実装

```dart
class ThinkingTimer {
  Timer? _timer;
  final VoidCallback onHintPhaseChange;
  final List<int> hintPhases; // [3, 6, 10] (秒)
  int _currentPhaseIndex = 0;
  
  void start() {
    _currentPhaseIndex = 0;
    _scheduleNextHint();
  }
  
  void _scheduleNextHint() {
    if (_currentPhaseIndex >= hintPhases.length) return;
    
    final delay = _currentPhaseIndex == 0
        ? hintPhases[0]
        : hintPhases[_currentPhaseIndex] - hintPhases[_currentPhaseIndex - 1];
    
    _timer = Timer(Duration(seconds: delay), () {
      onHintPhaseChange();
      _currentPhaseIndex++;
      _scheduleNextHint();
    });
  }
  
  void reset() {
    _timer?.cancel();
    _currentPhaseIndex = 0;
  }
  
  void stop() {
    _timer?.cancel();
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
```

### 4. ヒント表示ウィジェット

```dart
class HintDisplay extends StatelessWidget {
  final String fullText;
  final HintPhase phase;
  final double opacity;
  
  @override
  Widget build(BuildContext context) {
    String hintText = _getHintText(fullText, phase);
    
    return AnimatedOpacity(
      opacity: opacity,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: AnimatedSlide(
        offset: Offset(0, phase == HintPhase.none ? -10 : 0),
        duration: Duration(milliseconds: 300),
        child: Text(
          hintText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.blue.withOpacity(opacity),
          ),
        ),
      ),
    );
  }
  
  String _getHintText(String fullText, HintPhase phase) {
    final words = fullText.split(' ');
    switch (phase) {
      case HintPhase.initial:
        return words.isNotEmpty ? '${words[0][0]}...' : '';
      case HintPhase.extended:
        return words.take(3).join(' ') + '...';
      case HintPhase.keywords:
        return _highlightKeywords(fullText);
      default:
        return '';
    }
  }
  
  String _highlightKeywords(String text) {
    // 重要単語を抽出してハイライト
    // 実装は重要単語リストに基づく
    return text;
  }
}
```

### 5. アニメーション

```dart
// ヒント表示時の画面光る効果
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  color: hintPhase != HintPhase.none
      ? Colors.blue.withOpacity(0.05)
      : Colors.transparent,
  child: // コンテンツ
)

// パルスアニメーション（重要単語）
AnimatedBuilder(
  animation: _pulseAnimation,
  builder: (context, child) {
    return Opacity(
      opacity: 0.6 + (_pulseAnimation.value * 0.4),
      child: child,
    );
  },
  child: Text(importantWord),
)
```

### 6. バイブレーション

```dart
import 'package:flutter/services.dart';

void showHintWithFeedback(HintPhase phase) {
  // 視覚的フィードバック
  // 画面の微かな光
  
  // 触覚的フィードバック
  switch (phase) {
    case HintPhase.initial:
      HapticFeedback.lightImpact();
      break;
    case HintPhase.extended:
      HapticFeedback.selectionClick();
      break;
    case HintPhase.keywords:
      HapticFeedback.mediumImpact();
      break;
    default:
      break;
  }
}
```

### 7. ログ記録

```dart
class LearningService {
  // ヒント使用ログの記録
  Future<void> logHintUsage({
    required String sentenceId,
    required HintPhase hintPhase,
    required Duration thinkingTime,
  }) async {
    await SupabaseConfig.client
        .from('learning_logs')
        .insert({
          'user_id': userId,
          'sentence_id': sentenceId,
          'hint_phase': hintPhase.toString(),
          'thinking_time_seconds': thinkingTime.inSeconds,
          'timestamp': DateTime.now().toIso8601String(),
        });
  }
  
  // ヒント使用統計の取得
  Future<Map<HintPhase, int>> getHintUsageStats(String userId) async {
    // ヒント使用回数を集計
  }
}
```

### 8. パーソナライズド学習

```dart
// ヒント使用履歴に基づく復習優先度
class PersonalizedLearning {
  // ヒントを使った単語を優先的に復習
  Future<List<Sentence>> getReviewList(String userId) async {
    final hintUsageStats = await getHintUsageStats(userId);
    
    // ヒント使用回数が多い例文を優先
    return sentences
        .where((s) => hintUsageStats[s.id] != null)
        .sorted((a, b) => 
            (hintUsageStats[b.id] ?? 0).compareTo(hintUsageStats[a.id] ?? 0))
        .toList();
  }
}
```

## パフォーマンス最適化

### 1. タイマーの最適化
- `Timer`の適切なキャンセル
- メモリリークの防止
- バックグラウンド時の一時停止

### 2. アニメーションの最適化
- `AnimatedOpacity`の使用
- 60fpsの維持
- 不要な再描画の回避

### 3. データベース最適化
- バッチインサート
- インデックスの追加
- クエリの最適化

## アクセシビリティ

### 1. 視覚的アクセシビリティ
- ヒントのコントラスト比確保
- フォントサイズの調整可能
- カラーブラインド対応

### 2. 聴覚的アクセシビリティ
- バイブレーションの代替（音声フィードバック）
- スクリーンリーダー対応

### 3. 操作のアクセシビリティ
- 大きなタップターゲット
- キーボードナビゲーション
- ジェスチャーの代替手段

## 実装優先順位

### Phase 1: 基本機能
1. タイマーシステムの実装
2. 段階的ヒント表示（3段階）
3. ヒント使用ログの記録

### Phase 2: UX改善
4. 視覚的フィードバック（画面の光）
5. 触覚的フィードバック（バイブレーション）
6. アニメーションの最適化

### Phase 3: カスタマイズ
7. ヒント設定画面
8. カスタマイズ可能なタイミング
9. ヒントの透明度調整

### Phase 4: パーソナライズ
10. ヒント使用統計の表示
11. パーソナライズド復習リスト
12. 学習効果の可視化
