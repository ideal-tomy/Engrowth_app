# 3分英会話ストーリー タスクチェックリスト

Engrowth 1000語を基に、17シチュエーション × 各5本 = **85本** を順次作成します。

## 運用ルール

- **保存先**: 新規SQLは `supabase/migrations/` に保存 → Supabase実行後に `docs/archive/seed_stories/` へ移動
- **雛形**: `docs/archive/seed_stories/seed_story_coffee_shop.sql`
- **生成手順**: 各ストーリーごとに [3MIN_STORY_GENERATION_GUIDE.md](3MIN_STORY_GENERATION_GUIDE.md) の「生成サイクル」に従う

---

## 全体進捗

| 状況 | 完了数 | 残り |
|------|--------|------|
| シチュエーション | 17 / 17 | 0 |
| ストーリー本数 | 85 / 85 | 0 |

---

## シチュエーション別チェックリスト

### 1. greeting_biz（ビジネス挨拶）■完了
- [x] `seed_story_greeting_biz_01.sql` ※アーカイブ済
- [x] `seed_story_greeting_biz_02.sql` ※アーカイブ済
- [x] `seed_story_greeting_biz_03.sql` ※アーカイブ済
- [x] `seed_story_greeting_biz_04.sql` ※アーカイブ済
- [x] `seed_story_greeting_biz_05.sql` ※アーカイブ済

### 2. greeting_student（学生・国際交流挨拶）■完了
- [x] `seed_story_greeting_student_01.sql`
- [x] `seed_story_greeting_student_02.sql`
- [x] `seed_story_greeting_student_03.sql`
- [x] `seed_story_greeting_student_04.sql`
- [x] `seed_story_greeting_student_05.sql`

### 3. selfintro_biz（ビジネス自己紹介）■完了
- [x] `seed_story_selfintro_biz_01.sql`
- [x] `seed_story_selfintro_biz_02.sql`
- [x] `seed_story_selfintro_biz_03.sql`
- [x] `seed_story_selfintro_biz_04.sql`
- [x] `seed_story_selfintro_biz_05.sql`

### 4. selfintro_student（学生・新職場自己紹介）■完了
- [x] `seed_story_selfintro_student_01.sql`
- [x] `seed_story_selfintro_student_02.sql`
- [x] `seed_story_selfintro_student_03.sql`
- [x] `seed_story_selfintro_student_04.sql`
- [x] `seed_story_selfintro_student_05.sql`

### 5. directions（道案内）■完了
- [x] `seed_story_directions_01.sql`
- [x] `seed_story_directions_02.sql`
- [x] `seed_story_directions_03.sql`
- [x] `seed_story_directions_04.sql`
- [x] `seed_story_directions_05.sql`

### 6. flight（飛行機）■完了
- [x] `seed_story_flight_01.sql`
- [x] `seed_story_flight_02.sql`
- [x] `seed_story_flight_03.sql`
- [x] `seed_story_flight_04.sql`
- [x] `seed_story_flight_05.sql`

### 7. hotel（ホテル）■完了
- [x] `seed_story_hotel_01.sql`
- [x] `seed_story_hotel_02.sql`
- [x] `seed_story_hotel_03.sql`
- [x] `seed_story_hotel_04.sql`
- [x] `seed_story_hotel_05.sql`

### 8. cafe（カフェ&レストラン）■完了
- [x] `seed_story_cafe_01.sql`
- [x] `seed_story_cafe_02.sql`
- [x] `seed_story_cafe_03.sql`
- [x] `seed_story_cafe_04.sql`
- [x] `seed_story_cafe_05.sql`

### 9. shopping（ショッピング）■完了
- [x] `seed_story_shopping_01.sql`
- [x] `seed_story_shopping_02.sql`
- [x] `seed_story_shopping_03.sql`
- [x] `seed_story_shopping_04.sql`
- [x] `seed_story_shopping_05.sql`

### 10. transport（交通機関）■完了
- [x] `seed_story_transport_01.sql`
- [x] `seed_story_transport_02.sql`
- [x] `seed_story_transport_03.sql`
- [x] `seed_story_transport_04.sql`
- [x] `seed_story_transport_05.sql`

### 11. business_email（ビジネスメール）■完了
- [x] `seed_story_business_email_01.sql`
- [x] `seed_story_business_email_02.sql`
- [x] `seed_story_business_email_03.sql`
- [x] `seed_story_business_email_04.sql`
- [x] `seed_story_business_email_05.sql`

### 12. presentation1（プレゼン①）■完了
- [x] `seed_story_presentation1_01.sql`
- [x] `seed_story_presentation1_02.sql`
- [x] `seed_story_presentation1_03.sql`
- [x] `seed_story_presentation1_04.sql`
- [x] `seed_story_presentation1_05.sql`

### 13. presentation2（プレゼン②）■完了
- [x] `seed_story_presentation2_01.sql`
- [x] `seed_story_presentation2_02.sql`
- [x] `seed_story_presentation2_03.sql`
- [x] `seed_story_presentation2_04.sql`
- [x] `seed_story_presentation2_05.sql`

### 14. bank（銀行口座開設）■完了
- [x] `seed_story_bank_01.sql`
- [x] `seed_story_bank_02.sql`
- [x] `seed_story_bank_03.sql`
- [x] `seed_story_bank_04.sql`
- [x] `seed_story_bank_05.sql`

### 15. post（郵便局・宅急便）■完了
- [x] `seed_story_post_01.sql`
- [x] `seed_story_post_02.sql`
- [x] `seed_story_post_03.sql`
- [x] `seed_story_post_04.sql`
- [x] `seed_story_post_05.sql`

### 16. hospital（病院）■完了
- [x] `seed_story_hospital_01.sql`
- [x] `seed_story_hospital_02.sql`
- [x] `seed_story_hospital_03.sql`
- [x] `seed_story_hospital_04.sql`
- [x] `seed_story_hospital_05.sql`

### 17. custom（カスタム・学習プラン）■完了
- [x] `seed_story_custom_01.sql`
- [x] `seed_story_custom_02.sql`
- [x] `seed_story_custom_03.sql`
- [x] `seed_story_custom_04.sql`
- [x] `seed_story_custom_05.sql`

---

## 1本あたりの作業手順（くり返し）

| # | 作業 | コマンド例 |
|---|------|------------|
| 1 | プロンプト生成 | `dart run scripts/generate_batch_prompt.dart <situation_id> <story_index>` |
| 2 | CursorでSQL生成 | プロンプトを貼り付け、生成されたSQLを `supabase/migrations/seed_story_<theme>_<nn>.sql` に保存 |
| 3 | 検証 | `dart run scripts/validate_story_batch.dart supabase/migrations/seed_story_<theme>_<nn>.sql` |
| 4 | Supabase投入 | SQL Editor で実行 |
| 5 | 台帳更新 | `dart run scripts/word_allocator.dart <theme> <index> --update <theme>_<nn>` |
| 6 | アーカイブ | 実行済みSQLを `docs/archive/seed_stories/` へ移動（任意） |

---

## 次に着手するタスク

**85本すべて作成済。** Supabase Dashboard の SQL Editor で順に実行して投入してください。
