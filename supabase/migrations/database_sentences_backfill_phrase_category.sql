-- 既存 sentences の phrase_title / category_label_ja を初期バックフィル
-- dialogue_en, dialogue_jp, category_tag から自動振り分け
-- database_sentences_phrase_title_category.sql 実行後に実行

-- category_label_ja: category_tag を日本語ラベルに正規化
-- phrase_title: dialogue_en の冒頭パターンからネイティブ言い回しタイトルを抽出
UPDATE sentences s
SET
  category_label_ja = COALESCE(
    CASE
      -- 既に日本語のタグ（接客系）
      WHEN s.category_tag ILIKE '接客%' THEN '接客'
      WHEN s.category_tag ILIKE '%道%' OR s.category_tag ILIKE '%尋ね%' OR s.category_tag IN ('道を尋ねる', 'Directions', 'directions', 'Direction', 'direction') THEN '道案内'
      WHEN s.category_tag ILIKE '%買い物%' OR s.category_tag IN ('Shopping', 'shopping', 'SHOPPING') THEN '買い物'
      WHEN s.category_tag ILIKE '%挨拶%' OR s.category_tag IN ('Greetings', 'greetings') THEN '挨拶'
      WHEN s.category_tag ILIKE '%レストラン%' OR s.category_tag ILIKE '%カフェ%' OR s.category_tag IN ('Restaurant', 'restaurant', 'Cafe', 'cafe', 'Food', 'food') THEN 'レストラン・カフェ'
      WHEN s.category_tag ILIKE '%旅行%' OR s.category_tag IN ('Travel', 'travel', 'Adventure', 'adventure') THEN '旅行'
      WHEN s.category_tag ILIKE '%ビジネス%' OR s.category_tag IN ('Business', 'business') THEN 'ビジネス'
      WHEN s.category_tag ILIKE '%家族%' OR s.category_tag IN ('Family', 'family') THEN '家族'
      WHEN s.category_tag ILIKE '%教育%' OR s.category_tag IN ('Education', 'education') THEN '教育'
      WHEN s.category_tag ILIKE '%健康%' OR s.category_tag IN ('Health', 'health') THEN '健康・病院'
      WHEN s.category_tag ILIKE '%ホテル%' OR s.category_tag IN ('Hotel', 'hotel') THEN 'ホテル'
      WHEN s.category_tag ILIKE '%交通%' OR s.category_tag IN ('Transport', 'transport') THEN '交通・乗り物'
      WHEN s.category_tag ILIKE '%芸術%' OR s.category_tag IN ('Art', 'art') THEN '芸術'
      WHEN s.category_tag ILIKE '%友達%' OR s.category_tag IN ('Friends', 'friends') THEN '友達・交流'
      WHEN s.category_tag ILIKE '%人間関係%' OR s.category_tag IN ('Relationship', 'relationship') THEN '人間関係'
      WHEN s.category_tag ILIKE '%生活%' OR s.category_tag IN ('Life', 'life') THEN '生活'
      WHEN s.category_tag ILIKE '%イベント%' OR s.category_tag IN ('Event', 'event') THEN 'イベント'
      WHEN s.category_tag ILIKE '%社会%' OR s.category_tag IN ('Society', 'society') THEN '社会'
      WHEN s.category_tag ILIKE '%アウトドア%' OR s.category_tag IN ('Outdoor', 'outdoor') THEN 'アウトドア'
      WHEN s.category_tag ILIKE '%テクノロジー%' OR s.category_tag IN ('Technology', 'technology') THEN 'テクノロジー'
      WHEN s.category_tag ILIKE '%歴史%' OR s.category_tag IN ('History', 'history') THEN '歴史'
      WHEN s.category_tag ILIKE '%緊急%' OR s.category_tag IN ('Emergency', 'emergency') THEN '緊急・トラブル'
      WHEN s.category_tag IS NOT NULL AND TRIM(s.category_tag) != '' THEN TRIM(s.category_tag)
      ELSE 'その他'
    END,
    'その他'
  ),
  phrase_title = COALESCE(
    CASE
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'can i have%' THEN 'Can I have ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'would you like%' THEN 'Would you like ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'could you tell me%' THEN 'Could you tell me ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'excuse me, where%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'excuse me. where%' THEN 'Excuse me, where is ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'where is%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'where''s %' THEN 'Where is ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'how do i get%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'how can i get%' THEN 'How do I get to ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'i''d like%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'i would like%' THEN 'I''d like ...'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'i want%' THEN 'I want ...'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'can i help you%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'may i help you%' THEN 'Can I help you ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'of course%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'sure%' THEN 'Of course. / Sure.'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'yes please%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'yes, please%' THEN 'Yes, please.'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'is this the right way%' THEN 'Is this the right way to ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'which way%' THEN 'Which way ...?'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'hello%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'hi %' OR LOWER(COALESCE(s.dialogue_en, '')) = 'hi' THEN 'Hello. / Hi.'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'thank you%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'thanks%' THEN 'Thank you. / Thanks.'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'goodbye%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'bye%' THEN 'Goodbye. / Bye.'
      WHEN LOWER(COALESCE(s.dialogue_en, '')) LIKE 'sorry%' OR LOWER(COALESCE(s.dialogue_en, '')) LIKE 'excuse me%' THEN 'Sorry. / Excuse me.'
      ELSE NULL
    END,
    LEFT(TRIM(COALESCE(s.dialogue_en, '')), 40)
  )
WHERE s.phrase_title IS NULL OR s.category_label_ja IS NULL
   OR s.phrase_title = '' OR s.category_label_ja = '';
