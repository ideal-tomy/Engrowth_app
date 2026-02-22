-- 3分ストーリー: ホテルのルームサービス
-- Engrowthアプリ英単語データ（単語201-250）を使用
-- 使用単語例: company, question, night, number, point, home, room, mother, area, money, story, fact, month, right, study, book, eye, job, word, business

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ホテルのルームサービス',
    'ホテルでルームサービスを注文する会話。電話での注文や要望の伝え方を学べます。',
    3,
    5
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '注文の電話', 'ルームサービスに電話する', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'メニューの確認', '食事の内容や時間を確認する', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '配達と支払い', 'ルームサービスが届き料金を支払う', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'トラブルの対応', '注文の誤りを伝え対応を依頼する', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hello? Room service? I''d like to order dinner. What''s the number to dial?', 'もしもし。ルームサービスですか？夕食を注文したいです。ダイアルする番号は何ですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'You have the right number. This is room service. How can I help you?', '正しい番号です。ルームサービスでございます。ご用件を承ります。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'I have a question. Can I order food to my room? I''m in room 405. My mother is with me and she can''t go down.', '質問があります。部屋に食事を届けてもらえますか？405号室です。母が一緒で階段を降りられないんです。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Of course. We serve all our rooms. What would you like? I have the menu here.', 'もちろんです。全室に対応しております。何になさいますか？メニューをお持ちしております。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Let me look at the book in my room. One moment... I want two salads and pasta. Is that OK?', '部屋のメニューを見ます。少々... サラダ2つとパスタをお願いします。大丈夫ですか？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Yes, that''s fine. Any drinks? We have water, juice, and wine. The wine costs extra.', 'はい、結構です。お飲み物は？水、ジュース、ワインがあります。ワインは追加料金です。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Just water, please. So, the main point—how long will it take? I have a business call at eight.', '水だけお願いします。で、肝心なのですが—どのくらいかかりますか？8時に仕事の電話があるんです。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'About thirty minutes. We''ll have it to your room before eight. What''s the story with the pasta—tomato or cream?', '30分ほどです。8時前にご部屋へお届けします。パスタはトマトソースとクリーム、どちらでしょうか。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Cream, please. In fact, make it two cream pastas. Same for both of us. How much money will that be?', 'クリームで。実際にはクリームパスタを2つで。二人とも同じ。いくらになりますか？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Let me calculate... Two salads, two pastas, two waters. The total is forty-five dollars. You can pay when we deliver.', '計算します... サラダ2、パスタ2、水2。合計45ドルです。お届け時にお支払いいただけます。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Room service! Here is your order.', 'ルームサービスです。ご注文のお届けです。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Come in, please. Where should I put this? Oh, on the table. Got it.', 'どうぞお入りください。これはどこに置けば？あ、テーブルですね。わかりました。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Yes. I need you to sign here. You can add a tip if you like. Many guests do.', 'はい。ここにサインをお願いします。チップを追加しても結構です。多くのお客様がそうなさいます。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'OK. I''ll study the bill... Everything looks right. Here you go. Thank you. Have a good night!', 'わかりました。伝票を確認します... 問題なさそうです。はい。ありがとう。良い夜を。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Thank you, sir. Enjoy your meal. Call us if you need anything. We work all night.', 'ありがとうございます。ごゆっくりどうぞ。何か必要でしたらお電話ください。夜通し稼働しております。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Excuse me, I need to call again. There''s an issue with the order. One pasta is wrong.', 'すみません、また電話したいです。注文に問題がありました。パスタが1つ違います。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'I''m sorry to hear that. What''s wrong? We''ll fix it right away. Our company takes these things seriously.', '申し訳ございません。どのように違いますか？すぐに直します。当社ではこういったことには真摯に対応しております。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'We asked for cream but one has tomato. My mother can''t eat tomato. She has an allergy. It''s a health issue.', 'クリームを頼んだのに1つがトマトなんです。母はトマトが食べられません。アレルギーがあります。健康上の問題です。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'I understand. We''ll bring the right one in fifteen minutes. No extra charge. I''m sorry for the trouble. Is there anything else in the area we can help with?', '承知しました。15分以内に正しいものをお届けします。追加料金はいただきません。ご不便をおかけして申し訳ございません。他にご用件はございますか？' FROM conv4
UNION ALL SELECT id, 'A', 5, 'No, that''s all. Thank you for your quick response. We appreciate good service. We''ve stayed here every month for a year.', 'いいえ、それだけです。迅速な対応ありがとうございます。良いサービスは感謝します。1年、毎月ここに泊まっているんです。' FROM conv4;
