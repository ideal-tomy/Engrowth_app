# シナリオ学習ページ 実装計画書

## 1. 概要

「シナリオ学習」ページは、カフェ・ホテル・空港などのシチュエーション別に会話シーンを一覧表示し、タップで会話学習画面へ遷移するハブ画面である。将来的にシナリオ・シーンの増加を見据えた拡張性と、優れたUI事例に基づく魅力的なデザインを実現する。

---

## 2. レイアウト方式の比較と推奨

### 2.1 候補の比較

| 方式 | メリット | デメリット | 採用事例 |
|------|----------|------------|----------|
| **3カラムグリッド** | 多くのカードを一覧できる、情報密度が高い | スマホではカードが小さくなる、横長コンテンツに不向き | Pinterest, Instagram |
| **横スクロール（Netflix型）** | 没入感、発見の喜び、高級感、サムネイルを大きく見せられる | 奥のコンテンツが埋もれやすい | Netflix, Rakuten, Disney+ |
| **カルーセルスライダー** | 1つにフォーカス、スナップで操作が明確 | 1枚ずつしか見えない、比較がしづらい | アプリオンボーディング、チュートリアル |

### 2.2 推奨: **セクション + 横スクロール行（Netflix型）**

**採用理由**
1. **カテゴリ構造との相性**: カフェ／ホテル／空港という「シナリオ別」のグルーピングと、Netflix の「ジャンル別横スクロール行」が一致
2. **UX ガイドラインとの整合**: NN/G の「横スクロールは関連する同質コンテンツのサブセットに適する」に合致
3. **発見のしやすさ**: 次のカードが画面端に「のぞいて見える（peek）」ことで、「さらにスワイプできる」ことが直感的に伝わる
4. **高級感・統一感**: UI_DESIGN_PLAN_V2 の「魅力的で統一感のあるUI」に沿う
5. **学習アプリとの親和性**: Duolingo や Babbel もコース選択でカテゴリ＋カード形式を採用

**レイアウトイメージ**
```
┌─────────────────────────────────────┐
│ シナリオ学習              [アカウント]│
├─────────────────────────────────────┤
│ カフェ                               │
│ ┌────┐ ┌────┐ ┌────┐ ┌──   ← 横スクロール
│ │ 📷 │ │ 📷 │ │ 📷 │ │    （次のカードがのぞく）
│ │    │ │    │ │    │ │
│ │注文│ │支払│ │... │ │
│ └────┘ └────┘ └────┘ └──
│                                     │
│ ホテル                               │
│ ┌────┐ ┌────┐ ┌──
│ │ 📷 │ │ 📷 │ │
│ │    │ │    │ │
│ │CHI │ │... │ │
│ └────┘ └────┘ └──
│                                     │
│ 空港                                 │
│ ┌────┐ ┌──  （準備中 or カード1枚）
│ │ 📷 │ │
│ └────┘ └──
└─────────────────────────────────────┘
```

---

## 3. 他アプリの優れたUI要素の取り込み

### 3.1 Netflix / Rakuten / Disney+
- セクションごとの横スクロール行
- 端に次のカードを少し見せる（peek）ことでスワイプのヒント
- サムネイルを大きく（縦長）使い、情景が伝わるデザイン
- 軽いスナップで操作しやすくする

### 3.2 Duolingo / Babbel
- 進捗（例: ○/●）をカード上に表示
- 親しみやすいイラストやアイコン
- カテゴリごとの色分け（Engrowth テーマカラーで統一）

### 3.3 カラオケまねきねこ
- シンプルで分かりやすいアイコン
- 迷いのないタップで進むフロー

---

## 4. UI 設計方針（UI_DESIGN_PLAN_V2 との整合）

| 要素 | 方針 |
|------|------|
| カラー | プライマリ #d30306、背景 #f5f5f5（EngrowthTheme を使用） |
| カード | 角丸 12px、白背景、軽いシャドウ |
| セクションタイトル | 太字、適切な余白（8px ベース） |
| タップ | 軽いスケール＋触覚フィードバック |
| サムネイル | 16:9 または 4:3、fit: cover |

