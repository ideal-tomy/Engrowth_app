# 実装PLAN.md
## 管理者ダッシュボード / コンサルタントダッシュボード拡張
### テーマ: プライバシーと伴走の両立

## 0. 背景と前提

- 現在、音声提出基盤（`voice_submissions` / `voice_feedbacks`）と伴走基盤（`consultant_assignments` / `coach_missions` / `daily_summaries`）は存在する。
- ただし、クライアント心理的安全性（「提出物のみ共有」）と、コンサルタント伴走に必要な努力ログ（試行回数・滞在時間・端末情報）の分離が未整理。
- 既存UIUX（ミニマルで上質、ライト/ダーク統一）を維持し、情報密度だけ強化する。

---

## 1. 目的 / 非目的

### 目的

1. クライアントに「提出した録音のみコンサルに見える」認識を明確化する。
2. コンサルタントが提出物を迅速評価し、必要時に詳細ログを確認できる。
3. 学習セッション（端末・時間・試行）を保存し、伴走型指導に活用できる。
4. 管理者が権限付与により過去期間含むログ閲覧を制御できる。
5. ユーザー要望/レビューを日次でAI要約し、改善ループを回す。

### 非目的（このフェーズではやらない）

- 音声の自動採点モデル導入（ASR精度評価など）
- リアルタイムチャットの既読/未読高度機能
- 多言語管理画面

---

## 2. UX原則（心理的安全性 + 高級感）

1. **共有境界の明示**
   - クライアント画面で常時表示:  
     「コンサルタントに共有されるのは“提出済み録音”のみです」
2. **努力ログは自己成長の文脈で表示**
   - 「試行回数」「学習時間」は評価値ではなく、継続の証として見せる。
3. **コンサル画面は2層構造**
   - 主画面: 提出音声の評価導線（速く）
   - 詳細: 背景ログ（深く）
4. **UI統一**
   - 既存 `Theme.of(context).colorScheme` 準拠
   - カード角丸・薄い境界線・ダーク時は影より境界線重視
   - 情報過多は避け、ドロワー/詳細画面に逃がす

---

## 3. 画面要件

## 3.1 クライアント側（学習ユーザー）

### A. マイ録音履歴画面（新規）
- タブ:
  - `練習`（practice）
  - `提出済み`（submitted）
- 各録音カード:
  - 録音日時、課題名、再生ボタン
  - セッション要約（試行回数 / 学習時間）
  - ステータス（未提出 / 提出済み / フィードバック済）
- 画面上部に固定説明:
  - 「提出済みのみコンサルタントに共有されます」

### B. 録音提出導線（既存拡張）
- 提出前確認モーダル:
  - 提出対象、提出後に見える相手、取り消し可否
- 提出後:
  - 成功トースト + `提出済み` タブへ誘導

### C. クライアント向け伴走表示
- 今日の課題（`coach_missions`）
- コンサルからのコメント（`voice_feedbacks`）
- 簡易コミュニケーション（後述 messages）

---

## 3.2 コンサルタント側ダッシュボード（既存拡張）

### A. メイン一覧（最重要）
- 表示対象: `submission_type = submitted`
- ソート: 提出日時 DESC
- 各カードで即実行:
  - 音声再生
  - テンプレ挿入
  - コメント送信
  - 対応ステータス変更

### B. 詳細ログドロワー（新規）
- 項目:
  - 端末情報（OS / 機種 / device_type: smartphone/tablet/pc）
  - 学習日時（session_timestamp）
  - セッション時間（duration_sec）
  - リトライ回数（retry_count）
  - 試行回数（attempt_count）
  - 直近7日傾向（夜間学習比率など）
- 原則:
  - 主画面を汚さず、必要時のみ開く

### C. 課題発行（既存強化）
- プリセット:
  - 「3分会話をフルで録音して1本提出」
  - 「A役を3回提出」
- 手入力との併用可

---

## 3.3 管理者ダッシュボード（新規）

### A. 権限付与
- コンサルタントに対し特定クライアント閲覧権を付与
- 過去期間ログ閲覧の可否を設定
- 監査ログ（誰が誰を見たか）を記録

### B. 運用監視
- 未対応提出件数
- レビュー遅延
- 週間継続率
- AI要約の承認待ち件数

---

## 4. データベース拡張

## 4.1 新規テーブル: `user_sessions`
学習セッション単位の記録。

