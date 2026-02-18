# 進捗管理 UI/UX設計

## 概要

学習進捗を視覚的に分かりやすく、モチベーションを高めるUI/UX設計です。

## デザイン要件

### 1. ダッシュボードレイアウト

```
┌─────────────────────────────────────┐
│  AppBar                             │
│  - タイトル: 学習進捗               │
│  - 期間選択（今日/今週/今月/全体）  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐  │
│  │  全体進捗サマリー            │  │
│  │  ┌─────┐ ┌─────┐ ┌─────┐  │  │
│  │  │覚えた│ │学習中│ │未学習│  │  │
│  │  │ 45  │ │ 12  │ │ 178 │  │  │
│  │  └─────┘ └─────┘ └─────┘  │  │
│  │                             │  │
│  │  [進捗バー: 45/235 (19%)]   │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  学習統計                    │  │
│  │  - 連続学習日数: 7日         │  │
│  │  - 今週の学習時間: 2.5時間   │  │
│  │  - 総学習時間: 15.3時間     │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  達成度グラフ                │  │
│  │  [週間/月間の学習推移]       │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  カテゴリ別進捗              │  │
│  │  [#Business] 80% ████████  │  │
│  │  [#Friends] 60% ██████     │  │
│  │  [#Life] 40% ████          │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  最近の学習履歴              │  │
│  │  [学習した例文のリスト]       │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 2. 進捗サマリーカード

#### デザイン
- **レイアウト**: 3列グリッド
- **カード**: 
  - 覚えた: 緑色テーマ
  - 学習中: オレンジ色テーマ
  - 未学習: グレーテーマ

#### 数値表示
- **大きな数字**: 見出しサイズ（32px）
- **ラベル**: 小さく（14px）
- **アイコン**: 各カードに適切なアイコン

### 3. 進捗バー

#### デザイン
- **タイプ**: 線形プログレスバー
- **高さ**: 24px
- **角丸**: 12px
- **アニメーション**: 数値変化時にアニメーション

#### 表示情報
- 進捗率（%）
- 覚えた数 / 総数
- 残り数

### 4. 学習統計

#### 表示項目
- **連続学習日数**: ストリーク表示
- **今週の学習時間**: 時間表示
- **総学習時間**: 時間表示
- **平均学習時間**: 1日あたり

#### ビジュアル
- アイコン付きカード
- 数値の強調表示
- 前日/前週との比較

### 5. 達成度グラフ

#### グラフタイプ
- **週間**: 折れ線グラフ（7日間）
- **月間**: 棒グラフ（30日間）
- **年間**: カレンダービュー（オプション）

#### データ表示
- 学習した例文数
- 学習時間
- 達成率

### 6. カテゴリ別進捗

#### レイアウト
- カテゴリごとの進捗バー
- 進捗率表示
- 覚えた数 / 総数

#### インタラクション
- カテゴリタップで詳細表示
- フィルタリング

### 7. 学習履歴

#### リスト表示
- 日付ごとにグループ化
- 学習した例文のサムネイル
- 学習時間
- 達成状況
- ヒント使用状況（バッジ表示）

#### 詳細表示
- 例文カード
- 学習回数
- 最後の学習日時
- 習熟度
- ヒント使用統計
  - ヒント使用回数
  - 使用したヒントの段階
  - 平均思考時間

### 8. ヒント使用統計

#### 表示項目
- ヒント使用率（%）
- 段階別ヒント使用回数
- ヒントを使って覚えた例文数
- 平均思考時間

#### ビジュアル
- 円グラフ（段階別ヒント使用）
- 棒グラフ（ヒント使用率の推移）
- カテゴリ別ヒント使用統計

## 技術要件

### 1. データモデル拡張

```dart
class UserProgress {
  final String id;
  final String userId;
  final String sentenceId;
  final bool isMastered;
  final DateTime? lastStudiedAt;
  final int studyCount; // 学習回数
  final Duration totalStudyTime; // 総学習時間
  final double masteryLevel; // 習熟度 (0.0-1.0)
  
  // ヒント関連の新規フィールド
  final int hintUsageCount;        // ヒント使用回数
  final List<HintPhase> usedHints;  // 使用したヒントの段階
  final bool usedHintToMaster;      // ヒントを使って覚えたか
  final Duration averageThinkingTime; // 平均思考時間
  
  final DateTime createdAt;
}

enum HintPhase {
  none,        // ヒントなし
  initial,     // 初期ヒント（3秒）
  extended,    // 拡張ヒント（6秒）
  keywords,    // 重要単語（10秒）
}
```

class LearningStats {
  final int totalSentences;
  final int masteredSentences;
  final int studyingSentences;
  final int unstudiedSentences;
  final int consecutiveDays; // 連続学習日数（user_statsテーブルから取得）
  final Duration totalStudyTime;
  final Duration weeklyStudyTime;
  final Map<String, int> categoryProgress; // カテゴリ別進捗
}
```

### 2. 状態管理

```dart
// 進捗データ
final userProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  return await SupabaseService.getUserProgress(userId);
});

// 学習統計
final learningStatsProvider = FutureProvider<LearningStats>((ref) async {
  final progress = await ref.watch(userProgressProvider.future);
  return calculateStats(progress);
});

// 期間フィルタ
final timeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.all);
```

### 3. グラフライブラリ

```yaml
# pubspec.yamlに追加
dependencies:
  fl_chart: ^0.65.0
```

### 4. アニメーション

```dart
// 進捗バーのアニメーション
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.easeOut,
  width: progressWidth,
)

// 数値のカウントアップアニメーション
TweenAnimationBuilder<int>(
  tween: IntTween(begin: 0, end: masteredCount),
  duration: Duration(milliseconds: 1000),
  builder: (context, value, child) {
    return Text('$value');
  },
)
```

## モチベーション要素

### 1. 達成バッジ

- 10例文覚えた
- 50例文覚えた
- 100例文覚えた
- 7日連続学習
- 30日連続学習

### 2. ストリーク表示

- 連続学習日数を視覚化
- カレンダービュー
- 達成時の祝福アニメーション

### 3. 目標設定

- 週間目標（例: 10例文）
- 月間目標（例: 50例文）
- 進捗表示

### 4. ランキング（将来）

- 週間ランキング
- 月間ランキング
- カテゴリ別ランキング

## 実装優先順位

### Phase 1: 基本機能
1. 進捗サマリーカード
2. 進捗バー
3. 学習統計表示

### Phase 2: 可視化
4. 達成度グラフ
5. カテゴリ別進捗
6. 学習履歴リスト

### Phase 3: モチベーション
7. 達成バッジ
8. ストリーク表示
9. 目標設定機能

### Phase 4: 高度な機能
10. 詳細分析
11. 学習レコメンデーション
12. ランキング機能
