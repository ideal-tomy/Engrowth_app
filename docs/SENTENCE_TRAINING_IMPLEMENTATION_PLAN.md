# パターンスプリント 実装計画 V2

MVP 実装の段階とタスクを定義します。既存資産（conversation_utterances + TTS キャッシュ）を活用し、30〜60秒の口慣らしトレーニングを実装します。

---

## 1. MVP スコープ

- **モード**: Listen-Repeat（日本語ヒント表示、聞く→即リピート）
- **データ**: `conversation_utterances` から prefix マッチで抽出。音声は `tts_synthesize` 経由。
- **画面**: 会話トレーニング選択の「パターンスプリント」→ パターン一覧 → セッション画面
- **セッション長**: 30/45/60秒選択（デフォルト 45秒）
- **IA**: 瞬間英作文をパターンスプリントに置換。センテンス一覧はカテゴリ見出しセクション化。

---

## 2. 実装フェーズ

### Phase A: 設計更新（完了）

- `SENTENCE_TRAINING_SPEC` を Pattern Sprint V2 仕様へ更新
- SQL サンプル・データソース（`tts_assets.text` 不在）を明記

### Phase B: IA 差し替えと一覧再編

1. **ルート・導線**
   - `instant-composition` 導線を `パターンスプリント` に置換
   - `/pattern-sprint` ルート追加
   - Library 内の該当ボタン文言/遷移先の更新

2. **センテンス一覧**
   - `sentence_list_screen.dart` で `category_tag` ごとにグルーピング表示
   - 各カテゴリ末尾に「このカテゴリでスプリント」導線

3. **会話トレーニング選択**
   - パターンスプリントカード追加（または既存導線の差し替え）

### Phase C: セッション実装

1. **PatternSprintListScreen**
   - パターン一覧（prefix ベース）
   - 30/45/60秒選択

2. **PatternSprintSessionScreen**
   - 自動再生ループ（1フレーズ→2〜3秒猶予→次へ）
   - 一時停止/再開、スキップ、停止
   - プリフェッチ・キャンセル・デバウンス
   - 終了演出（実施件数、「もう1セット」）

3. **PatternSprintService / Provider**
   - `conversation_utterances` からの prefix 抽出
   - 候補整形（重複排除、抽選）

### Phase D: 計測と調整

- analytics: session_start / session_complete / session_abort
- played_count, duration_sec, cache_hit_rate
- 失敗時フォールバック
- prefill 同時実行ポリシーを Runbook に反映

### Phase E: 拡張（将来）

- Shadowing モード
- Pattern Substitution
- Cued Recall 拡張
- n-gram 人気パターン自動提示

---

## 3. ファイル構成

| ファイル | 役割 |
|----------|------|
| `lib/screens/pattern_sprint_list_screen.dart` | パターン選択・秒数選択 |
| `lib/screens/pattern_sprint_session_screen.dart` | セッション実行画面 |
| `lib/providers/pattern_sprint_provider.dart` | 候補取得・セッション状態 |
| `lib/services/pattern_sprint_service.dart` | 抽出クエリ・整形 |
| `lib/screens/sentence_list_screen.dart` | カテゴリグルーピング改修 |
| `lib/utils/router.dart` | `/pattern-sprint` 追加 |
| `lib/screens/conversation_training_choice_screen.dart` | パターンスプリントカード |
| `lib/screens/library_hub_screen.dart` | 瞬間英作文→パターンスプリント導線置換 |

---

## 4. 依存関係

- `OpenAiTtsService`（`fetchAudioUrl`, `playFromUrl`, `stop`）
- `conversation_utterances` / `ConversationService` 拡張または新規取得
- `tts_synthesize` Edge Function
- `ConversationStudyScreen` のプリフェッチ・キャンセル・デバウンス設計

---

## 5. 受け入れ基準（MVP）

- [ ] 会話トレーニング選択から「パターンスプリント」を選べる
- [ ] パターン一覧が表示される
- [ ] 30/45/60秒を選択してセッション開始できる
- [ ] セッション内で聞く→リピート猶予→次へが自動進行する
- [ ] 一時停止/再開/スキップ/停止が破綻しない
- [ ] 英文非表示 + 日本語ヒントのみで運用できる
- [ ] センテンス一覧がカテゴリ見出しセクションで表示される
- [ ] 瞬間英作文導線がパターンスプリントに置換されている