- `id uuid pk`
- `user_id uuid not null`
- `track text check (track in ('scenario','story','sentence','conversation'))`
- `content_id uuid null`（対象コンテンツ）
- `session_timestamp timestamptz not null default now()`
- `started_at timestamptz`
- `ended_at timestamptz`
- `duration_sec int default 0`
- `attempt_count int default 0`
- `retry_count int default 0`
- `device_os text`（iOS / Android / Windows / macOS / Web）
- `device_model text`（例: iPhone15,3）
- `device_type text check (device_type in ('smartphone','tablet','pc','other'))`
- `app_version text`
- `metadata jsonb default '{}'::jsonb`
- `created_at timestamptz default now()`

## 4.2 既存拡張: `voice_submissions`
- `session_id` を `user_sessions.id` と紐づけ（text→uuid移行 or 新カラム `session_uuid`）
- `submission_context jsonb` 追加（提出時の要約をスナップショット保存）

## 4.3 新規テーブル: `consultant_client_permissions`
期間外閲覧を管理者が制御。

- `id uuid pk`
- `consultant_id uuid not null`
- `client_id uuid not null`
- `can_view_historical boolean default false`
- `valid_from timestamptz null`
- `valid_to timestamptz null`
- `granted_by uuid not null`（admin）
- `created_at timestamptz default now()`

## 4.4 コミュニケーション
最小構成:

- `coach_threads`（client-consultantペア）
- `coach_messages`（本文、種別、送信者、created_at、read_at）

## 4.5 要望/レビュー
- `app_feedback`
  - `author_role`（client/consultant）
  - `category`（bug, ux, feature, other）
  - `content`
  - `status`（new, triaged, planned, done）

---

## 5. RLS/権限方針（必須）

1. `voice_submissions`
   - クライアント: 自分の行のみ
   - コンサル: 担当クライアントのみ
   - 管理者: 全体
2. `voice_feedbacks`
   - 提出者本人 + 担当コンサル + 管理者のみ参照
3. `user_sessions`
   - 本人参照可
   - 担当コンサル参照可
   - `can_view_historical` が true の場合は期間外も可
4. 管理者権限は JWT claim で判定（`app_role=admin`）

---

## 6. イベント計測

- 既存 `analytics_events` は継続利用
- 新規イベント例:
  - `session_started`
  - `session_completed`
  - `submission_created`
  - `submission_sent`
  - `consultant_feedback_sent`
  - `historical_access_granted`
  - `feedback_posted`

---

## 7. AI日次要約 + 承認フロー（推奨）

## 7.1 日次バッチ（毎日）
- 00:10 UTC/JST に集計ジョブ実行
- 入力:
  - `app_feedback`
  - `analytics_events`
  - `voice_submissions` / `user_sessions` の統計
- 出力テーブル: `daily_ai_insights`
  - `summary_date`
  - `highlights`
  - `risks`
  - `top_requests`
  - `proposed_actions`
  - `status`（draft/approved/rejected）
  - `generated_by_model`

## 7.2 承認フロー（最適提案）
- Step1: AIが `draft` 作成
- Step2: 運用担当（admin or lead consultant）が確認
- Step3:
  - 問題なければ `approved` で公開
  - 不適切なら `rejected` + reason記録
- Step4: 公開先
  - 管理者ダッシュボード: 全文
  - コンサル画面: 実行タスクのみ短縮表示

※理由: 毎日自動化しつつ、誤要約・過剰解釈を人間が制御できるため。

---

## 8. 実装フェーズ

### Phase 1（1〜2週間）
- RLS是正
- クライアントUIで「提出のみ共有」明示
- コンサル一覧の提出レビュー導線改善

### Phase 2（1〜2週間）
- `user_sessions` 導入
- 録音提出とセッション紐づけ
- コンサル詳細ログドロワー追加

### Phase 3（1週間）
- 管理者権限付与UI
- 期間外閲覧ロジック追加
- 監査ログ整備

### Phase 4（1〜2週間）
- `app_feedback` 投稿UI
- AI日次要約バッチ + 承認画面

---

## 9. 受け入れ基準（抜粋）

1. クライアントは「練習」と「提出済み」を明確に区別して閲覧できる。
2. コンサルメイン画面は提出録音のみ表示される。
3. 詳細ログで OS/機種/device_type、retry、duration が確認できる。
4. 管理者が付与した権限で期間外ログ閲覧が可能になる。
5. AI要約は毎日自動生成され、承認後のみ公開される。
6. ライト/ダーク双方で可読性と既存UI統一を維持する。

---

## 10. UI統一ルール（実装時ガイド）

- 色は `Theme.of(context).colorScheme` のみ使用（直書き最小化）
- ダークモードでは影を減らし、境界線（outlineVariant）を活用
- 主要カード半径・余白は既存値に合わせる（角丸24/12系を踏襲）
- 一次操作（提出/送信）は常に右下 or カード下部の同位置に固定
- 心理負荷を上げる文言（「失敗」「不足」）は避ける

---