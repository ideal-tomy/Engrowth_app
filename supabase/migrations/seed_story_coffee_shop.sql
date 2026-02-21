-- 3分ストーリー: カフェでの注文
-- Engrowthアプリ英単語データ（単語30-155付近）を使用
-- 使用単語例: say, go, know, think, make, time, see, want, come, look, use, way, take, thing, give, work, find, day, tell, help, talk, start, show, hear, bring, sit, learn, understand, read, add, spend, open, remember, buy, wait, serve

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'カフェでの注文',
    'カフェでコーヒーとサンドイッチを注文する自然な会話。日常で使えるフレーズを学べます。',
    3,
    0
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と注文の開始', '店に入り、注文を始める', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '注文の詳細確認', '飲み物と食べ物の詳細を聞く', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '支払いと受け取り', '料金を支払い、商品を受け取る', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お礼と別れ', '感謝を伝えて店を後にする', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hi! Welcome. What would you like today?', 'こんにちは！いらっしゃいませ。本日は何になさいますか？' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Hi! I''d like a coffee, please. And I want to know what you have for food.', 'こんにちは。コーヒーをください。それと、何か食べるものがあるか教えてほしいんです。' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Sure! We have sandwiches and pastries. Many people like our turkey sandwich. Let me show you the menu.', 'かしこまりました。サンドイッチとペストリーがあります。多くのお客様がターキーサンドを気に入られています。メニューをお見せしますね。' FROM conv1
UNION ALL SELECT id, 'A', 4, 'Thank you. I think I''ll take the turkey sandwich. Can you make it to go?', 'ありがとう。ターキーサンドにします。持ち帰りでお願いできますか？' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Of course! So that''s one coffee and one turkey sandwich to go. Give me a minute, I''ll bring it when it''s ready.', '承知しました。コーヒー1つとターキーサンド1つ、持ち帰りですね。少々お待ちください。すぐにお持ちします。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'Actually, can I add a small salad? I want to eat something healthy today.', '実は、小さなサラダを追加できますか？今日は体に良いものを食べたいんです。' FROM conv2
UNION ALL SELECT id, 'B', 2, 'Sure thing! We have a garden salad. It comes with tomatoes and a light dressing. Would you like that?', 'もちろんです。ガーデンサラダがあります。トマトと軽いドレッシングが付きます。いかがですか？' FROM conv2
UNION ALL SELECT id, 'A', 3, 'Yes, that sounds good. How much will that be? I need to know before I pay.', 'はい、それでお願いします。全部でいくらになりますか？支払いの前に知りたいです。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'Let me see... The coffee is three dollars, the sandwich is eight, and the salad is five. So the total is sixteen dollars.', '少々お待ちください。コーヒーが3ドル、サンドイッチが8ドル、サラダが5ドルなので、合計16ドルになります。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'OK, I understand. I''ll pay by card.', 'わかりました。カードで払います。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Here you go. Please use the machine over there. Take your time.', 'こちらです。あちらの機械をお使いください。お急ぎなく。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Thanks. Oh, I remember now—do you have a stamp card? I come here often and I''d like to get one.', 'ありがとう。あ、思い出したんですが、スタンプカードはありますか？よく来るので、欲しいんです。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Yes! We give you one stamp each time you buy a drink. When you get ten stamps, your next drink is free.', 'はい！飲み物を買うたびにスタンプを1つ押します。10個貯まると、次の飲み物が無料になります。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'That''s a nice way to do it. I''ll start today then!', 'それはいいやり方ですね。今日から始めます！' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Great! Here is your order. Your coffee, sandwich, and salad. Enjoy! Find a seat if you want to eat here.', 'ありがとうございます。お客様のご注文です。コーヒー、サンドイッチ、サラダ。召し上がれ。店内でお召し上がりの場合は席をお探しください。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Thank you so much! You really help me learn English. I spend a lot of time here and everyone is so kind.', '本当にありがとうございます。英語を学ぶのにとても助かっています。ここでたくさん時間を過ごしているのですが、皆さん親切なんです。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'That''s nice to hear! We love to serve people from different places. Please come back again.', 'お聞きして嬉しいです。いろんな国の方にお越しいただくのが大好きなんです。またお越しください。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'I will! Have a good day. I hope your work goes well today.', '必ず来ます。良い1日を。今日の仕事がうまくいきますように。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Thanks! You too. See you next time!', 'ありがとうございます。お客様も。またお会いしましょう。' FROM conv4;
