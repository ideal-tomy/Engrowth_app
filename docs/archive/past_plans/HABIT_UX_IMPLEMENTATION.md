# 習慣化UX（ストリーク/今日のミッション/通知）導入手順

## 目的
学習継続率を最大化するための「習慣化UX」を導入する。  
Engrowthの学習導線を「迷わず、毎日、短時間でも進められる」体験にする。

## 対象機能
- ストリーク（連続学習日数）
- 今日のミッション（1タップ開始）
- 学習リマインド通知（任意ON/OFF）

## UI/UX要件（スマホ前提）
- 進捗画面トップにストリークを大きく表示
- 学習タブの最上部に「今日のミッション」カードを固定
- ミッション達成時の小さな演出（チェック + 軽い振動）
- 学習開始CTAは親指で押しやすい位置（画面下寄り）

## 技術要件
### 1) データモデル追加
`user_stats`（新規）を作成、または`user_progress`拡張で保持
- `user_id` (uuid)
- `streak_count` (int)
- `last_study_date` (date)  // ユーザーのローカル日付で保持
- `daily_goal_count` (int)  // 例文数 or 学習分数
- `daily_done_count` (int)
- `timezone` (text)
- `updated_at` (timestamptz)

### 2) ストリーク算出ルール
- `last_study_date == 今日` → ストリーク維持
- `last_study_date == 昨日` → +1
- それ以外 → 1にリセット

### 3) ミッション設計
初期案:
- 例文学習: 3件
- 画像想起: 3件
- 音読: 1件（音声機能導入後に解禁）

## 実装手順
1. **DB追加**
   - `user_stats`テーブル追加
   - `last_study_date`, `streak_count`, `daily_goal_count`, `daily_done_count` を保持
2. **モデル追加**
   - `UserStats`モデルを追加
   - `copyWith`, `fromJson`, `toJson`
3. **プロバイダ追加（Riverpod）**
   - `userStatsProvider`（FutureProvider）
   - `userStatsNotifier`（更新用）
4. **ミッション更新ロジック**
   - 学習完了時に`daily_done_count`更新
   - 目標達成時にUIに「達成」演出
5. **ストリーク更新**
   - 学習完了時に`last_study_date`を更新
   - 日付跨ぎ時の判定を実行（アプリ起動時/学習開始時）
6. **通知設定**
   - `flutter_local_notifications`導入
   - 設定画面でON/OFF + 時刻指定
   - 通知文言は短く/ポジティブに

## 画面設計（簡易ワイヤー）
```
┌──────────────┐
│ 今日のミッション │  ← 最上部に固定
│ 3/3 完了      │
│ [今すぐ学習]   │
├──────────────┤
│ ストリーク 7日 │
│ 🔥🔥🔥         │
└──────────────┘
```

## 受け入れ条件
- 連続学習日数が正しく更新される
- 1タップで「今日のミッション」開始ができる
- 通知のON/OFFが設定画面で切り替えられる

