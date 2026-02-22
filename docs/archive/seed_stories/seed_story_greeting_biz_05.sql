-- 3分ストーリー: 研修初日の挨拶
-- 使用単語: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay
-- theme_slug: greeting_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '研修初日の挨拶',
    '新人研修の初日、同じグループの人たちと挨拶。休憩室でコーヒーを取りながら自己紹介を交わす。',
    3,
    5
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '研修室で出会う', '朝、研修室に入り隣の席の人と挨拶', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '休憩室へ', 'コーヒーブレイクで自己紹介', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '飲み物と軽食の注文', 'メニューを見て注文する', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '席に戻る前の会計', '支払いを済ませ、午後の研修に向かう', 'business', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hello! Is this seat free? I''m new to the training program too.', 'こんにちは！この席は空いていますか？私も研修プログラムの新人なんです。' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Hello! Yes, please sit down. Welcome! I just got here myself. I''m glad we can sit together.', 'こんにちは！はい、どうぞお座りください。ようこそ！私も今着いたところです。隣り合わせで嬉しいです。' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Thank you. I was nervous about today. It''s nice to meet someone friendly. Do you want coffee or water during the break?', 'ありがとうございます。今日は緊張していました。親切な人に会えて嬉しいです。休憩中にコーヒーかお水は飲みますか？' FROM conv1
UNION ALL SELECT id, 'A', 4, 'Coffee, please. I''ll need it. They said there''s a cafe. Can we order from there?', 'コーヒーをお願いします。必要なんです。カフェがあるそうです。そこで注文できますか？' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Yes. They have a full menu. I heard the sandwiches are good. We can go together when the break starts.', 'はい。フルメニューがあります。サンドイッチがおいしいそうです。休憩が始まったら一緒に行きましょう。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'Great. Thank you. So, what department are you in? I''d love to know more about everyone here.', 'いいですね。ありがとう。で、どの部署ですか？皆さんのことにもっと知りたいです。' FROM conv2
UNION ALL SELECT id, 'B', 2, 'I''m in sales. I started last month. Welcome to the company! I think we''ll have a good training together.', '営業です。先月入ったばかりです。会社へようこそ！一緒にいい研修になりそうです。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'Thank you. I''m in tech. I hope we can help each other. Shall we go get coffee now?', 'ありがとうございます。私は技術部門です。お互い助け合えるといいですね。今コーヒーを取りに行きましょうか？' FROM conv2
UNION ALL SELECT id, 'B', 4, 'Yes, please. Let me show you the way. I already know where the menu is. We can order and pay at the counter.', 'はい、行きましょう。案内します。メニューのある場所はもう知っています。カウンターで注文して払えます。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'Perfect. Thank you. I''ll get the bill for both of us. Consider it a thank you for the welcome.', '完璧です。ありがとう。2人分私が払います。歓迎してくれたお礼として。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Here''s the menu. They have coffee, water, and lots of sandwiches. What would you like?', 'メニューです。コーヒー、お水、サンドイッチがいろいろあります。何にしますか？' FROM conv3
UNION ALL SELECT id, 'A', 2, 'I''d like a black coffee, please. And a chicken sandwich. Can I order now?', 'ブラックコーヒーをお願いします。チキンサンドイッチも。今注文できますか？' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Sure. I''ll have the same. Thank you for offering to pay. I''ll get the next one.', 'もちろん。私も同じのにします。払ってくださるとありがとう。次は私が払います。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'Deal. I''m glad we met. This seat next to you in the training room is perfect.', '決まりです。会えて嬉しいです。研修室であなたの隣の席で良かった。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Me too. Welcome to the group. Let''s support each other. I''ll go get our order when it''s ready.', '私も。グループへようこそ。お互いサポートしましょう。準備できたら注文を取りに行きます。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'That was good. Can I get the bill now? I want to pay before we go back to the room.', 'おいしかった。お会計お願いします。部屋に戻る前に払いたいんです。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'Thank you again. I really appreciate it. It was nice to meet you during the break.', 'またありがとうございます。本当に感謝しています。休憩中に会えて良かったです。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'You too. Welcome to the training. I think we''ll learn a lot together. Please let me know if you need anything.', 'こちらこそ。研修へようこそ。一緒にたくさん学べそうです。何かあれば教えてください。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Thank you. Same here. I''m ready for the afternoon session. See you in the room.', 'ありがとうございます。こちらも同じです。午後のセッションの準備ができました。部屋で会いましょう。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'See you. Thank you for the nice chat and the coffee break. Good luck with the rest of the day!', 'またね。楽しいおしゃべりとコーヒーブレイクをありがとう。今日の残りも頑張りましょう！' FROM conv4;