---

## 5. データ構造・ナビゲーション

### 5.1 シナリオカテゴリの定義

| カテゴリID | 表示名 | 会話 theme との対応例 |
|------------|--------|------------------------|
| cafe | カフェ | カフェ・レストラン、レストラン、カフェ |
| hotel | ホテル | ホテル |
| airport | 空港 | 空港 |

- `conversations.theme` をカテゴリにマッピングしてグルーピング
- 将来、DB に `scenario_category` を追加してもよい

### 5.2 フロー

1. **シナリオ学習ページ** (`/scenario-learning` 新規)
   - カフェ／ホテル／空港のセクション
   - 各セクションは横スクロールの会話カード行
2. **カードタップ** → `/conversation/:id?mode=listen`（会話学習画面へ直接遷移）

### 5.3 既存ルートとの関係

- `/scenarios` … 例文ベースのシナリオ学習（ScenarioListScreen）
- `/conversations` … 学生/ビジネスコース別の会話一覧
- **`/scenario-learning`** … **シナリオ別会話ハブ**（本計画で新規作成）

---

## 6. 実装計画

### Phase 1: 基盤（1〜2日）

1. **ルート追加**
   - `router.dart` に `/scenario-learning` を追加
   - 学習モードの「シナリオ学習」ボタンの遷移先を `/scenario-learning` に変更（または両方表示）

2. **シナリオカテゴリの定義**
   - `lib/constants/scenario_categories.dart` を作成
   - カテゴリID、表示名、theme マッピングを定義

3. **Provider 拡張**
   - カテゴリ別に会話を取得する Provider を追加
   - 例: `conversationsByCategoryProvider(categoryId)`

### Phase 2: 画面実装（2〜3日）

4. **ScenarioLearningScreen 作成**
   - `lib/screens/scenario_learning_screen.dart`
   - 縦スクロールの `ListView` 内に、セクションごとに `SingleChildScrollView` で横スクロール行を配置

5. **ScenarioSectionCard ウィジェット**
   - セクションタイトル + 横スクロールの会話カード
   - カード: サムネイル、タイトル、進捗（オプション）
   - 端のカードが少し見えるよう `padding` で調整

6. **スナップ・スクロール**
   - `ListView.builder` の `scrollDirection: Axis.horizontal` に `physics: BouncingScrollPhysics()` などで自然な動き
   - カード幅を固定して `PageScrollPhysics` 相当のスナップ（オプション）

### Phase 3: デザイン仕上げ（1日）

7. **Engrowth テーマ適用**
   - AppBar、セクションタイトル、カードに EngrowthColors を適用
   - 空セクションの「準備中」表示

8. **アニメーション・フィードバック**
   - カードタップ時のスケールアニメーション
   - `HapticFeedback.selectionClick()` など

9. **空状態**
   - カテゴリに会話が0件のときの「準備中」メッセージ

### Phase 4: 拡張（将来）

10. 進捗表示（会話ごとの学習完了率）
11. 「おすすめ」セクション（学習履歴に基づく）
12. カルーセルのスナップ調整（`carousel_slider` パッケージ等の検討）

---

## 7. 技術メモ

### 7.1 横スクロールの実装例（Flutter）

```dart
SizedBox(
  height: 180,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: conversations.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: ScenarioConversationCard(conversation: conversations[index]),
      );
    },
  ),
)
```

### 7.2 カテゴリ別取得

- 現状: `theme` でフィルタ → クライアント側でカテゴリにグルーピング
- 将来: `scenario_category` カラムを追加して DB 側でフィルタ

---

## 8. 関連ドキュメント

- [UI_DESIGN_PLAN_V2.md](./UI_DESIGN_PLAN_V2.md) - 全体UI計画
- [VOICE_FIRST_CONVERSATION_DESIGN.md](./VOICE_FIRST_CONVERSATION_DESIGN.md) - 会話学習設計
