-- 3分ストーリー: 国際交流イベントでの挨拶
-- 使用単語: company, system, program, question, night, government, number, point, home, water, room, mother
-- theme_slug: greeting_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際交流イベントでの挨拶',
    '国際交流イベントで初めて会う人たちと英語で挨拶を交わし、名前・出身・趣味など簡単な自己紹介をする会話。',
    3,
    6
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '会場での出会い', 'イベント会場で隣に座った人と挨拶', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '出身と家族の話', 'お互いの国や家族について話す', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '勉強やプログラムについて', '参加しているプログラムや目的を共有', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の連絡と別れ', '今夜のイベントや連絡先を話して別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! Is this seat free? The room is quite full tonight.', 'こんにちは！この席は空いていますか？今夜は会場が結構混んでいますね。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes, please sit down. Welcome to the event! Are you new to this program?', 'はい、どうぞ座ってください。イベントへようこそ。このプログラムは初めてですか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. I have a question though. How does the system work here? Do we just talk to different people?', 'はい。質問があるんです。ここでの流れはどうなっていますか？いろんな人と話すだけですか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Basically, yes. The program is simple. We mix and chat. There is water and snacks over there. Would you like some?', '基本はそうです。プログラムはシンプルです。混ざっておしゃべりします。あそこにお水とスナックがあります。いかがですか？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. Maybe later. I''m a bit nervous. I want to practice my English.', 'ありがとう。あとでいただきます。ちょっと緊張していて。英語の練習をしたいんです。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'So where is your home? What country are you from?', '出身はどこですか？どちらの国からですか？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I''m from Japan. My mother is Japanese and my father is from another country. We live in Tokyo. What about you?', '日本からです。母は日本人で父は別の国出身です。東京に住んでいます。あなたは？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'I''m from the US. My home is in California. I came here to study. The government has a program for students. It''s a good system.', 'アメリカからです。カリフォルニアの家です。勉強のために来ました。政府の学生向けプログラムがあって。いい制度なんです。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I see. So you have a room at the dorm? I''m staying with a host family. It''s nice but I miss my mother sometimes.', 'なるほど。寮の部屋に住んでいますか？私はホストファミリーの家に滞在しています。いいんですけど、母が恋しいときがあります。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I understand. I talk to my family every night. It helps. How long will you stay?', 'わかります。毎晩家族と話します。助かります。どのくらい滞在しますか？' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Six months. I work for a company in Japan. They have a study program. I want to improve my English for my job.', '6ヶ月です。日本の会社で働いています。会社に研修プログラムがあって。仕事のために英語を上達させたいんです。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'That makes sense. A lot of people here are students. The number of participants is high. What''s the main point of your program?', 'なるほど。ここには学生が多いです。参加者の数が多いんです。あなたのプログラムの主な目的は何ですか？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Business English. My company does work with other countries. I need to understand different systems and cultures.', 'ビジネス英語です。会社は他国と取引をしています。いろんなシステムや文化を理解する必要があるんです。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good point. I think tonight''s event is perfect for that. We can practice real conversation. No question is too simple here.', 'いい視点ですね。今夜のイベントはぴったりだと思います。実際の会話の練習ができます。ここではどんな質問も簡単すぎることはありません。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. That''s encouraging. I''ll try to talk to more people. Maybe we can meet again later tonight?', 'ありがとうございます。励みになります。もっと多くの人と話してみます。今夜あとでまた会えませんか？' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Sure! There is another event tonight in the same room. Same program, different people. Will you come?', 'もちろん。今夜同じ部屋でもう一つのイベントがあります。同じプログラムで違う人たちと。来ますか？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Yes, I''d like to. Can I get your number? I want to stay in touch. This has been really helpful.', 'はい、行きたいです。番号を教えてもらえますか？連絡を取り合いたいんです。本当に助かりました。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Of course. Here you go. The event starts at seven. I''ll look for you. Good luck with your company program.', 'もちろん。どうぞ。イベントは7時に始まります。あなたを探しますね。会社のプログラム、頑張ってください。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you so much. It was nice to meet you. I feel less nervous now. See you tonight!', '本当にありがとうございました。会えて嬉しかったです。緊張が和らいだ気がします。今夜また。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You too. Enjoy the rest of the event. Bye!', 'こちらこそ。残りのイベントを楽しんでください。バイバイ。' FROM conv4;
