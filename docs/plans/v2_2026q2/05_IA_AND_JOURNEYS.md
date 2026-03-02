# トップ→各ページ導線・ページ遷移仕様

## Goal

- アプリトップ（ホーム）から各ページへの導線マップを明確化する。
- タブ・push・モーダルの遷移ポリシーを定義し、迷子を防ぐ。

## Non-Goal

- ルート定義の細部実装。既存 router.dart のポリシーを文書化・拡張する。

## Exit Criteria

- 導線マップが文書化され、新規画面追加時の参照となる。
- 遷移ポリシー（go vs push、戻るの扱い）が一貫している。

---

## 1. 遷移ポリシー（router.dart 準拠）

| 種別 | 用途 | メソッド | 戻る |
|------|------|----------|------|
| タブルート | /home, /library, /progress, /words | context.go | なし（タブ切替） |
|  push | 詳細・設定・学習画面 | context.push | 矢印で戻る |
| モーダル | 全画面シート | push + close アイコン | 閉じるのみ |

---

## 2. ホーム（/home）からの導線マップ

### 2.1 メインタイル（MainTilesGrid）経由

| タップ先 | 遷移先 | 種別 |
|----------|--------|------|
| 会話トレーニング | /conversation-training | push |
| 単語検索 | /words?focus=search または /search | go |
| パターンスプリント | /pattern-sprint | push |
| センテンス一覧 | /sentences | push |
| 学習進捗 | /progress/scenario-board または /progress/story-board | push |
| お気に入り | /favorites | push |
| 本日の復習 | /review | push |
| 録音履歴 | /recordings | push |
| 設定 | ドロワー内 | - |

### 2.2 カード経由

| カード | 遷移先 | 備考 |
|--------|--------|------|
| ResumeLearningCard | /study, /scenario/:id, /story/:id 等 | 続きから |
| RecommendedCard | 各種学習画面 | 推奨 |
| DailyReportCard | 日課関連 | coaching 時 |
| TodaysMissionCard | ミッション詳細 | coaching 時 |

### 2.3 ドロワー（設定）

| 項目 | 遷移先 | AuthStage/ロール |
|------|--------|------------------|
| 使い方 | /help | 全員 |
| コンセプト | /concept | 全員 |
| アカウント | /account | 全員 |
| 録音履歴 | /recordings | ログイン時 |
| 担当コンサルへ連絡 | /consultant-contact | ログイン時 |
| 講師用ダッシュボード | /consultant | コンサル時 |
| 管理者ダッシュボード | /admin | 管理者時 |
| データ保存について | 説明 | 匿名時 |
| 各種設定 | /hint-settings, /playback-speed-settings 等 | 全員 |

### 2.4 Marquee（HeaderMarqueeRail）

- marquee_tap から学習開始までの到達率を KPI で追跡。
- タップ先は学習コンテンツ（シナリオ/ストーリー/センテンス）へ。

---

## 3. Library（/library）からの導線

- シナリオ一覧 → /scenarios → /scenario/:id
- 会話一覧 → /conversations → /conversation/:id
- ストーリー → /story/:id
- センテンス → /sentences

---

## 4. ロール別ルート

| ルート | アクセス条件 | 未達成時 |
|--------|--------------|----------|
| /consultant | ログイン + isConsultant | /home へリダイレクト |
| /admin | ログイン + isAdmin | /home へリダイレクト |

---

## 5. 初回体験導線

| ステップ | 遷移 |
|----------|------|
| アプリ起動 | /home |
| OnboardingBanner タップ | /onboarding |
| オンボーディング完了 | /tutorial-conversation |
| チュートリアル完了 | /home |

---

## 6. 迷子防止

- 初回導線完了後、必ずホームに誘導する。
- 主要画面からホームへの「1タップ戻り」を保証する（BottomNav の Home タブ）。
- 説明過多を避け、1画面1目的を徹底する。
