# 音声メイン会話習得機能 設計書

## 概要

従来の「文字を読む」学習から「音で聞き取り、音で話す」学習へのシフト。
実際の英会話に近い環境を作り、耳と口を鍛えることを目的とする。

## コアコンセプト

### 1. 音声ファースト原則
- **初期状態**: テキストは非表示
- **音声再生必須**: 1回以上音声を流した後にのみテキスト表示ボタンが有効化
- **復習時も同様**: 表示が切り替わるごとにリセット（毎回1回は音声を流す必要がある）

### 2. 会話形式（ラリー）の採用
- 2人以上の会話形式を前提
- ユーザーは役割を選択可能（A役/B役/C役など）
- 「全役割を自分で行う」モードも搭載

### 3. シチュエーション設計
画像に示されたコース構成をベースに：
- **学生コース**: 挨拶、自己紹介、道案内、空港、ホテル、レストラン、ショッピング、交通機関、銀行、郵便局、病院、カスタム
- **ビジネスコース**: 挨拶、自己紹介、道案内、空港、ホテル、レストラン、ショッピング、交通機関、ビジネスメール、プレゼンテーション、カスタム

## データモデル設計

### 1. 会話テーブル（新規）
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  situation_type TEXT,  -- 'student', 'business'
  week_range TEXT,  -- '1-2', '3-4', etc.
  theme TEXT,  -- '挨拶', '自己紹介', etc.
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. 会話発話テーブル（新規）
```sql
CREATE TABLE conversation_utterances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  speaker_role TEXT NOT NULL,  -- 'A', 'B', 'C', 'system'
  utterance_order INTEGER NOT NULL,
  english_text TEXT NOT NULL,
  japanese_text TEXT NOT NULL,
  audio_url TEXT,  -- 音声ファイルURL（オプション）
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, utterance_order)
);
```

### 3. 音声再生履歴テーブル（新規）
```sql
CREATE TABLE voice_playback_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  utterance_id UUID REFERENCES conversation_utterances(id) ON DELETE CASCADE,
  played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  playback_type TEXT,  -- 'tts', 'user_recording', 'system_audio'
  UNIQUE(user_id, conversation_id, utterance_id, played_at)
);
```

### 4. 既存テーブルの拡張
- `sentences`テーブル: 会話形式に対応するため、`conversation_id`と`utterance_order`を追加（後方互換性のためオプショナル）
- `scenarios`テーブル: `conversation_mode`フィールドを追加（'sentence' or 'conversation'）

## UI/UX設計

### 1. 会話学習画面の基本構造
```
┌─────────────────────────┐
│   [シチュエーション画像]   │
│                         │
│   (テキスト非表示)       │
│                         │
├─────────────────────────┤
│  [音声再生ボタン]        │
│  [録音/発話ボタン]       │
│  [テキスト表示ボタン]    │ ← 音声再生後に有効化
└─────────────────────────┘
```

### 2. 会話ラリー表示モード
```
┌─────────────────────────┐
│   [シチュエーション画像]   │
├─────────────────────────┤
│  👤 A: [音声再生]        │
│  👤 B: [音声再生]        │
│  👤 A: [音声再生]        │
│  👤 B: [音声再生]        │
│                         │
│  [あなたのターン]        │
│  [録音ボタン]           │
└─────────────────────────┘
```

### 3. テキスト表示の条件
- **初期状態**: テキスト非表示、テキスト表示ボタンも非表示
- **音声再生後**: テキスト表示ボタンが有効化
- **テキスト表示後**: 次回の会話/例文に移るとリセット
- **復習時**: 同じ会話でも毎回1回は音声を流す必要がある

## 学習フロー

### モード1: 聞き流しモード
1. シチュエーション画像表示
2. 「会話を聞き流す」ボタンをタップ
3. 会話全体を自動再生（A→B→A→B...）
4. 各発話の音声再生後にテキスト表示ボタンが有効化

### モード2: ロールプレイングモード
1. シチュエーション画像表示
2. 「各役で参加する」ボタンをタップ
3. 役割選択（A役/B役/C役）
4. 自分のターンで録音/発話
5. 音声認識で判定
6. OK判定なら次の発話者へ

### モード3: 全役割モード
1. シチュエーション画像表示
2. 「全役割を自分で行う」ボタンをタップ
3. 会話全体を順番に発話
4. 各発話の音声再生後にテキスト表示ボタンが有効化

## 技術要件

### 1. 音声認識の強化
- `speech_to_text`パッケージを活用
- 発話判定ロジック（類似度計算）
- 発音評価（将来的に追加可能）

### 2. 音声再生履歴の管理
- ユーザーごとの再生履歴を記録
- テキスト表示ボタンの有効化判定
- セッションごとのリセット

### 3. 会話進行管理
- 現在の発話位置の追跡
- 役割ごとの進行管理
- 会話完了判定

## 実装優先順位

### Phase 1: 基盤整備（1-2週間）
1. データベーススキーマ拡張
2. 会話モデル実装
3. 音声再生履歴管理

### Phase 2: UI実装（2-3週間）
1. 会話学習画面の実装
2. テキスト表示条件の実装
3. 会話ラリー表示

### Phase 3: 音声認識統合（2-3週間）
1. 発話判定ロジック
2. ロールプレイングモード
3. 全役割モード

## 実装済み（2025年2月）

### 音のみ学習フロー
1. **① 会話全体を聞く** - 必須。A/B役ボタンはこれが完了するまで無効
2. **② A役/B役で練習** - 3秒カウントダウン後、相手役が発話開始 → ユーザーのターン
3. **テキスト非表示が原則** - 役モード中は音のみ。フォールバック「どうしてもわからないときはテキストを表示」あり
4. **③ 両役クリア** - テキスト表示なしで両方話せたら次へ（今後実装）

## 既存機能との統合

- **既存の例文**: `conversation_id`がnullの場合は従来通り動作
- **シナリオ機能**: 会話形式のシナリオに対応
- **音声機能**: TTS、録音機能を活用
- **進捗管理**: 会話単位での進捗管理に対応
