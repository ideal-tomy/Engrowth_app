# パターンスプリント（口慣らしトレーニング）仕様書 V2

頻出言い回しを様々なパターンで連続発話し、口と脳を慣れさせるトレーニング機能の仕様です。
第二言語習得（SLA）研究に基づく設計です。既存資産（conversation_utterances + TTS キャッシュ）を活用します。

---

## 1. 目的

- **自動化の促進**: 頻出チャンク（formulaic sequences）を反復により自動化
- **口頭流暢性の向上**: 聞く→発話のサイクルを短く繰り返す（30〜60秒の高密度）
- **転移の促進**: 同一表現を複数コンテキストで体験し、別シーンへの転用を促す
- **達成感**: 短時間で完走でき、継続しやすいサイクル設計

---

## 2. データソース（重要）

- **パターン抽出元**: `conversation_utterances.english_text` を使用する。
- **注意**: `tts_assets` には `text` カラムが存在しない。音声は `tts_synthesize` Edge Function 経由で取得し、キャッシュヒット時は即返却される。
- **音声キャッシュ**: `tts_assets` + Storage `tts-audio` バケット。prefill で事前投入済みの場合は即再生可能。

---

## 3. 学習モード（SLA根拠）

| モード | 説明 | SLA根拠 | MVP |
|--------|------|---------|-----|
| **Listen-Repeat** | 音声提示→即復唱（2〜3秒猶予） | 模倣・明示的記憶の活性化 | ○ |
| **Shadowing** | 短遅延（0.5〜1秒）で追従 | 聴覚的短期記憶・発話の同期 | Phase 2 |
| **Pattern Substitution** | 語句差し替えで連続発話 | 変形練習・文法的柔軟性 | Phase 2 |
| **Cued Recall** | 日本語ヒントのみ表示 | 検索練習・長期記憶の強化 | MVP（日本語ヒントのみ） |

---

## 4. UX要件 V2（MVP）

- **導線**: 会話トレーニング選択に「パターンスプリント」カード。既存「瞬間英作文」導線を置換。
- **セッション長**: デフォルト 45秒。選択肢 30/45/60秒。（30秒は達成感◎だが語数不足しやすい。45秒がバランス良い。）
- **表示**: 英文は原則非表示。画面中央に日本語ヒントのみ。任意で「答えを見る」長押しで英文表示。
- **再生ループ**:
  - 1フレーズごとに「お手本音声」再生
  - 直後に 2〜3秒のリピート猶予
  - 次フレーズへ自動進行
- **操作**: 一時停止/再開、スキップ、停止（即時キャンセル）、連打防止（デバウンス）
- **終了演出**: 実施フレーズ数、推定発話時間、「もう1セット」ボタン

---

## 5. センテンス一覧 UX 改修

- **目的**: カテゴリ単位で見渡せる一覧にする。
- **表示イメージ**:
  - タイトル: 道案内 → 道案内に関する例文1、2、3...
  - タイトル: 接客 → 接客に関する例文1、2、3...
- **実装**: `sentence_list_screen.dart` で `category_tag` ごとにグルーピング表示。
- **各カテゴリ**: 末尾に「このカテゴリでスプリント」導線を追加。

---

## 6. パターン抽出ロジック

- **MVP**: prefix マッチ（例: `Can I have`, `I'd like`, `Could you`）
- **候補生成手順**:
  1. `conversation_utterances` から prefix に合う英文を取得
  2. 同文重複を除外
  3. セッション秒数に応じて N 件を抽選
  4. 再生順を「易→難」またはランダムで選択
- **拡張（Phase 2）**: 2語/3語 n-gram 集計で人気パターンを自動提示

---

## 7. 頻出表現の例

| 表現 | バリエーション例 |
|------|------------------|
| I'd like ~ | I'd like a coffee. / I'd like to check in. |
| Could you ~ | Could you tell me ~? / Could you help me ~? |
| Can I ~ | Can I have ~? / Can I get ~? |
| I'm looking for ~ | I'm looking for a hotel. / I'm looking for the station. |
| How much ~ | How much is this? / How much does it cost? |
| Where can I ~ | Where can I find ~? / Where can I get ~? |

---

## 8. 既存資産の再利用

- **再生**: `OpenAiTtsService`（`fetchAudioUrl`, `playFromUrl`）
- **会話発話**: `conversation_utterances` テーブル
- **TTS キャッシュ**: `tts_synthesize` Edge Function、`tts_assets`、Storage `tts-audio`
- **プリフェッチ・キャンセル**: `ConversationStudyScreen` の設計を流用
- **センテンス一覧**: `SentenceListScreen` のカテゴリグルーピング改修

---

## 9. prefill 同時実行ポリシー

- **結論**: 同時実行は可能だが推奨しない（体感遅延・502 率上昇の恐れ）。
- **ルール**: 本番利用時間帯は `prefill --limit` で小分け実行。大量 prefill はオフピークで実行。
- **監視**: Edge Functions Invocations/Logs で 5xx 率を確認。しきい値超過時は prefill を一時停止。

---

## 10. 瞬間英作文の扱い（アーカイブ）

- MVP期間は機能を非表示にし、ユーザー導線から外す。
- コード資産は即削除せず保持。
- 再導入判断: パターンスプリントの継続率/完走率が安定し、「産出系（英作文）」ニーズが定量で確認できた時点。
