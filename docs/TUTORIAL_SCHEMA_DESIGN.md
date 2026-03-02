# チュートリアル専用テーブル設計とRLS方針

## 概要
事前生成音声を使った低遅延・低コストの初回体験チュートリアル用スキーマ。  
リアルタイムAIではなく、DBに保存した音声と意図バケットで返答を決定する。

## エンティティ

### tutorials（チュートリアル定義）
| カラム | 型 | 説明 |
|--------|-----|------|
| id | UUID | PK |
| title | TEXT | タイトル（例: 初回挨拶体験） |
| description_ja | TEXT | 説明（日本語） |
| display_order | INTEGER | 表示順 |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

### tutorial_steps（ステップ定義）
1ステップ = システムが発話 → ユーザーが話す → 意図に応じて返答

| カラム | 型 | 説明 |
|--------|-----|------|
| id | UUID | PK |
| tutorial_id | UUID | FK → tutorials |
| step_order | INTEGER | ステップ順（1起点） |
| prompt_text_en | TEXT | AIの最初の発話（英語） |
| prompt_text_ja | TEXT | AIの最初の発話（日本語） |
| prompt_audio_url | TEXT | 事前生成音声URL（nullable=未設定時TTS） |
| created_at | TIMESTAMPTZ | |

### tutorial_step_responses（意図別返答）
ユーザー発話の意図バケットごとに返答を決定

| カラム | 型 | 説明 |
|--------|-----|------|
| id | UUID | PK |
| tutorial_step_id | UUID | FK → tutorial_steps |
| intent_bucket | TEXT | greeting / self_intro / unknown（フォールバック） |
| response_text_en | TEXT | 返答テキスト（英語） |
| response_text_ja | TEXT | 返答テキスト（日本語） |
| response_audio_url | TEXT | 事前生成音声URL |
| next_step_id | UUID | 次ステップ（NULL=終了） |

## 意図バケット（アプリ側でマッピング）
STT結果を以下のバケットに正規化する（Dart実装）:
- **greeting**: Hello, Hi, Hey, こんにちは 等
- **self_intro**: My name is, I'm X, 〜です 等
- **unknown**: 上記以外 → フォールバック応答（「もう一度言ってみよう」等）

## RLS方針
- 全テーブル: SELECT のみ許可（anon / authenticated）
- 挿入・更新・削除: アプリからは行わない。管理画面やSQLで投入
- RLS: `USING (true)` で全ユーザーが読み取り可能
