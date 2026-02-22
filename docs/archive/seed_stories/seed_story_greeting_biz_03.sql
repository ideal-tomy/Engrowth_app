-- 3分ストーリー: クライアント訪問での初対面
-- 使用単語: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay
-- theme_slug: greeting_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'クライアント訪問での初対面',
    '取引先のオフィスを初めて訪問し、担当者と挨拶。会議室への案内と飲み物の提供、ミーティング前の会話。',
    3,
    3
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '受付で挨拶', 'オフィス入り口で担当者が出迎える', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '会議室へ案内', '席に着き飲み物を勧められる', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '自己紹介と打ち合わせの確認', '互いの役割を伝え、本題に入る前の会話', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '昼食の提案と会計の話', 'ランチに誘われ、支払いについて軽く話す', 'business', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hello! Welcome to our office. I''m so glad you could come today. Please come this way.', 'こんにちは！当社オフィスへようこそ。今日お越しいただき嬉しいです。こちらへどうぞ。' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Hello! Thank you for having me. Your office is very nice. Where should I take a seat?', 'こんにちは！お招きありがとうございます。オフィスが素晴らしいですね。どちらに席を取ればよいでしょうか？' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Please follow me to the meeting room. We have a good view from there. Would you like coffee or water?', '会議室まで案内します。そこから良い眺めが見えます。コーヒーとお水、どちらがよろしいですか？' FROM conv1
UNION ALL SELECT id, 'A', 4, 'Coffee, please. Thank you. I had a long drive this morning.', 'コーヒーをお願いします。ありがとうございます。今朝長いドライブだったので。' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Sure. I''ll order some for you. Please make yourself comfortable in this seat.', 'かしこまりました。注文します。どうぞこの席でお楽に。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'Thank you for the welcome. I''ve been looking forward to this meeting. I think we have a lot to discuss.', '歓迎してくださりありがとうございます。このミーティングを楽しみにしていました。話し合うことがたくさんありそうです。' FROM conv2
UNION ALL SELECT id, 'B', 2, 'Yes, we do. I handle the project on our side. What''s your role in your company? Please tell me.', 'はい、その通りです。当方ではプロジェクトを担当しています。御社でのご役割を教えてください。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'I''m the technical lead. I''ll support the integration work. I hope we can work well together.', '技術リードです。統合作業をサポートします。うまく連携できるといいですね。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'I think so too. Here''s your coffee. We also have a menu for lunch if you''d like to stay.', '私もそう思います。コーヒーです。お昼をご一緒するならメニューもありますよ。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'That sounds nice. Thank you. Do you have sandwiches? I''d like something light.', 'いいですね。ありがとうございます。サンドイッチはありますか？軽いものがいいんです。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Yes, we do. Let me show you the menu. You can order from the cafe downstairs. We often use them for meetings.', 'はい、あります。メニューをお見せします。階下のカフェから注文できます。ミーティングでよく利用しているんです。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Thank you. I''ll have a turkey sandwich, please. And I''d like to pay for my lunch. Is that possible?', 'ありがとうございます。ターキーサンドをお願いします。昼食代は私が払いたいんです。可能ですか？' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Oh, thank you! Usually we add it to the bill and split it. But if you prefer to pay separately, that''s fine.', 'ああ、ありがとうございます！普段は請求書に含めて割り勘にしています。別払いをご希望ならそれでも構いません。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'I''d like to pay for today as a thank you for hosting us. Please let me get the bill.', '今日は歓迎してくださったお礼として私が払いたいんです。お会計をさせてください。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'That''s very kind. Thank you. Let''s order now and we can continue our talk over lunch.', 'お気遣いありがとうございます。ありがとう。今注文して、ランチをしながら話を続けましょう。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Perfect. Thank you for welcoming me today. I feel very comfortable here.', '完璧です。今日歓迎してくださりありがとうございます。とても居心地が良いです。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'I''m glad to hear that. We want our partners to feel at home. Please let us know if you need anything.', 'そうおっしゃっていただいて嬉しいです。パートナーにはくつろいでいただきたいんです。何かあればお申し付けください。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Thank you. I will. I look forward to working with you. This seat has a great view, by the way.', 'ありがとうございます。そうします。一緒に仕事できるのを楽しみにしています。この席は眺めがいいですね。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Yes, we like it. Most visitors enjoy the view. Well, shall we start the meeting? I''ll call to order the sandwiches.', 'はい、気に入っています。多くのお客様が眺めを楽しんでくださいます。では、ミーティングを始めましょうか？サンドイッチを注文する電話をかけます。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'Please do. Thank you again for everything. I''m ready when you are.', 'お願いします。本当にありがとうございます。いつでも準備できています。' FROM conv4;
