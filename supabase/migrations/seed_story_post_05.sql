-- 3分ストーリー: 郵便局・宅急便（5本目）
-- 使用単語: treat, trip, evening
-- theme_slug: post | situation_type: student | theme: 郵便局・宅急便

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '宅配の集荷を依頼する',
    '自宅から荷物を発送するため、集荷を宅配業者に依頼する会話。',
    3,
    75
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '集荷の依頼', '電話で', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '日時の指定', '都合の良い時間', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '梱包の確認', '準備すること', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認', 'お礼', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need a pickup for my package. It is too big. The trip to the post office would be hard. Can you treat me with home collection? Is evening possible?', 'こんにちは。小包の集荷が必要。大きすぎる。郵便局への旅は大変。自宅集荷で扱える？夕方は可能？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. Pickup is available. We treat our customers well. The trip saves you time. We have an evening slot from 5 to 7. Good? We treat it free if over five kilos.', 'はい。集荷は利用可能。顧客をよく扱う。旅を節約。5時から7時の夕方枠。いい？5キロ以上は無料で扱う。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Evening 5 to 7. You treat me perfect. My trip to class is until 4. So I have time to pack after. Good.', '夕方5時から7時。完璧に扱う。授業への旅は4時まで。梱包する時間がある。いい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'What is your address? I need to treat this as confirmation. Same as your account? Our evening driver will come. Please treat the package as ready.', '住所は？確認として扱う必要。アカウントと同じ？夕方ドライバーが来る。小包を準備として扱って。' FROM conv1
UNION ALL SELECT id, 'A', 5, '123 Main Street. Treat it as apartment 4B. Trip up the stairs. Evening. Will the driver ring? Can you treat me with help? The box is heavy.', '123メイン通り。アパート4Bとして扱う。階段を上る旅。夕方。ドライバーは鳴らす？助けで扱える？箱は重い。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'The driver will ring at your door in the evening. If you need help with the trip down, we treat heavy packages OK. Help is part of our service.', 'ドライバーは夕方ドアを鳴らす。下りる旅で助けが必要なら、重い荷物を扱うOK。助けはサービスの一部。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Thank you. You treat me well. The trip stress is less. Evening pickup is convenient. You treat students right. Student life good.', 'ありがとう。よく扱う。旅のストレスは少ない。夕方集荷は便利。学生を正しく扱う。学生生活いい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Tomorrow evening 5 to 7. I treat it as confirmed. Trip is ready. Pack well. Treat fragile items. Mark the box. Our evening driver will take care. Good.', '明日夕方5時から7時。確認済みとして扱う。旅は準備。よく梱包。壊れ物を扱う。箱にマーク。夕方ドライバーがケア。いい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Fragile mark. I will treat it. I will do that. There are books inside the trip. I treat them carefully. Evening. Thanks. Good.', '壊れ物マーク。そう扱う。そうする。旅の中に本がある。慎重に扱う。夕方。ありがとう。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Goodbye. We treat evening tomorrow. Trip should be smooth. Good day.', 'バイバイ。明日の夕方を扱う。旅はスムーズに。よい一日を。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Goodbye. You treat the service and trip as excellent. The evening slot was perfect. Thank you.', 'バイバイ。サービスと旅を素晴らしく扱う。夕方の枠は完璧。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'You are welcome. We treat our customers well. The trip to the post office. We always offer the evening option. We treat students right. We know you are busy. Good.', 'どういたしまして。顧客をよく扱う。郵便局への旅。夕方オプションはいつも。学生を正しく扱う。忙しいとわかる。いい。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'You treat me great. I will trip home now. Evening. I pack now. I treat it as ready for tomorrow. Good.', 'すごく扱う。今家への旅。夕方。梱包する。明日の準備として扱う。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Goodbye. We treat with care. Your trip and package. Our evening driver is professional. We treat it well. Good.', 'バイバイ。ケアで扱う。あなたの旅と小包。夕方ドライバーはプロ。よく扱う。いい。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. I treat my thanks. The trip saved me. Evening was convenient. I appreciate how you treat customers. Good day.', 'バイバイ。感謝を扱う。旅を節約した。夕方は便利だった。顧客を扱う方法に感謝。よい一日を。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. We treat your success. Your trip and package. Evening pickup. We treat it smooth. Good luck.', 'バイバイ。成功を扱う。あなたの旅と小包。夕方集荷。スムーズに扱う。頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. You treat me well. The trip is complete. Evening tomorrow. I treat myself as ready. Thank you.', 'バイバイ。うまく扱う。旅は完了。明日の夕方。準備として自分を扱う。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Take care. Good evening to you.', 'バイバイ。お気をつけて。よい夕方を。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good evening. Same treat. I trip home now. Bye.', 'よい夕方を。同じ扱い。今家への旅。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good night.', 'バイバイ。おやすみなさい。' FROM conv4;
