-- 3分ストーリー: カフェで仕事をする
-- Engrowthアプリ英単語データ（単語301-350）を使用
-- 使用単語例: role, possible, heart, voice, whole, mind, finally, free, price, decision, view, relationship, town, building, action, full, model, season, society, position, record, paper, special, space, form, event, official

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'カフェで仕事をする',
    'カフェでリモートワークや打ち合わせをする会話。Wi-Fiや席の確保など、カフェで働く際の表現を学べます。',
    3,
    7
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '席を確保する', 'カフェに入り席を探す', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '注文とWi-Fi', '飲み物を注文しWi-Fiについて聞く', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '長居の許可', '何時間いるか、充電について確認する', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '追加注文と別れ', '追加注文をし、会計する', 'student', 'カフェ'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi. Do you have space for one? I need to work on my laptop for a while.', 'こんにちは。1人分の席はありますか？少しノートパソコンで仕事をしたいんです。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Sure! We have tables near the window. The view is nice. Is that possible for you?', 'もちろん。窓際にテーブルがあります。眺めが良いです。いかがですか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes, that sounds good. I''m in town for a meeting. This cafe is in a great building—very calm.', 'はい、それでお願いします。打ち合わせで町に来ています。このカフェはすばらしい建物ですね—とても落ち着きます。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Thank you. We get a lot of people who work here. It''s a special place. Find a seat and order when you''re ready.', 'ありがとうございます。ここで仕事するお客様が多くいらっしゃいます。特別な場所なんです。お席をお探しになって、お決まりになったらお注文ください。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Got it. Thanks.', 'わかりました。ありがとう。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'I''d like a large coffee, please. What''s the price? And do you have free Wi-Fi?', 'ラージのコーヒーをください。おいくらですか？それと無料Wi-Fiはありますか？' FROM conv2
UNION ALL SELECT id, 'B', 2, 'Large coffee is four dollars. Yes, Wi-Fi is free. The password is on the wall. We have outlets too—near the ground.', 'ラージは4ドルです。はい、Wi-Fiは無料です。パスワードは壁にあります。コンセントも—床近くに。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'Perfect. I have an important call. I need a quiet spot. Is it OK to take calls here?', '完璧です。重要な電話があります。静かな場所が必要なんです。ここで電話してもいいですか？' FROM conv2
UNION ALL SELECT id, 'B', 4, 'Yes, but please keep your voice low. We have other guests. It''s the season for students—we''re full in the afternoon.', 'はい、ただ声は小さくお願いします。他のお客様がいらっしゃいます。学生の季節で—午後は満席になります。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'I understand. I''ll be mindful. Thanks.', 'わかりました。気をつけます。ありがとう。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'Here''s your coffee. Can I get you anything else? We have sandwiches and pastries.', 'お待たせしました。他にご注文は？サンドイッチとペストリーがあります。' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Maybe later. For now, is it OK if I stay two or three hours? I have a lot of paper to work on.', 'あとでかもしれない。今のところ、2〜3時間いてもいいですか？仕事の書類がたくさんあるんです。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'That''s fine. We don''t have an official time limit. Many people use this as a workspace. Just buy something every couple of hours.', '大丈夫です。正式な制限時間はありません。ワークスペースとして使うお客様が多くいらっしゃいます。2時間ごとに何かお買い求めください。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'Fair enough. I''ll have another coffee later. My whole team works remotely. This kind of space is a model for our society now.', 'なるほど。あとでコーヒーもう一杯頼みます。チーム全員がリモートなんです。こういう場所は今の社会のモデルですね。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'We think so too. Enjoy. Let us know if you need anything. We have events sometimes—maybe you''ll catch one.', '私たちもそう思います。ごゆっくり。何かあればお声がけください。イベントも時々やってます。もしかしたら参加できますよ。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'I''m done. Can I get the bill? I had two coffees and finally a sandwich. The meeting went well—we made a decision.', '終わりました。お会計お願いします。コーヒー2杯と、最後にサンドイッチを。打ち合わせはうまくいきました—決断できました。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'Sure. Two coffees and one sandwich. Your record shows twelve dollars. Card or cash?', 'かしこまりました。コーヒー2杯とサンドイッチ1つ。12ドルです。カードと現金どちらですか？' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Card. I had a good relationship with this place today. I''ll come back. Strong coffee, great service. You all play a key role in that.', 'カードで。今日はこの場所と良い関係が築けました。また来ます。しっかりしたコーヒー、素晴らしいサービス。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'Thank you! We''re glad it worked. See you next time. Good luck with your position!', 'ありがとうございます。お役に立てて嬉しいです。またお越しください。お仕事のポジション、頑張ってください。' FROM conv4
UNION ALL SELECT id, 'A', 5, 'Thanks! Bye.', 'ありがとう。バイバイ。' FROM conv4;
