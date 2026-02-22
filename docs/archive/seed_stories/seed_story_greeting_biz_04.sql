-- 3分ストーリー: オフィス見学での挨拶
-- 使用単語: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay
-- theme_slug: greeting_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'オフィス見学での挨拶',
    '新規取引を検討中、相手先オフィスを見学。担当者と挨拶し、ラウンジでコーヒーを飲みながら話す。',
    3,
    4
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'エントランスで出迎え', 'オフィス入口で担当者が挨拶', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'ラウンジへ案内', '休憩スペースで席に着く', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '飲み物と軽食の提供', 'コーヒーを注文し、メニューを見る', 'business', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '見学終了とお礼', '会計の話、お礼を伝えて別れる', 'business', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hello! Welcome to our office. We''re happy to have you here today. Please come in.', 'こんにちは！当社オフィスへようこそ。今日お越しいただき嬉しいです。どうぞお入りください。' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Hello! Thank you for the invitation. Your building looks impressive. Where can I take a seat?', 'こんにちは！お招きありがとうございます。建物が素晴らしいですね。どちらに席を取ればよいでしょうか？' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Please follow me to the lounge. We have coffee and water there. You can order anything you like.', 'ラウンジへどうぞ。コーヒーとお水があります。お好きなものを注文できますよ。' FROM conv1
UNION ALL SELECT id, 'A', 4, 'Thank you. Coffee would be great. I''d like to see the lounge too.', 'ありがとうございます。コーヒーがいいです。ラウンジも見てみたいです。' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Sure. This way, please. Welcome to our team space. We''re proud of it.', 'かしこまりました。こちらへどうぞ。チームスペースへようこそ。自慢の場所です。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'This is a nice seat. The view is wonderful. Thank you for showing me around.', 'いい席ですね。眺めが素晴らしい。案内してくださりありがとうございます。' FROM conv2
UNION ALL SELECT id, 'B', 2, 'You''re welcome. Let me order some coffee for you. What would you like? Black or with milk?', 'どういたしまして。コーヒーを注文しますね。どんなのがよろしいですか？ブラックかミルク入りか。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'Black, please. And maybe some water too. Thank you.', 'ブラックをお願いします。お水もいただけると助かります。ありがとうございます。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'No problem. We also have a menu for sandwiches if you get hungry. The cafe is very popular here.', '問題ありません。お腹が空いたらサンドイッチのメニューもあります。カフェはここで大人気なんです。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'That''s good to know. Thank you. I might order a sandwich later. I skipped breakfast.', 'それはいい情報ですね。ありがとう。あとでサンドイッチを注文するかもしれません。朝食を抜いてきたんです。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Here''s your coffee and water. Please enjoy. Let me know when you want to order food.', 'コーヒーとお水です。どうぞ。食べ物を注文したくなったらお知らせください。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Thank you so much. The coffee is good. Can I see the menu? I think I''ll order a sandwich now.', '本当にありがとうございます。コーヒーがおいしいです。メニューを見せてもらえますか？今サンドイッチを注文しようと思います。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Of course. Here you go. Please take your time. I''d like to pay for your lunch today as a welcome gift.', 'もちろん。どうぞ。ゆっくり選んでください。今日の昼食は歓迎の贈り物として私が払います。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'Oh, thank you! That''s very kind. Are you sure? I''d be happy to pay for myself.', 'ああ、ありがとうございます！お気遣いありがとう。本当にいいんですか？自分で払っても構いません。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Please let me. It''s our pleasure. I''ll get the bill when we''re done. Just enjoy your visit.', 'お任せください。私たちの喜びです。終わったらお会計します。見学をお楽しみください。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Thank you for everything today. The office is wonderful. I''ll discuss the visit with my team.', '今日は本当にありがとうございました。オフィスは素晴らしいです。チームと見学について話し合います。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'I''m glad you liked it. Welcome again anytime. We hope to work with you soon.', '気に入っていただけて嬉しいです。いつでもまたようこそ。早日お取引できることを願っています。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Thank you. I''ll send an email with my thoughts. And please don''t forget to send me the bill for the sandwich.', 'ありがとうございます。所感をメールでお送りします。サンドイッチの請求書をお送りください。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Don''t worry about it. We covered it today. It was nice to meet you. Please take care.', '心配しないでください。今日は私たちが払いました。お会いできて嬉しかったです。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'You too. Thank you again for the welcome and the coffee. Goodbye!', 'こちらこそ。歓迎とコーヒーを本当にありがとうございました。さようなら！' FROM conv4;
