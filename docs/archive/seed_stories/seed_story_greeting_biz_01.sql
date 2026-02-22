-- 3分ストーリー: ビジネスシーンでの初対面の挨拶と会話
-- 使用単語: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay
-- theme_slug: greeting_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ビジネス初対面の挨拶',
    '新しいプロジェクトチームで初めて会う同僚との丁寧な挨拶、自己紹介、そしてランチでの会話まで。',
    3,
    1
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '出会いと歓迎', 'オフィスで初対面、挨拶と席の案内', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '自己紹介', 'お互いの名前と担当を伝える', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'ランチの提案', '昼食に誘い、メニューを確認する', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '注文と会計', 'サンドイッチを注文し、支払いを済ませる', 'business', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hello! Welcome to the team. I''m glad you could join us today. We''ve been looking forward to meeting you.', 'こんにちは！チームへようこそ。今日はお越しいただきありがとうございます。お会いできるのを楽しみにしていました。' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Hello! Thank you so much. I''m really excited to be here and to start working on this project. Where can I take a seat for now?', 'こんにちは！本当にありがとうございます。参加できて嬉しいです。今、どちらに席を取ればよいでしょうか？' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Please sit over there by the window. The view is nice and it''s a quiet spot. Would you like some coffee or water while we talk?', '窓際の席にどうぞ。眺めが良くて静かです。お話しする間、コーヒーかお水はいかがですか？' FROM conv1
UNION ALL SELECT id, 'A', 4, 'Water, please. That would be great. I had a long trip this morning so water would be perfect. Thank you.', 'お水をお願いします。助かります。今朝長い移動だったので水がちょうどいいです。ありがとうございます。' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Sure. I''ll get it for you in a minute. Make yourself at home.', 'かしこまりました。すぐにお持ちします。どうぞお楽になさってください。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'I''ve read about the project online and I think we have a lot to discuss. The scope seems quite interesting.', 'プロジェクトについてオンラインで読みました。話し合うことはたくさんありそうです。スコープがとても興味深いですね。' FROM conv2
UNION ALL SELECT id, 'B', 2, 'Yes, absolutely. I handle the design side of things. What will you be working on? I''d love to know how we can collaborate.', 'はい、その通りです。私はデザイン側を担当しています。あなたはどの分野を担当されますか？一緒にどう連携できるか知りたいです。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'I''ll support the technical part. I hope we can work well together. I believe good communication between design and tech is key.', '技術面をサポートします。うまく連携できるといいですね。デザインと技術の間の良好なコミュニケーションが鍵だと思います。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'I think so too. By the way, it''s almost noon. Would you like to get lunch? I can show you around the building.', '私もそう思います。ところで、もうすぐお昼です。ランチに行きませんか？建物内を案内しますよ。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'That sounds good. Thank you for the offer. Where do you usually go? I''d like to try a place that everyone likes.', 'いいですね。誘ってくださりありがとうございます。普段はどこに行かれますか？皆さんが気に入っているところを試してみたいです。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'There''s a cafe downstairs. They have a nice menu with lots of options. Let me show you the way.', '階下にカフェがあります。いろいろなメニューがありますよ。案内しますね。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Great. I''d like to order something light for lunch. Do they have sandwiches? I don''t want to eat too much before the afternoon meeting.', 'いいですね。軽いランチを注文したいです。サンドイッチはありますか？午後のミーティング前に食べすぎたくないんです。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Yes, they do. The turkey sandwich is very popular here. Please take a look at the full menu when we get there. They also have salads if you prefer.', 'はい、あります。ターキーサンドがここでは人気なんです。着いたらメニューをご覧ください。サラダもありますよ。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'Perfect. I think I''ll have the turkey sandwich then. Shall we go? I''m ready when you are.', '完璧です。それではターキーサンドにします。行きましょうか？いつでも行けます。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Sure. This way, please. It''s just down the hall and we take the elevator to the first floor.', 'はい。こちらへどうぞ。廊下を進んでエレベーターで1階に行きます。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'That was really good. Can I get the bill, please? I''d like to pay for lunch today as a thank you for welcoming me to the team.', 'とてもおいしかったです。お会計お願いします。今日のランチは私が払います。チームに迎えてくださったお礼として。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'Oh, thank you! That''s very kind of you. Are you sure? You don''t have to do that.', 'ああ、ありがとうございます！お気遣いありがとう。本当にいいんですか？そんなことしなくてもいいのに。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Yes, please. Consider it a thank you for welcoming me today and for showing me around. I really appreciate it.', 'はい、お願いします。今日歓迎してくださって、案内までしてくださったお礼として。本当に感謝しています。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'I really appreciate it too. Let me get the next one when we go out for coffee again. It was nice to meet you. I think we''ll work well together.', 'こちらこそ感謝しています。次にコーヒーに行くときは私が払います。お会いできて嬉しかったです。うまく連携できそうです。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'You too. I look forward to working with you on the project. Thank you again for everything today.', 'こちらこそ。プロジェクトで一緒に仕事できるのを楽しみにしています。今日はいろいろありがとうございました。' FROM conv4;
