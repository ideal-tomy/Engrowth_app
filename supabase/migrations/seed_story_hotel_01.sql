-- 3分ストーリー: ホテルのチェックイン
-- Engrowthアプリ英単語データ（単語151-200）を使用
-- 使用単語例: consider, appear, buy, wait, serve, send, expect, build, stay, fall, reach, remain, suggest, pass, require, report, decide, return, explain, hope

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ホテルのチェックイン',
    'ホテルに到着し、フロントでチェックインする会話。宿泊時の基本表現を学べます。',
    3,
    4
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'フロントへ', 'ホテルに到着しフロントに歩いていく', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '予約の確認', '名前と予約内容を確認する', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '部屋とアメニティ', '部屋の詳細や設備について聞く', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'キーを受け取り退室', 'チェックインを終え部屋へ向かう', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Excuse me. I just reached the hotel. I have a reservation. Where should I go?', 'すみません。ホテルに着いたばかりです。予約があります。どこへ行けばいいですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome! Please come to the front desk. I''ll serve you. Can you wait a moment? I''m helping another guest.', 'いらっしゃいませ。フロントまでお越しください。お手伝いします。少々お待ちいただけますか？お客様が1名おります。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Sure, no problem. I''ll stay here. The building looks nice, by the way.', '大丈夫です。ここで待ちます。ところで、建物が素敵ですね。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Thank you. We built it three years ago. It''s new. I''ll be with you in a second.', 'ありがとうございます。3年前に建てたものです。新しいんです。すぐ参ります。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Take your time.', 'お急ぎなく。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Hi! How can I help you? Do you have a reservation?', 'こんにちは。どのようなご用件でしょうか。ご予約はお取りですか？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Yes. My name is Tanaka. I expect to stay for three nights. I sent an email to confirm last week.', 'はい。田中です。3泊の予定です。先週確認のメールを送りました。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Let me check... Yes, I see it. Mr. Tanaka, two adults, three nights. Is that right?', '少々お待ちください... はい、確認できました。田中様、大人2名、3泊ですね。よろしいですか？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Yes, that''s correct. I need to report a change—we decided to stay one more night. Can we add it?', 'はい、その通りです。変更の報告があり—1泊追加することにしました。追加できますか？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I''ll check if we have room. It might require an extra charge. One moment.', '空室を確認します。追加料金が必要かもしれません。少々お待ちください。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Good news. We can do it. I suggest a room on the fifth floor. It has a nice view.', '良いお知らせです。可能です。5階のお部屋をおすすめします。眺めが良いです。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'That sounds good. What about breakfast? I hope you serve it. I read good things online.', 'いいですね。朝食はどうですか？出してくれるといいのですが。ネットで評判を読みました。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'Yes, we serve breakfast from seven to ten. You can buy vouchers at the desk or use our cafe. Let me explain the options.', 'はい、7時から10時まで提供しています。デスクで券をお買い求めいただくか、カフェをご利用いただけます。オプションをご説明します。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'I''ll consider it. For now, can we just get the keys? We want to rest. It was a long trip.', '検討します。まず鍵だけいただけますか？休みたいんです。長い旅だったので。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'Of course. Your room will remain ready. Here are two key cards. Pass them over the sensor to enter.', 'もちろんです。お部屋はご利用可能です。キーカードが2枚です。センサーにかざしてお入れください。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Thank you. Where is the elevator? I don''t want to fall carrying these bags.', 'ありがとう。エレベーターはどこですか？この荷物を持って転んだりしたくないので。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'To your right. The elevator will return you to this floor if you need anything. We''re here twenty-four hours.', '右手です。何か必要でしたらエレベーターでこの階に戻れます。24時間対応しております。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Great. One more thing—do you appear on the door when housekeeping comes? I mean, do you leave a sign?', 'ありがとう。もう一つ—ハウスキーピングの人はドアに何か表示するんですか？お札を置くとか。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Yes, they put a card under the door. If you want them to wait, just hang the "Do Not Disturb" sign. Have a nice stay!', 'はい、カードをドアの下に置きます。お待ちいただきたい場合は「お静かに」の札をかけてください。素敵なご滞在を。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'Thanks! We''ll see you.', 'ありがとう。また。' FROM conv4;
