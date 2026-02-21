-- 3分ストーリー: カフェで友人と待ち合わせ
-- Engrowthアプリ英単語データ（単語351-400）を使用
-- 使用単語例: matter, everyone, center, couple, site, project, activity, star, table, need, situation, easy, cost, industry, figure, street, phone, data, quite, picture, clear, practice, piece, land, product

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'カフェで友人と待ち合わせ',
    'カフェで友人と待ち合わせし、待ち時間に注文する。日常のカフェ利用シーンを学べます。',
    3,
    8
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '到着と席の確保', 'カフェに到着し友人を待つ', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '待ち合わせの連絡', '友人が遅れているため電話で連絡する', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '注文と席で待つ', '飲み物を注文し席で待つ', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '友人が到着', '友人が到着し会話を始める', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi. Table for two, please. My friend will join me soon. Can I sit in the center?', 'こんにちは。2人用のテーブルをお願いします。友達がすぐ来ます。真ん中あたりに座れますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Sure. Here, by the window. Everyone likes this spot. Is this your first time?', 'もちろん。こちら、窓際です。みなさんこの席がお好きです。初めてですか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. I found this place on a food site. The pictures looked good. We have a project to discuss.', 'はい。食べ物のサイトで見つけました。写真が良さそうで。打ち合わせるプロジェクトがあるんです。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Nice. Well, take your time. Order when your friend lands—I mean, when your friend arrives. What matters is you''re comfortable.', 'いいですね。では、ごゆっくり。お友達が着いたらお注文ください。大切なのはリラックスできることです。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thanks. I''ll wait.', 'ありがとう。待ちます。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'Hello? Yeah, I''m at the cafe. On Main Street. You''re late—what''s the situation?', 'もしもし。うん、カフェにいるよ。メインストリートの。遅れてる—どういう状況？' FROM conv2
UNION ALL SELECT id, 'B', 2, 'Sorry! The bus was slow. I need five more minutes. Can you order for me? A latte. I''ll pay when I get there.', 'ごめん。バスが遅くて。あと5分必要。僕の分も注文してくれる？ラテを。着いたら払うから。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'OK, no problem. I''ll get a couple of drinks. The cost is fine—it''s easy. See you soon.', 'オーケー、大丈夫。2杯頼むよ。費用は大丈夫—簡単だよ。すぐ会おう。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'Thanks! Oh, and check your phone for the data I sent. It''s about our activity. We can talk when I land.', 'ありがとう。あ、送ったデータをスマホで確認して。アクティビティの件。着いたら話そう。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'Got it. I''ll take a look. Bye.', '了解。見ておく。じゃあ。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I''d like to order. One iced coffee for me and one latte for my friend. He''s on the way.', '注文したいです。アイスコーヒー1つと、友達用にラテ1つ。友達は向かってます。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Sure. So that''s iced coffee and latte. We have a new product—star anise syrup. Want to add it?', 'かしこまりました。アイスコーヒーとラテですね。新商品がございます—スターアニスシロップ。追加されますか？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Maybe next time. For now, just the two drinks. How much? I figure about eight dollars.', '今度ね。今回は2杯だけ。いくらですか？8ドルくらいかな。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Nine fifty. Close. Here you go. Practice your English while you wait—we get a lot of learners. It''s quite clear from the way they order!', '9ドル50セントです。ほぼその通り。どうぞ。待ちながら英語の練習を—学習者のお客様が多いです。注文の仕方でかなりわかります。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Ha! I''m one of them. Thanks. I''ll have a piece of cake later when my friend comes.', 'はは。僕もその1人です。ありがとう。友達が来たらケーキを1切れ頼むわ。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Hey! Sorry I''m late. Is that my latte? You''re a star. Thanks.', 'やあ。遅れてごめん。それが僕のラテ？最高だよ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'No problem. I got the data. The industry info looks good. We can work on the project this afternoon.', '大丈夫。データ受け取った。業界情報良さそう。午後プロジェクトを進めよう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Perfect. This cafe is a good place. I''ve been here a couple times. The staff is nice. It''s a recent find.', '完璧。このカフェいい場所だね。僕は2、3回来たことある。スタッフがいい。最近見つけたんだ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Same. Well, let''s get to it. I have the picture clear now. We need to plan the next step.', '僕も。じゃあ本題に入ろう。全体像ははっきりしてる。次のステップを計画する必要がある。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Agreed. Let''s make it happen. Cheers!', '同意。実現させよう。乾杯。' FROM conv4;
