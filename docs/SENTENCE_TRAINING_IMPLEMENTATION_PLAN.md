# センテンストレーニング 実装計画

MVP 実装の段階とタスクを定義します。

---

## 1. MVP スコープ

- **モード**: Listen-Repeat のみ
- **データ**: 既存 `sentences` を `category_tag = #SentenceTraining` でフィルタし、Pack は `group` でグルーピング
- **画面**: 会話トレーニング選択に「センテンストレーニング」追加 → パック一覧 → チャンク単位の練習画面
- **進捗**: 再生回数・完了チャンク数をローカル（SharedPreferences）または Supabase に記録

---

## 2. 実装フェーズ

### Phase 1: 導線と一覧（1〜2日）

1. **ルート追加**
   - `router.dart`: `/sentence-training` を追加
   - 遷移先: `SentenceTrainingListScreen`（新規）

2. **会話トレーニング選択にカード追加**
   - `ConversationTrainingChoiceScreen`: 3つ目のカード「センテンストレーニング」を追加
   - `onTap`: `context.push('/sentence-training')`

3. **パック一覧画面**
   - `SentenceTrainingListScreen`: `sentences` を `category_tag` でフィルタし、`group` でグルーピング
   - 各グループを「Pack」としてカード表示
   - タップで `SentenceTrainingStudyScreen` へ（packId=group 名を渡す）

### Phase 2: 練習画面（2〜3日）

1. **SentenceTrainingStudyScreen**
   - `group` に属する sentences を順番に表示
   - 1チャンクあたり: 英語表示、TTS 再生、録音ボタン、次/前
   - 既存 `AudioControls` を組み込み（sentenceId を渡す）
   - 最後のチャンク完了時に「お疲れ様」表示、パック一覧へ戻る

2. **進捗記録**
   - 完了チャンク数を `SharedPreferences` または `user_progress` 相当に保存
   - パック単位の完了率を一覧で表示（任意）

### Phase 3: データ整備（1日）

1. **トレーニング用 sentences の登録**
   - Supabase `sentences` に `category_tag = #SentenceTraining`、`group` に Pack 名を設定した例文を投入
   - 初回は 1 Pack（例: 20 チャンク）分のみ用意

2. **Provider 拡張**
   - `sentenceTrainingPacksProvider`: `sentences` を `category_tag = #SentenceTraining` でフィルタし、`group` でグループ化
   - `sentenceTrainingPackSentencesProvider(packId)`: 指定 Pack の sentences を返す

### Phase 4: 拡張（将来）

- Shadowing モード（遅延再生）
- Pattern Substitution（語句差し替えUI）
- Cued Recall（日本語ヒント表示）
- `training_packs` / `training_chunks` 専用テーブルへの移行

---

## 3. ファイル構成

| ファイル | 役割 |
|----------|------|
| `lib/screens/sentence_training_list_screen.dart` | Pack 一覧 |
| `lib/screens/sentence_training_study_screen.dart` | チャンク単位の練習 |
| `lib/providers/sentence_training_provider.dart` | Pack 取得・進捗 |
| `lib/utils/router.dart` | `/sentence-training` 追加 |
| `lib/screens/conversation_training_choice_screen.dart` | カード追加 |

---

## 4. 依存関係

- `TtsService`: 既存
- `AudioControls` / 録音: 既存
- `sentences` / `SupabaseService`: 既存
- `EnvConfig`, `SupabaseConfig`: 既存

---

## 5. 受け入れ基準（MVP）

- [ ] 会話トレーニング選択から「センテンストレーニング」を選べる
- [ ] パック一覧が表示される（1 Pack 以上）
- [ ] パックを選ぶと、チャンクが順番に表示される
- [ ] 各チャンクで TTS 再生と録音ができる
- [ ] 次/前でチャンク間を移動できる
- [ ] 最後のチャンク完了後、一覧へ戻れる
