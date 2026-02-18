# ゲーミフィケーション（バッジ/称号/演出）導入手順

## 目的
達成感と継続意欲を高め、学習の「楽しい」体験を強化する。

## 対象機能
- バッジ/称号
- 小さな達成演出（学習完了時）
- ポイント/レベル（段階導入）

## UI/UX要件（スマホ前提）
- 進捗画面に「称号/バッジ」セクション
- 学習完了時に小さな演出（1〜2秒）
- 演出は邪魔にならず、すぐ次へ行ける

## 技術要件
### 1) データモデル追加
`achievements`
- `id` (uuid)
- `title` (text)
- `description` (text)
- `icon` (text)
- `condition_type` (text)
- `condition_value` (int)

`user_achievements`
- `user_id` (uuid)
- `achievement_id` (uuid)
- `unlocked_at` (timestamptz)

### 2) 解除条件（初期案）
- ストリーク7日
- 例文50件達成
- シナリオ3本完了
- ヒントなし正解10回

## 実装手順
1. **DB追加**
   - `achievements`, `user_achievements`
2. **モデル追加**
   - `Achievement`, `UserAchievement`
3. **解除判定ロジック**
   - 学習完了時に条件チェック
4. **UI表示**
   - 進捗画面で一覧表示
5. **演出**
   - 解除時に軽いアニメーション/バイブ

## 受け入れ条件
- 条件達成時にバッジが解除される
- 解除演出が表示され、学習を妨げない
- 進捗画面でバッジ一覧が確認できる

