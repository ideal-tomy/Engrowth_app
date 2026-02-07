# 全Issue一覧

Engrowthアプリの開発で作成すべき全Issueの一覧です。

## Phase 1: 基礎固め

### Issue #1: 単語ページ - 検索機能の強化
**タイトル**: `[Feature] 単語ページの検索機能を強化`

**内容**:
- リアルタイム検索の実装（デバウンス300ms）
- 検索候補の表示
- 検索履歴の保存
- 高度な検索オプション（品詞、グループで絞り込み）

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`

---

### Issue #2: 単語ページ - フィルタリング機能の追加
**タイトル**: `[Feature] 単語ページにフィルタリング機能を追加`

**内容**:
- 品詞フィルタ（動詞、名詞、形容詞など）
- グループフィルタ（S-001, S-002, Basicなど）
- 学習状況フィルタ（すべて、学習済み、未学習）
- フィルタチップの実装

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`

---

### Issue #3: 単語ページ - ソート機能の追加
**タイトル**: `[Feature] 単語ページにソート機能を追加`

**内容**:
- アルファベット順（A-Z, Z-A）
- 追加日順（新着、古い順）
- 学習回数順
- お気に入り順

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`

---

### Issue #4: 単語ページ - カードデザインの改善
**タイトル**: `[UI/UX] 単語カードのデザインを改善`

**内容**:
- グリッド表示の実装
- カードレイアウトの改善
- 画像表示エリアの追加
- アニメーションの追加

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`, `docs/UI_UX_DESIGN.md`

---

### Issue #5: 例文ページ - カードデザインの改善
**タイトル**: `[UI/UX] 例文カードのデザインを改善`

**内容**:
- カードレイアウトの改善
- カテゴリタグの表示
- シーン設定の表示
- ターゲット単語の表示

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`, `docs/UI_UX_DESIGN.md`

---

### Issue #6: 例文ページ - カテゴリフィルタの追加
**タイトル**: `[Feature] 例文ページにカテゴリフィルタを追加`

**内容**:
- カテゴリチップの実装
- 複数カテゴリの選択
- カテゴリ別のフィルタリング

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`

---

### Issue #7: 例文ページ - 検索機能の強化
**タイトル**: `[Feature] 例文ページの検索機能を強化`

**内容**:
- 全文検索（英語、日本語）
- タグ検索
- シーン検索
- リアルタイム検索

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`

---

### Issue #8: Supabase Storage設定
**タイトル**: `[Backend] Supabase Storageの設定とバケット作成`

**内容**:
- `sentences-images`バケットの作成
- `words-images`バケットの作成
- ストレージポリシーの設定
- CORS設定

**ラベル**: `backend`, `database`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #9: 画像アップロードサービス実装
**タイトル**: `[Feature] 画像アップロードサービスの実装`

**内容**:
- `ImageUploadService`クラスの実装
- 画像リサイズ機能
- Supabase Storageへのアップロード
- データベース更新

**ラベル**: `backend`, `enhancement`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #10: 画像表示の改善
**タイトル**: `[UI/UX] 画像表示の改善と最適化`

**内容**:
- 画像キャッシュの最適化
- プレースホルダーの改善
- エラー表示の改善
- 遅延読み込みの実装

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #26: 学習モード - インテリジェント・ヒント・フェード機能 ⭐
**タイトル**: `[Feature] インテリジェント・ヒント・フェード機能の実装`

**内容**:
- 2秒（カスタマイズ可能）詰まったらヒントがフェードイン
- 段階的ヒント表示（先頭1文字→先頭3単語→重要単語）
- ヒント使用ログの記録
- 視覚的・触覚的フィードバック

**技術要件**:
- `ThinkingTimer`クラスの実装
- `HintDisplay`ウィジェットの実装
- `HintPhase`enumの定義
- タイマー管理システム
- ヒント使用ログのデータベース保存
- バイブレーション機能（`HapticFeedback`）

**デザイン要件**:
- 段階的フェードインアニメーション（300ms）
- 画面の微かな光る効果
- パルスアニメーション（重要単語）
- スライドインアニメーション
- Material Design 3準拠

**脳科学的根拠**:
- 望ましい困難（Desirable Difficulty）
- 足場かけ（Scaffolding）
- アハ体験とドーパミン放出
- 想起練習（Retrieval Practice）

**ラベル**: `frontend`, `enhancement`, `learning`

**関連ドキュメント**: `docs/LEARNING_MODE_DESIGN.md`

---

## Phase 2: UI/UX強化

### Issue #11: 単語ページ - グリッド/リスト表示切替
**タイトル**: `[Feature] 単語ページにグリッド/リスト表示切替を追加`

**内容**:
- 表示モードの切替機能
- グリッド表示の実装
- リスト表示の実装
- アニメーション

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`

