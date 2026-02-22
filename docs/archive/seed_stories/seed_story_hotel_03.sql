-- 3分ストーリー: ホテルのチェックアウト
-- Engrowthアプリ英単語データ（単語251-300）を使用
-- 使用単語例: information, level, office, door, health, person, art, history, party, result, change, morning, reason, research, moment, light, class, control, care, field

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ホテルのチェックアウト',
    'ホテルを出る際のチェックアウト。請求確認やタクシーの手配など、退館時の会話を学べます。',
    3,
    6
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'フロントでチェックアウト', 'カウンターで精算手続きをする', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '請求内容の確認', '明細について質問する', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '荷物預かりとタクシー', '荷物を預けタクシーを呼んでもらう', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お礼と別れ', '感謝を伝えホテルを後にする', 'student', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning. I''d like to check out. Room 712. Here''s my key.', 'おはようございます。チェックアウトをお願いします。712号室です。こちらが鍵です。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Good morning. One moment, please. I''ll pull up your information. Did you enjoy your stay?', 'おはようございます。少々お待ちください。情報を確認します。ご滞在はいかがでしたか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes, very much. The room was nice. Good level of service. I had a business meeting and everything went well.', 'はい、とても。部屋も良かった。サービス水準も高かった。仕事の打ち合わせがあって、すべて順調でした。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'I''m glad to hear that. Here is your bill. You can review it. Let me know if you have any questions.', 'お聞きして嬉しいです。こちらが請求書です。ご確認ください。ご質問があればお知らせください。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. I need to check a few things. Can I ask now?', 'ありがとうございます。いくつか確認したいことがあります。今聞いてもいいですか？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Of course. What would you like to know?', 'もちろんです。何でしょうか？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'This charge for the mini bar. I didn''t open the door to it. I''m sure I didn''t use anything.', 'ミニバーのこの料金です。ドアを開けた覚えがありません。使っていないはずです。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Let me check. Sometimes the sensor has a problem. We''ll take care of it. Your health and satisfaction matter to us.', '確認します。センサーに問題があることがあります。対応します。お客様の満足は当ホテルの重要な事柄です。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. One more thing—the reason for this extra charge? I see "room service" but we didn''t order at night.', 'ありがとうございます。もう一つ—この追加料金の理由は？「ルームサービス」とありますが、夜は注文していません。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Oh, that was from your first morning. You had coffee and toast. Does that sound right? If not, we''ll change it.', 'ああ、それは初日の朝のお食事です。コーヒーとトーストでした。合っていますか？違えば変更します。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Right, I remember now. That''s fine. So, the result is—how much do I owe?', 'そうでした、思い出しました。それでいいです。では結果として—いくら払えばいいですか？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'After we remove the mini bar charge, the total is two hundred twenty dollars. You can pay at the office or here.', 'ミニバー料金を差し引くと、合計220ドルです。オフィスまたはこちらでお支払いいただけます。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I''ll pay here. Also, I need a taxi to the airport. Can you call one? I have a flight in two hours.', 'ここで払います。それと、空港行きのタクシーをお願いしたいです。呼んでもらえますか？2時間後に便があります。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Sure. We''ll take care of that. In the meantime, we can take care of your bags. You can wait in the lobby.', '承知しました。手配します。その間、荷物はお預かりします。ロビーでお待ちいただけます。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Perfect. I''ll sit and have a light snack. Control the bill for me—I don''t want any surprises!', '完璧です。座って軽食を取ります。請求はしっかり管理してください—想定外は困ります。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Your taxi is here. Here are your bags. Safe travels!', 'タクシーが到着しました。こちらがお荷物です。良い旅を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Everyone here has been so kind. You have a great team. It''s like a family, not just a party of staff.', 'ありがとうございます。みなさん親切でした。素晴らしいチームですね。スタッフの集まりというより家族のようです。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'That''s nice of you to say. We do research on guest satisfaction. Your feedback helps. Please come back.', 'お褒めいただきありがとうございます。お客様満足度の調査も行っております。ご意見は参考になります。またお越しください。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will. This place has history and art—you can feel it. I''ll tell my friends. Goodbye!', '必ず。この場所には歴史と芸術がある—感じられます。友人にも勧めます。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye! Have a good trip!', 'さようなら。よいご旅行を。' FROM conv4;
