# 単語マスターリスト（3分英会話生成用）

## ファイル構成

- **words_master_1000.csv**: 1000単語のマスターリスト（テンプレート）
  - カラム: `word`, `meaning`, `part_of_speech`
  - 1行1語。実際の1000語で上書きしてください。

- **words_slot_XXX_YYY.csv**: 50語単位のスロット（任意）
  - 例: `words_slot_001_050.csv` = 1〜50番目の単語
  - 重複を避けるため、AIに渡す際は「このスロットを使って」と指定

## スロット管理

1000語を20スロットに分割:

| スロット | 単語範囲 | 推奨ストーリー数 |
|----------|----------|-------------------|
| 001_050 | 1〜50 | 2〜3本 |
| 051_100 | 51〜100 | 2〜3本 |
| ... | ... | ... |
| 951_1000 | 951〜1000 | 2〜3本 |

1ストーリーあたり10〜15語を使用するため、50語で2〜3本が目安。

## スロットファイルの生成

`scripts/split_words_into_slots.dart` で words_master_1000.csv を50語ずつ分割できます:

```bash
dart run scripts/split_words_into_slots.dart
```

## 使用方法

1. words_master_1000.csv に1000語を登録（DBの words テーブルからエクスポートしても可）
2. Cursorで `@assets/csv/words_master_1000.csv` または `@assets/csv/words_slot_001_050.csv` を指定
3. `@docs/prompts/3min_story_generation_rules.md` を参照してストーリー生成を依頼