---

### Issue #12: 単語ページ - アニメーション追加
**タイトル**: `[UI/UX] 単語ページにアニメーションを追加`

**内容**:
- カード表示アニメーション
- リスト/グリッド切替アニメーション
- フィルタ変更アニメーション
- マイクロインタラクション

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`, `docs/UI_UX_DESIGN.md`

---

### Issue #13: 単語ページ - スワイプジェスチャー
**タイトル**: `[Feature] 単語カードにスワイプジェスチャーを追加`

**内容**:
- 左スワイプ: お気に入り追加
- 右スワイプ: 学習済みマーク
- スワイプアニメーション

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/WORD_PAGE_DESIGN.md`

---

### Issue #14: 例文ページ - 画像オーバーレイ実装
**タイトル**: `[UI/UX] 例文カードに画像オーバーレイを追加`

**内容**:
- グラデーションオーバーレイ
- カテゴリタグの表示
- 難易度バッジの表示

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`

---

### Issue #15: 例文ページ - 詳細表示モーダル
**タイトル**: `[Feature] 例文詳細表示モーダルの実装`

**内容**:
- モーダル/ボトムシートの実装
- フルサイズ画像表示
- 完全な例文表示
- 関連情報の表示

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`

---

### Issue #16: 例文ページ - アニメーション追加
**タイトル**: `[UI/UX] 例文ページにアニメーションを追加`

**内容**:
- カード表示アニメーション
- 画像フェードイン
- フィルタ変更アニメーション

**ラベル**: `frontend`, `ui/ux`, `enhancement`

**関連ドキュメント**: `docs/SENTENCE_PAGE_DESIGN.md`, `docs/UI_UX_DESIGN.md`

---

### Issue #17: 画像リサイズ機能
**タイトル**: `[Feature] 画像リサイズ機能の実装`

**内容**:
- アップロード時の自動リサイズ
- 複数サイズの生成（original, medium, thumbnail）
- 画像最適化

**ラベル**: `backend`, `enhancement`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #18: サムネイル生成
**タイトル**: `[Feature] 画像サムネイル生成機能の実装`

**内容**:
- サムネイルの自動生成
- サムネイルの保存
- サムネイルの表示

**ラベル**: `backend`, `enhancement`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #19: キャッシュ戦略の実装
**タイトル**: `[Feature] 画像キャッシュ戦略の実装`

**内容**:
- メモリキャッシュの最適化
- ディスクキャッシュの設定
- プリロード戦略

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/IMAGE_IMPLEMENTATION.md`

---

### Issue #27: 学習モード - ヒント設定画面
**タイトル**: `[Feature] ヒント設定画面の実装`

**内容**:
- ヒント表示までの時間設定（2秒/5秒/10秒/カスタム）
- ヒントの段階設定（3段階/5段階/カスタム）
- ヒントの透明度設定
- バイブレーションON/OFF

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/LEARNING_MODE_DESIGN.md`

---

## Phase 3: 進捗管理

### Issue #20: 進捗サマリーカード
**タイトル**: `[Feature] 進捗サマリーカードの実装`

**内容**:
- 覚えた/学習中/未学習の表示
- 数値の強調表示
- カードデザイン

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #21: 進捗バー実装
**タイトル**: `[Feature] 進捗バーの実装`

**内容**:
- 線形プログレスバー
- 進捗率の表示
- アニメーション

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #22: 学習統計表示
**タイトル**: `[Feature] 学習統計の表示`

**内容**:
- 連続学習日数
- 学習時間の表示
- 平均学習時間

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #23: 達成度グラフ
**タイトル**: `[Feature] 達成度グラフの実装`

**内容**:
- 週間グラフ（折れ線）
- 月間グラフ（棒）
- データの可視化

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #24: カテゴリ別進捗
**タイトル**: `[Feature] カテゴリ別進捗の表示`

**内容**:
- カテゴリごとの進捗バー
- 進捗率の表示
- フィルタリング

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #25: 学習履歴リスト
**タイトル**: `[Feature] 学習履歴リストの実装`

