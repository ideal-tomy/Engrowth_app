# ドキュメント矛盾点レポート

## 発見された矛盾点

### 1. ヒントタイミングの矛盾

#### 矛盾内容
初期ヒントの表示タイミングが複数のドキュメントで異なっています。

#### 矛盾箇所

**ファイル1: `docs/LEARNING_MODE_DESIGN.md`**
- **行69**: `Phase 1: 初期ヒント（3秒後）`
- **行92**: `initial,     // 初期ヒント（3秒）`
- **行125**: `ヒント表示までの時間: 2秒 / 5秒 / 10秒 / カスタム`（設定画面の説明）
- **行136**: `○ 2秒  ○ 5秒  ● 10秒  ○ カスタム`（設定画面のUI例、デフォルトは10秒）

**ファイル2: `docs/LEARNING_MODE_QUICK_START.md`**
- **行51**: `初期ヒント（2秒後）`
- **行144**: `2秒後: 最初の1文字が表示されることを確認`

**ファイル3: `docs/DATABASE_SCHEMA_EXTENSION.md`**
- **行53**: `initial_hint_delay_seconds INTEGER DEFAULT 2,  -- 初期ヒントまでの秒数`

**ファイル4: `docs/ALL_ISSUES_LIST.md`**
- **行160**: `2秒（カスタマイズ可能）詰まったらヒントがフェードイン`

**ファイル5: `docs/INITIAL_ISSUES_DETAILED.md`**
- **行540**: `2秒（カスタマイズ可能）詰まったらヒントがフェードイン`
- **行575**: `ヒント表示までの時間設定（2秒/5秒/10秒/カスタム）`

**ファイル6: `docs/PROGRESS_DESIGN.md`**
- **行176**: `initial,     // 初期ヒント（3秒）`

#### 推奨解決策
**統一値: 3秒（カスタマイズ可能）**

理由：
- `LEARNING_MODE_DESIGN.md`が最も詳細な設計ドキュメント
- 脳科学的根拠として「2秒の沈黙」が記載されているが、実際のヒント表示は3秒後が適切
- データベースのデフォルト値は2秒だが、これは「カスタマイズ可能」の最小値として扱う

**修正が必要なファイル**:
1. `docs/LEARNING_MODE_QUICK_START.md`: 2秒 → 3秒に変更
2. `docs/DATABASE_SCHEMA_EXTENSION.md`: デフォルト値を2秒のまま（カスタマイズ可能な最小値として）または3秒に変更
3. `docs/PROGRESS_DESIGN.md`: コメントは3秒のまま（正しい）

---

### 2. ストリーク管理の矛盾

#### 矛盾内容
連続学習日数（ストリーク）の管理方法が2つのアプローチで記載されています。

#### 矛盾箇所

**ファイル1: `docs/HABIT_UX_IMPLEMENTATION.md`**
- **行20-27**: `user_stats`テーブル（新規）を作成
  - `streak_count` (int)
  - `last_study_date` (date)
  - `daily_goal_count` (int)
  - `daily_done_count` (int)

**ファイル2: `docs/PROGRESS_DESIGN.md`**
- **行187**: `LearningStats`クラスに`consecutiveDays`フィールド
- **行250-254**: ストリーク表示の説明（`LearningStats`から取得）

#### 推奨解決策
**統一アプローチ: `user_stats`テーブル + `LearningStats`クラス**

理由：
- `user_stats`テーブルでデータを永続化
- `LearningStats`クラスは`user_stats`から計算された統計情報を保持するビューモデルとして使用

**修正が必要なファイル**:
1. `docs/PROGRESS_DESIGN.md`: `LearningStats`クラスの`consecutiveDays`は`user_stats`テーブルから取得することを明記

---

### 3. 画像URL生成方法の記載（矛盾ではない）

#### 確認内容
画像URL生成について、2つの方法が記載されていますが、これは矛盾ではなく、両方の方法をサポートしている設計です。

**方法A: 個別IDベース**
- `{sentence_id}/medium.jpg`形式
- `IMAGE_IMPLEMENTATION.md`に記載

**方法B: Group名ベース**
- `{group}.png`形式
- `IMAGE_UPLOAD_GUIDE.md`、`IMAGE_DISPLAY_TEST.md`に記載

#### 結論
矛盾ではありません。両方の方法をサポートする設計として問題ありません。

---

## 修正推奨事項

### 優先度: 高

1. **ヒントタイミングの統一**
   - デフォルト値を3秒に統一
   - カスタマイズ可能な範囲: 2秒〜10秒

2. **ストリーク管理の明確化**
   - `user_stats`テーブルでデータ永続化
   - `LearningStats`は計算結果を保持するビューモデルとして使用

### 優先度: 中

3. **用語の統一**
   - `ImageURL` vs `image_url`（大文字小文字の統一）
   - `Group` vs `group`（大文字小文字の統一）

---

## 完了したファイルの移動

以下のファイルは実装完了後、参考として不要になった可能性があります：

1. `docs/LEARNING_MODE_QUICK_START.md` - 実装完了後のクイックスタートガイド
2. `docs/IMAGE_UPLOAD_QUICK_START.md` - 実装完了後のクイックスタートガイド
3. `docs/IMAGE_DISPLAY_TEST.md` - 実装完了後のテスト手順

これらを`docs/completed/`フォルダに移動しました。
