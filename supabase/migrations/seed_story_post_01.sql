-- 3分ストーリー: 郵便局・宅急便（1本目）
-- 使用単語: weapon, employee, cultural, contain, peace
-- theme_slug: post | situation_type: student | theme: 郵便局・宅急便

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '小包を送る',
    '郵便局で小包を海外に送る手続きを職員に相談する会話。',
    3,
    71
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '窓口へ', '送り方の相談', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金の確認', '重量と送料', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '梱包', '制限の説明', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '発送完了', '追跡番号', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I need to send a package. To Japan. Cultural items. Gifts. For family. Peace of mind. They arrive. Safe. No weapon. Nothing dangerous. Just. Books. Snacks.', 'こんにちは。小包を送りたい。日本へ。文化的な品。ギフト。家族に。安心。届く。安全。武器なし。危ないものなし。本と。お菓子だけ。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. Employee. Here. Can help. Package. To Japan. Contain. What? Cultural. Items. OK. Weapon. Prohibited. Peace. Of. Course. We. Handle. Carefully.', 'ようこそ。従業員。ここに。手伝える。小包。日本へ。含む。何？文化的な品。OK。武器。禁止。平和。もちろん。慎重に扱う。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Box. Contain. Books. Two. Japanese. Cultural. Study. Snacks. Traditional. Tea. Peace. Gift. For. Mother. Employee. Check? Allowed?', '箱。含む。本。2册。日本語。文化的。勉強。お菓子。伝統的。お茶。平和。贈り物。母に。従業員。チェック？許可？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Books. Snacks. Tea. Cultural. All OK. Contain. No. Liquid. Over. Limit? Peace. No. Problem. Weapon. None. Good. Employee. Will. Weigh. Now.', '本。お菓子。お茶。文化的。すべてOK。含む。液体なし。制限超え？平和。問題なし。武器。なし。いい。従業員。計る。今。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Weight? Limit? Cultural. Books. Heavy. Maybe. Contain. Five. Or. Six. Peace. Hope. Not. Too. Much. Cost.', '重量？制限？文化的。本。重い。かも。含む。5または6。平和。望む。あまり。多くなりすぎない。コスト。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Two. Kilos. Employee. Scale. Contain. Weight. OK. Standard. Peace. Price. Forty. Dollars. Surface. Sixty. Air. Cultural. Items. No. Extra. Fee.', '2キロ。従業員。 scale。含む。重量。OK。標準。平和。料金。40ドル。船便。60。航空。文化的な品。追加料金なし。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Forty. Surface. Slow? Peace. Patience. Sixty. Air. Fast? Employee. Recommend? Cultural. Tea. Fresh. Date?', '40。船便。遅い？平和。忍耐。60。航空。速い？従業員。勧める？文化的。お茶。鮮度？日付？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Air. Better. Snacks. Tea. Cultural. Items. Fresh. Contain. Quality. Peace. Of. Mind. Employee. Suggests. Sixty. Worth. It.', '航空。 better。お菓子。お茶。文化的な品。新鮮。含む。品質。安心。従業員。提案。60。価値ある。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Air. Sixty. Contain. Tracking? Peace. Know. Where. Package? Employee. Include?', '航空。60。含む。追跡？平和。知る。どこ。小包？従業員。含む？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Tracking. Free. Contain. In. Price. Peace. Of. Mind. Cultural. Gift. Safe. Employee. Ensure. No. Weapon. Policy. Strict.', 'はい。追跡。無料。含む。料金に。安心。文化的。赠り物。安全。従業員。保証。武器なし。ポリシー。厳格。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Form? Contain. Address? Japan. Write. Peace. Roman. Letters? Or. Japanese? Cultural. Preference?', '用紙？含む。住所？日本。書く。平和。ローマ字？日本語？文化的。好み？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Both. Best. Employee. Advice. Contain. Japanese. Address. For. Local. Post. Peace. Roman. For. Customs. Cultural. Clarity. No. Confusion.', '両方。ベスト。従業員。アドバイス。含む。日本語住所。現地郵便用。平和。ローマ字。税関用。文化的。明確さ。混乱なし。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Customs. Form. Contain. Content? List? Cultural. Items. Books. Snacks. Tea. Peace. Declare. Value? Employee?', '税関。用紙。含む。内容？リスト？文化的な品。本。お菓子。お茶。平和。申告。価値？従業員？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Declare. Value. Contain. Honest. Amount. Peace. No. Trouble. Cultural. Gifts. Usually. Low. Value. OK. Employee. Helps. Fill.', 'はい。申告。価値。含む。正直な金額。平和。問題なし。文化的。贈り物。通常。低い価値。OK。従業員。手伝う。記入。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. Employee. Patient. Cultural. Bridge. Peace. Between. Countries. Contain. Love. In. Package. Good.', 'ありがとう。従業員。忍耐強い。文化的。架け橋。平和。国の間。含む。愛。小包に。いい。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Here. Receipt. Contain. Tracking. Number. Peace. Check. Online. Cultural. Gift. On. Way. Employee. Wish. Safe. Journey. No. Weapon. Worry.', 'これ。領収書。含む。追跡番号。平和。チェック。オンライン。文化的。赠り物。途中。従業員。祈る。安全な旅。武器。心配なし。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Peace. Thank you. Cultural. Exchange. Contain. Joy. Employee. Help. Big. Mother. Happy. Japan. Good.', '平和。ありがとう。文化交流。含む。喜び。従業員。助け。大きい。母。嬉しい。日本。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Peace. Package. Contain. Care. Employee. Pack. Cultural. Items. Safe. Bye.', 'どういたしまして。平和。小包。含む。心遣い。従業員。梱包。文化的な品。安全。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Peace. Employee. Kind. Cultural. Understanding. Contain. Gratitude. Thank you.', 'バイバイ。平和。従業員。親切。文化的。理解。含む。感謝。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care. Good day.', 'バイバイ。お気をつけて。よい一日を。' FROM conv4;
