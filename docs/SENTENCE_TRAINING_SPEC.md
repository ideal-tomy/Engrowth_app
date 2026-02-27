# センテンストレーニング機能 仕様書

頻出言い回しを様々なパターンで連続発話し、口と脳を慣れさせるトレーニング機能の仕様です。
第二言語習得（SLA）研究に基づく設計です。

---

## 1. 目的

- **自動化の促進**: 頻出チャンク（formulaic sequences）を反復により自動化
- **口頭流暢性の向上**: 聞く→発話のサイクルを短く繰り返す
- **転移の促進**: 同一表現を複数コンテキストで体験し、別シーンへの転用を促す

---

## 2. 学習モード（SLA根拠）

| モード | 説明 | SLA根拠 |
|--------|------|---------|
| **Listen-Repeat** | 音声提示→即復唱 | 模倣・明示的記憶の活性化 |
| **Shadowing** | 短遅延（0.5〜1秒）で追従 | 聴覚的短期記憶・発話の同期 |
| **Pattern Substitution** | 語句差し替えで連続発話 | 変形練習・文法的柔軟性 |
| **Cued Recall** | 日本語/状況ヒントから英語再生 | 検索練習・長期記憶の強化 |

各モードで難易度（1000語/3000語）と速度（0.6x〜1.2x）を段階制御。

---

## 3. データモデル

### 3.1 Training Pack

1 トレーニングセッションの単位。例: 20 チャンク。

| フィールド | 型 | 説明 |
|------------|-----|------|
| id | uuid | 一意ID |
| title | text | 表示名（例: 「注文・依頼の言い回し」） |
| description | text | 概要 |
| difficulty | int | 1=初級(1000語), 2=中級(3000語) |
| scene_tag | text | シーン（カフェ, ホテル, 道案内 等） |
| display_order | int | 表示順 |
| created_at | timestamptz | - |

### 3.2 Training Chunk

1 つの頻出表現とそのバリエーション。

| フィールド | 型 | 説明 |
|------------|-----|------|
| id | uuid | 一意ID |
| pack_id | uuid | 所属 Pack |
| base_phrase_en | text | 基盤となる英語表現 |
| base_phrase_jp | text | 日本語訳 |
| variations | jsonb | バリエーション配列（3〜5件） |
| chunk_order | int | Pack 内の順序 |

`variations` の例:
```json
[
  {"en": "I'd like a coffee, please.", "jp": "コーヒーをください。"},
  {"en": "I'd like to check in, please.", "jp": "チェックインをお願いします。"}
]
```

### 3.3 既存 sentences の再利用（代替案）

`sentences` テーブルに `training_pack_id` を追加し、`category_tag` を `#SentenceTraining` 等に統一することで、既存の Sentence モデル・Provider を流用可能。バリエーションは `target_words` や別カラムで管理。

---

## 4. UI/UX 設計

### 4.1 入口

- **会話トレーニング選択画面** (`ConversationTrainingChoiceScreen`) に「センテンストレーニング」カードを追加
- タップで `/sentence-training` へ遷移

### 4.2 パック一覧

- Pack をカード形式で一覧表示
- フィルタ: 難易度、シーン
- 進捗表示: 完了率、最後に実施した日時（任意）

### 4.3 トレーニング画面

- 1 チャンク単位で表示
- **Listen**: TTS 再生ボタン
- **Repeat**: 録音ボタン（既存 `AudioControls` を再利用）
- 次/前へのナビゲーション
- モード切替: Listen-Repeat / Shadowing / Pattern Substitution / Cued Recall（MVP では Listen-Repeat のみでも可）

### 4.4 進捗

- `accuracy_proxy`: 自己評価（「うまく言えた」/「もう一度」）または再生回数・完了率
- 記録先: `user_progress` 拡張または `sentence_training_sessions` 新規テーブル

---

## 5. 頻出表現の例（Pack 構築用）

| 表現 | バリエーション例 |
|------|------------------|
| I'd like ~ | I'd like a coffee. / I'd like to check in. / I'd like two of those. |
| Could you ~ | Could you tell me ~? / Could you help me ~? |
| Can I ~ | Can I have ~? / Can I get ~? |
| I'm looking for ~ | I'm looking for a hotel. / I'm looking for the station. |
| How much ~ | How much is this? / How much does it cost? |
| Where can I ~ | Where can I find ~? / Where can I get ~? |
| Is it possible to ~ | Is it possible to change my reservation? |

---

## 6. 既存資産の再利用

- **再生**: `TtsService`（`speakEnglish`, `speakEnglishSlow`）
- **録音**: `AudioControls` / `VoiceSubmissionService`
- **例文一覧**: `SentenceListScreen` のレイアウト・フィルタを参考に、Training Pack 一覧を構築
- **進捗**: `SupabaseService.getUserProgress` のパターンを流用し、`training_pack_id` ベースの進捗を追加