**内容**:
- 日付ごとのグループ化
- 学習した例文の表示
- 詳細情報の表示

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`

---

### Issue #28: 進捗管理 - ヒント使用統計の表示
**タイトル**: `[Feature] ヒント使用統計の表示`

**内容**:
- ヒント使用率の表示
- 段階別ヒント使用回数
- ヒントを使って覚えた例文数
- 平均思考時間

**ラベル**: `frontend`, `enhancement`

**関連ドキュメント**: `docs/PROGRESS_DESIGN.md`, `docs/LEARNING_MODE_DESIGN.md`

---

## Phase 4: 高度な機能

### Issue #29: 学習モード - パーソナライズド復習リスト
**タイトル**: `[Feature] ヒント使用履歴に基づく復習リスト`

**内容**:
- ヒントを使った例文を優先的に復習
- ヒント使用回数に基づく優先順位
- カスタマイズ可能な復習アルゴリズム

**ラベル**: `frontend`, `backend`, `enhancement`

**関連ドキュメント**: `docs/LEARNING_MODE_DESIGN.md`

---

## Phase 5: 学習体験強化機能

### Issue #30: 習慣化UX（ストリーク/今日のミッション/通知）
**タイトル**: `[Feature] 習慣化UX機能の実装（ストリーク/今日のミッション/通知）`

**内容**:
- 連続学習日数（ストリーク）の表示と更新
- 今日のミッション（1タップ開始）
- 学習リマインド通知（任意ON/OFF）

**技術要件**:
- `user_stats`テーブル追加
- ストリーク算出ロジック（日付跨ぎ判定）
- `flutter_local_notifications`パッケージ導入
- 通知設定の永続化

**デザイン要件**:
- 進捗画面トップにストリークを大きく表示
- 学習タブの最上部に「今日のミッション」カードを固定
- ミッション達成時の小さな演出（チェック + 軽い振動）
- 学習開始CTAは親指で押しやすい位置（画面下寄り）

**ラベル**: `frontend`, `backend`, `enhancement`, `habit`

**関連ドキュメント**: `docs/HABIT_UX_IMPLEMENTATION.md`

---

### Issue #31: 復習最適化（忘却曲線/ヒント使用率）
**タイトル**: `[Feature] 復習最適化機能の実装（忘却曲線/ヒント使用率ベース）`

**内容**:
- 復習リスト自動生成
- ヒント使用率ベースの優先度付け
- 1日の復習枠（今日の復習）

**技術要件**:
- `user_progress`テーブル拡張（`last_review_at`, `next_review_at`, `stability`, `difficulty`, `review_count`）
- 復習優先度ロジック（ヒント使用率を加味）
- 復習間隔の算出（簡易SR: Spaced Repetition）
- 復習キュー生成ロジック

**デザイン要件**:
- 学習タブの上部に「今日の復習」カード
- 進捗画面に「要復習」セクションを追加
- 復習セッションは通常学習と同じUI/導線で開始

**ラベル**: `frontend`, `backend`, `enhancement`, `review`

**関連ドキュメント**: `docs/REVIEW_OPTIMIZATION_IMPLEMENTATION.md`

---

### Issue #32: 音声機能（再生/録音/発話入力）
**タイトル**: `[Feature] 音声機能の実装（再生/録音/発話入力）`

**内容**:
- 例文音声再生（英語/日本語/ゆっくり）
- 録音 → 自分の発話を再生比較
- 発話入力で次へ進む（任意）

**技術要件**:
- `flutter_tts`パッケージ導入（TTS）
- `record`または`flutter_sound`パッケージ導入（録音）
- `speech_to_text`パッケージ導入（音声認識、任意）
- iOS/Androidのマイク権限設定

**デザイン要件**:
- 学習画面下部に音声操作ボタン配置
- 画像の視認性を損なわない配置
- 再生中はボタンをローディング表示

**ラベル**: `frontend`, `enhancement`, `audio`

**関連ドキュメント**: `docs/AUDIO_SPEAKING_IMPLEMENTATION.md`

---

### Issue #33: シチュエーション連鎖学習（ストーリー型）
**タイトル**: `[Feature] シチュエーション連鎖学習機能の実装（ストーリー型）`

**内容**:
- シーン連鎖ストーリー（例: 空港 → ホテル → レストラン）
- シナリオ単位の進捗管理
- シナリオ完了演出

**技術要件**:
- `scenarios`テーブル追加
- `scenario_steps`テーブル追加
- `user_scenario_progress`テーブル追加
- シナリオ順序管理ロジック

**デザイン要件**:
- シナリオ一覧はカード型で「所要時間/難易度/進捗率」を表示
- 学習モードはシナリオ内の順序で自動遷移
- 完了時に小さな達成演出（バッジ連動可）

**ラベル**: `frontend`, `backend`, `enhancement`, `scenario`

**関連ドキュメント**: `docs/SCENARIO_CHAIN_IMPLEMENTATION.md`

---

### Issue #34: ゲーミフィケーション（バッジ/称号/演出）
**タイトル**: `[Feature] ゲーミフィケーション機能の実装（バッジ/称号/演出）`

**内容**:
- バッジ/称号システム
- 達成演出（学習完了時）
- ポイント/レベル（段階導入）

**技術要件**:
- `achievements`テーブル追加
- `user_achievements`テーブル追加
- 解除判定ロジック（ストリーク、例文数、シナリオ完了、ヒントなし正解など）
- 達成演出のアニメーション実装

**デザイン要件**:
- 進捗画面に「称号/バッジ」セクション
- 学習完了時に小さな演出（1〜2秒）
- 演出は邪魔にならず、すぐ次へ行ける

**ラベル**: `frontend`, `backend`, `enhancement`, `gamification`

**関連ドキュメント**: `docs/GAMIFICATION_IMPLEMENTATION.md`

---

### Issue #35: ナビゲーション/UX洗練（M3/状態保持）
**タイトル**: `[UI/UX] ナビゲーション/UX洗練（Material Design 3/状態保持）`

**内容**:
- M3 `NavigationBar`への統一
- タブ切り替え時の状態保持
- 初期画面の学習優先化

**技術要件**:
- `go_router`の`StatefulShellRoute`採用
- `BottomNavigationBar`から`NavigationBar`への置き換え
- 各タブの状態保持（スクロール位置、フィルタ状態）
- 初期画面を`/study`へリダイレクト

**デザイン要件**:
- メイン4機能は常時表示
- 親指で届く位置に主要CTA
- タブ切替後もスクロール/フィルタ状態を維持

**ラベル**: `frontend`, `ui/ux`, `enhancement`, `navigation`

**関連ドキュメント**: `docs/NAVIGATION_UI_POLISH_IMPLEMENTATION.md`

---

## Issue作成用テンプレート

GitHubでIssueを作成する際は、以下のテンプレートを使用してください：

### 機能追加の場合
```
[Feature] {機能名}

