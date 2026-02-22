-- 3分ストーリー: 国際交流イベントでの挨拶（5本目）
-- 使用単語: kid, body, information, back, parent, face, others, level, office, door, health, person
-- theme_slug: greeting_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際交流イベントでの健康の話',
    '国際交流イベントで健康や家族、オフィスでの経験について話し合う会話。',
    3,
    10
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '入り口での出会い', 'ドアの前で会い挨拶', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '家族と健康', '子供や親、健康の話', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '仕事と情報', 'オフィスの仕事や情報交換', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '別れと今後', '戻る約束をして別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! I just came through the door. Is this the right place for the exchange event?', 'こんにちは。今ドアから入りました。交換イベントはここですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes, you are in the right place. Welcome! I am one of the organizers. Let me give you some information about the event.', 'はい、正しい場所です。ようこそ。運営の一人です。イベントについての情報をお伝えします。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I face the door when I get nervous. I like to know where the exit is. Is that strange?', 'ありがとう。緊張するとドアの方を向いちゃいます。出口がどこか知っていたいんです。変ですか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Not at all. Many others do the same. We are all human. Take a seat. There are drinks in the back.', '全然。他の多くの人も同じです。人間ですから。席に着いてください。後ろに飲み物があります。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thanks. I will sit by the door. Just in case. My body feels a bit tired. Long day.', 'ありがとう。ドアのそばに座ります。念のため。体が少し疲れています。長い1日でした。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'So are you a student? Do you have a kid at home? I ask because we have many parents in our program.', '学生ですか？お子さんはいますか？私たちのプログラムには親御さんが多くいるので。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'No, I do not have a kid. But my parent lives with me. She worries about my health. I exercise to keep my body strong.', 'いいえ、子供はいません。でも親が一緒に住んでいます。私の健康を心配しています。体を強く保つために運動しています。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'That is good. Health is important. I have a kid. A little one. I bring her back to the office sometimes. She likes to meet others.', 'それはいいですね。健康は大切です。子供がいます。小さい子。時々オフィスに連れて帰ります。他の人に会うのが好きです。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'How nice. I work in an office too. But no kids there. Just adults. We share information all day. It can be tiring for the body.', 'いいですね。私もオフィスで働いています。でも子供はいません。大人だけ。一日中情報を共有します。体が疲れることがあります。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I understand. What level is your English? You speak well. Better than many others I have met.', 'わかります。英語のレベルはどのくらいですか？お上手です。会った多くの人より上です。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Thank you. I practice a lot. I need English for my office job. We work with people from other countries. Information goes back and forth.', 'ありがとう。たくさん練習しています。オフィスの仕事で英語が必要なんです。他国の人と仕事をします。情報が行き来します。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'That sounds like a good way to learn. Face to face with real people. Not just from a book. Each person has different information to share.', 'いい学び方ですね。実際の人と face to face で。本からだけじゃなく。それぞれが共有する情報が違います。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Yes. I learn from others every day. My parent says I should take care of my health though. Too much work is not good for the body.', 'はい。毎日他の人から学んでいます。でも親は健康に気をつけるように言います。働きすぎは体に良くないと。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Your parent is right. I close the door at the office at six. I go back home to my kid. Balance is key.', 'お母さん（お父さん）の言う通りです。オフィスでは6時にドアを閉めます。子供のいる家に帰ります。バランスが鍵です。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Good advice. I will try that. Maybe I can get more information from you about the event? When does it end?', 'いいアドバイス。やってみます。イベントについてもっと情報をいただけますか？いつ終わりますか？' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'In about thirty minutes. We have a break at the back. You can meet other people there. Same level, same goals.', 'あと30分くらいです。後方で休憩があります。そこで他の人に会えます。同じレベル、同じ目標。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I will go to the back then. Thank you for the information. You are a kind person. I feel better about my body and mind now.', 'それでは後ろに行きます。情報をありがとう。優しい方ですね。今は心身ともに気分が良くなりました。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. Take care of your health. I hope to see you back here next week. We have an event for kids and parents too. You can bring your parent.', '良かった。健康に気をつけて。来週またここで会えるといいです。子供と親向けのイベントもあります。お母さん（お父さん）を連れてきてください。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'That is a good idea. I will ask. Goodbye. It was nice to face you. I mean, meet you.', 'いいアイデア。聞いてみます。さようなら。お会いできて嬉しかったです。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. See you next time. Bye!', 'さようなら。また次に。バイバイ。' FROM conv4;
