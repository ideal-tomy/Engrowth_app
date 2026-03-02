# 日課・初回体験 実装 QA チェックリスト

## KPI イベント（analytics_events テーブル）

| event_type | 説明 |
|------------|------|
| `onboarding_started` | 初回体験開始 |
| `onboarding_step_completed` | 初回体験ステップ完了（step, step_index） |
| `onboarding_completed` | 初回体験完了 |
| `onboarding_skipped` | 初回体験スキップ（at_step） |
| `daily_report_recorded` | 日課録音完了 |
| `daily_report_submitted` | 日課提出完了 |
| `daily_report_card_shown` | 日課カード表示（status） |
| `tutorial_started` | 挨拶体験チュートリアル開始 |
| `tutorial_step_started` | チュートリアルステップ開始（step_id, step_order） |
| `tutorial_step_completed` | チュートリアルステップ完了（step_id, intent, used_fallback） |
| `tutorial_fallback_used` | 意図不明でフォールバック応答使用（step_id, stt_text） |
| `tutorial_completed` | チュートリアル完了 |
| `tutorial_skipped` | チュートリアルスキップ（at_step_id） |

## E2E 確認シナリオ

### 1. 初回起動 → 体験完了 → 録音保存 → 提出 → コンサル確認

1. 初回体験をリセット（設定ドロワー > 開発: 初回体験をリセット）
2. ホームで「初回体験をはじめる」バナーをタップ
3. ようこそ → 「はじめる」→ 挨拶体験ステップで「体験する」→ チュートリアル会話画面
4. マイクを押して「Hello」や「My name is ...」と話し、返答を確認（スキップも可）
5. 各ステップを進め、必要に応じて「体験する」で実際の画面へ遷移
6. 最終ステップで「ホームへ」をタップ
7. ホームに日課カードが表示されることを確認
8. 録音（例文学習 or 会話学習）→「今日の報告を送る」で提出
9. 録音履歴画面で提出済みタブに表示されることを確認
10. コンサルダッシュボード（開発: コンサルタント ON）で提出がキューに表示されることを確認

### 2. 匿名ユーザー時の案内

1. 匿名のまま録音履歴画面を開く
2. 「アカウントを作成すると録音履歴が保存されます」が表示されることを確認
3. 日課カードは表示されない（ログイン時のみ）ことを確認

### 3. ロール別導線

- **一般ユーザー**: ホーム → 日課カード → 録音履歴 → 提出
- **コンサルタント**: 設定ドロワーから「講師用ダッシュボード」→ 今日の報告タブ
- **管理者**: 設定ドロワーから「管理者ダッシュボード」→ 運用タブで日課提出指標

## 主要ルート

- `/onboarding` - 初回体験フロー
- `/tutorial-conversation` - 挨拶体験チュートリアル（事前生成音声／意図バケット）
- `/recordings` - 録音履歴（練習/提出済み）
- `/consultant` - コンサルタントダッシュボード
- `/admin` - 管理者ダッシュボード