## 概要
{機能の概要}

## 内容
- {項目1}
- {項目2}
- {項目3}

## 技術要件
- {技術要件1}
- {技術要件2}

## デザイン要件
- {デザイン要件1}
- {デザイン要件2}

## 関連ドキュメント
- {ドキュメントパス}

## ラベル
{ラベル1}, {ラベル2}
```

### UI/UX改善の場合
```
[UI/UX] {改善内容}

## 概要
{改善の概要}

## 現在の課題
{現在の問題点}

## 提案する改善内容
{改善内容}

## デザイン要件
{デザイン要件}

## 技術要件
{技術要件}

## 関連ドキュメント
{ドキュメントパス}

## ラベル
{ラベル1}, {ラベル2}
```

## 優先順位まとめ

### 高優先度（Phase 1）
- Issue #1-10
- Issue #26: インテリジェント・ヒント・フェード機能（最重要）⭐

### 中優先度（Phase 2）
- Issue #11-19
- Issue #27: ヒント設定画面
- Issue #28: ヒント使用統計の表示

### 低優先度（Phase 3-4）
- Issue #20-25
- Issue #29: パーソナライズド復習リスト

### 学習体験強化（Phase 5）
- Issue #35: ナビゲーション/UX洗練（基盤整備・最優先）⭐
- Issue #32: 音声機能（独立実装可能）
- Issue #30: 習慣化UX（継続率向上）
- Issue #31: 復習最適化（学習効率最大化）
- Issue #33: シチュエーション連鎖学習（差別化機能）
- Issue #34: ゲーミフィケーション（モチベーション向上）

## 実装順序の推奨

### 基本機能（Phase 1-4）
1. **最初に実装すべき**: Issue #26（インテリジェント・ヒント・フェード機能）
2. **次に実装**: Issue #1-3（単語ページの基本機能）
3. **その後**: Issue #5-7（例文ページの基本機能）
4. **画像機能**: Issue #8-10（画像実装）
5. **UI改善**: Issue #4, #11-16（UI/UX強化）
6. **進捗管理**: Issue #20-25, #28（進捗管理機能）

### 学習体験強化（Phase 5）
詳細は`docs/IMPLEMENTATION_ROADMAP.md`を参照
