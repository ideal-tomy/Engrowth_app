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

## 実装順序の推奨

1. **最初に実装すべき**: Issue #26（インテリジェント・ヒント・フェード機能）
2. **次に実装**: Issue #1-3（単語ページの基本機能）
3. **その後**: Issue #5-7（例文ページの基本機能）
4. **画像機能**: Issue #8-10（画像実装）
5. **UI改善**: Issue #4, #11-16（UI/UX強化）
6. **進捗管理**: Issue #20-25, #28（進捗管理機能）
