-- 3分ストーリー: ビジネスイベントでの初対面
-- 使用単語: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay
-- theme_slug: greeting_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ビジネスイベントでの初対面',
    '業界カンファレンスで初めて会う他社の担当者との挨拶と名刺交換。コーヒーブレイクでの会話。',
    3,
    2
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '会場での出会い', 'カンファレンス会場で隣の席の人と挨拶', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '自己紹介と名刺交換', '会社名と担当を伝え合う', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'コーヒーブレイクへ', '休憩室で飲み物を取る', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '軽食と今後の連絡', 'サンドイッチを取って席に戻り、別れの挨拶', 'business', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hello! Is this seat taken? I don''t want to sit in the wrong place.', 'こんにちは！この席は空いていますか？間違った席に座りたくないんです。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Hello! No, please sit down. Welcome to the conference. I''m glad we''re sitting next to each other.', 'こんにちは！いいえ、どうぞお座りください。カンファレンスへようこそ。隣り合わせで嬉しいです。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. This is my first time at this event. The venue is quite nice.', 'ありがとうございます。このイベントは初めてなんです。会場がとてもいいですね。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes, it is. They have coffee and water in the back. You can order something during the break if you like.', 'はい、そうなんです。後方にコーヒーとお水があります。休憩中に何か注文できますよ。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'That''s good to know. Thank you for telling me. I might need a coffee soon.', 'それはいい情報ですね。教えてくださりありがとうございます。もうすぐコーヒーが必要かもしれません。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'So, what company are you from? I''d love to know more about what you do.', 'どの会社からいらっしゃいましたか？お仕事の内容を聞かせてください。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I work for a tech company. We develop software for business. What about you? Please tell me about your role.', 'テック企業で働いています。ビジネス向けソフトウェアを開発しています。あなたは？ご担当について教えてください。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'I''m in sales. I handle clients in Asia. It''s nice to meet people from different industries here.', '営業をしています。アジアのクライアントを担当しています。いろんな業界の方とお会いできるのが嬉しいです。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I agree. Thank you for the chat. Maybe we can get coffee together during the next break?', '同感です。お話しくださりありがとうございます。次の休憩に一緒にコーヒーでもいかがですか？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I''d like that. Let''s go when the session ends. I''ll show you where the menu is.', 'いいですね。セッションが終わったら行きましょう。メニューのある場所をお見せします。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Great. Can you show me the menu? I want to order a coffee and maybe some water.', 'ありがとう。メニューを見せてもらえますか？コーヒーと、できればお水を注文したいんです。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Sure. Here it is. The coffee is good here. Please take your time to choose.', 'もちろん。こちらです。ここはコーヒーがおいしいです。ゆっくり選んでください。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thank you. I''ll have a black coffee, please. And a bottle of water for the afternoon session.', 'ありがとうございます。ブラックコーヒーをください。それと午後のセッション用にお水を1本お願いします。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good choice. I''ll have the same. Let me pay for both. Consider it a welcome gift.', 'いい選択ですね。私も同じのにします。両方払いますね。歓迎の贈り物と思ってください。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Oh, thank you! That''s very kind. I''ll get the bill next time we have coffee together.', 'ああ、ありがとうございます！お気遣いありがとう。次にコーヒーを一緒に飲むときは私が払います。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'They also have sandwiches if you''re hungry. The turkey one is popular. Do you want to order one?', 'お腹が空いたらサンドイッチもありますよ。ターキーが人気なんです。注文しますか？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Yes, please. I''d like a sandwich. Can I pay for it? You paid for the coffee already.', 'はい、お願いします。サンドイッチが欲しいです。私が払いましょうか？コーヒーはもうお支払いでしたよね。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'That would be great. Thank you. Let''s find a seat and eat before the next session.', 'それは助かります。ありがとう。席を見つけて次のセッションの前に食べましょう。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good idea. I''ll get the bill and we can sit by the window. Thank you for a nice chat today.', 'いいですね。お会計して窓際に座りましょう。今日は楽しいお話をありがとうございました。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You too. Welcome again, and I look forward to staying in touch. Let''s exchange cards before we go back.', 'こちらこそ。またようこそ、そしてこれからも連絡を取り合いましょう。戻る前に名刺を交換しましょう。' FROM conv4;
