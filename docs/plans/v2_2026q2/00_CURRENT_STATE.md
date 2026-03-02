# 現状棚卸し（計画入力）

本ファイルは3ヶ月バージョンアップ計画の入力情報として、既存ルート・画面・ロール機能・現行ドキュメントを整理したものです。

## 1. ルート一覧（lib/utils/router.dart 基準）

### メイン4タブ
| パス | 画面 | 説明 |
|------|------|------|
| /home | DashboardScreen | ホーム・全導線ハブ |
| /library | LibraryHubScreen | コンテンツ入口 |
| /progress | ProgressScreen | 進捗・統計 |
| /words | WordListScreen | 単語検索・一覧 |

### 学習関連
| パス | 画面 | 説明 |
|------|------|------|
| /study | StudyScreen | 例文学習（30秒/3分） |
| /conversation-training | ConversationTrainingChoiceScreen | 30秒/3分選択 |
| /scenario-learning | ScenarioLearningScreen | 30秒会話入口 |
| /story-training | StoryTrainingScreen | 3分会話入口 |
| /scenario/:id | ScenarioStudyScreen | シナリオ詳細 |
| /conversation/:id | ConversationStudyScreen | 会話学習 |
| /story/:id | StoryStudyScreen | ストーリー学習 |
| /pattern-sprint | PatternSprintListScreen | パターンスプリント |
| /pattern-sprint/session | PatternSprintSessionScreen | スプリントセッション |
| /sentences | SentenceListScreen | センテンス一覧 |
| /conversations | ConversationListScreen | 会話一覧 |
| /scenarios | ScenarioListScreen | シナリオ一覧 |

### 振り返り・継続
| パス | 画面 | 説明 |
|------|------|------|
| /recordings | RecordingHistoryScreen | 録音履歴（練習/提出済み） |
| /review | ReviewListScreen | 本日の復習 |
| /favorites | FavoritesScreen | お気に入り |
| /progress/scenario-board | ScenarioProgressBoardScreen | シナリオ進捗 |
| /progress/story-board | StoryProgressBoardScreen | ストーリー進捗 |

### 初回体験・説明
| パス | 画面 | 説明 |
|------|------|------|
| /onboarding | OnboardingFlowScreen | 初回体験7ステップ |
| /tutorial-conversation | TutorialConversationScreen | 挨拶体験（事前生成音声） |
| /help | HelpScreen | 使い方 |
| /concept | ConceptScreen | Engrowthが選ばれる理由 |

### 設定・アカウント
| パス | 画面 | 説明 |
|------|------|------|
| /account | AccountScreen | アカウント作成・管理 |
| /hint-settings | HintSettingsScreen | 2秒ヒント設定 |
| /playback-speed-settings | PlaybackSpeedSettingsScreen | 音声再生速度 |
| /notifications | NotificationsScreen | 通知一覧 |

### ロール別（権限制御あり）
| パス | 画面 | アクセス | 備考 |
|------|------|----------|------|
| /consultant | ConsultantDashboardScreen | ログイン必須 | 未ログイン時 /home へリダイレクト |
| /admin | AdminDashboardScreen | ログイン必須 | 同上、ロールは画面側で判定 |

## 2. ロール機能の現状

### ユーザー（学習者）
- 実装済み: ホーム導線、初回体験、学習全般、録音・提出、通知、設定
- TODO: 担当コンサルタントへ連絡（メッセージ画面未実装、Snackbarで準備中表示）

### コンサルタント
- 判定: consultant_assignments に consultant_id で登録、または devViewAsConsultantProvider
- 実装済み: 今日の報告タブ、日課運用タブ、提出キュー、音声再生、テンプレ挿入、フィードバック送信
- TODO: user_sessions 連携による詳細ログ、課題プリセット発行UIの本格化

### 管理者
- 判定: 本番は未実装（TODO: JWT app_role=admin）、開発時は devViewAsAdminProvider
- 実装済み: 4タブUI（権限付与/監査/運用/AI承認）
- TODO: 実データ連携、権限付与ロジック、監査ログ、AI承認フロー

## 3. 現行ドキュメント（参照すべき一次資料）

- MASTER_PLAN.md
- docs/ACTIVE_DOCS_INDEX.md
- docs/DAILY_VOICE_ONBOARDING_QA.md
- docs/MARQUEE_QA_CHECKLIST.md
- docs/TUTORIAL_SCHEMA_DESIGN.md
- docs/TUTORIAL_FUNNEL_QA.md
- docs/SUPABASE_MIGRATION_ORDER.md
- supabase/migrations/MIGRATION_CATALOG.md

### 補助（計画の精度向上用）
- docs/受け入れ基準_E2E確認.md
- docs/kpi_ux_plan.md
- docs/ux_audit_mobile.md
- docs/ENGROWTH_DESIGN_SYSTEM.md

## 4. ホーム（DashboardScreen）構成要素

- ヘッダー（メニュー、タイトル、連続日数）
- HeaderMarqueeRail（enableMarquee 時）
- OnboardingBanner（初回未完了時）
- AnonymousDataSaveBanner（匿名時）
- CoachBanner / TodaysMissionCard（coaching プラン時）
- DailyReportCard
- ConversationPracticeGoalCard
- ResumeLearningCard
- RecommendedCard
- MainTilesGrid（会話トレーニング、単語検索、パターンスプリント、センテンス一覧、学習進捗、お気に入り、本日の復習、録音履歴、設定）
- AnonymousLpBanner（匿名時）
- ConsultantNotificationBanner（ログイン時）
- Drawer: 設定、使い方、コンセプト、アカウント、録音履歴、各種設定、講師用/管理者ダッシュボード（ロール時）
