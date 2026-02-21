-- 3分ストーリー: 初めての挨拶（公園で）
-- Engrowthアプリ英単語データ（単語1-50）を使用
-- 使用単語例: say, go, know, get, like, think, make, time, see, I, you, have, it, can, will, would, this, that, all, one, about, more, when

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '初めての挨拶',
    '公園で知らない人と初めて会った時の挨拶。自己紹介と簡単な会話を学べます。',
    3,
    1
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '出会いと挨拶', '公園で偶然会い、挨拶を交わす', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '自己紹介', 'お互いの名前と出身を伝える', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '好きなことの話', '趣味や好きなことを話す', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '別れの挨拶', 'また会う約束をして別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! Nice day, isn''t it?', 'やあ、いい天気ですね。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Hi! Yes, it is. I come here often. Do you?', 'こんにちは。ええ、そうですね。私はよくここに来ます。あなたは？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'This is my first time. I want to know a good place to sit. Can you tell me?', '初めてなんです。いい場所を教えてほしいんです。どこかおすすめありますか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Sure! Over there by the tree. That''s the best spot. I can show you if you like.', 'もちろん。あそこの木の近くがいいよ。一番おすすめの場所だよ。よければ案内するよ。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you! That would be great.', 'ありがとう。それ、助かります。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'By the way, my name is Tom. What about you?', 'ところで、僕はトムっていいます。あなたは？' FROM conv2
UNION ALL SELECT id, 'B', 2, 'I''m Sarah. Nice to meet you, Tom. So, are you from around here?', 'サラよ。会えて嬉しいわ、トム。この辺りにお住まいなの？' FROM conv2
UNION ALL SELECT id, 'A', 3, 'No, I just moved here. I don''t know many people yet. That''s why I thought I''d come to the park.', 'いいえ、最近引っ越してきたばかりなんです。まだ知り合いが少なくて。だから公園に来てみようと思って。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'I see. Well, you will get to know more people. This is a nice town.', 'そうなの。まあ、そのうちもっと知り合いができるわ。いい町よ。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'I think so too. I like it here already.', '僕もそう思います。もうここが気に入っています。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'So Tom, what do you like to do in your free time?', 'トム、暇なときは何をするのが好き？' FROM conv3
UNION ALL SELECT id, 'A', 2, 'I like to read and take walks. I make time for that every day. How about you?', '読書と散歩が好きです。毎日その時間を確保してます。サラは？' FROM conv3
UNION ALL SELECT id, 'B', 3, 'I love reading too! And I go running sometimes. We have a lot in common.', '私も読書が大好き。それと時々ジョギングもするわ。共通点がたくさんあるわね。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'That''s good to hear. Maybe we can go for a walk together one day?', 'それは嬉しいですね。いつか一緒に散歩できたらいいですね。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'I''d like that! Let''s say next weekend?', 'いいわね。来週の週末ってどう？' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Sounds good! I''ll see you then. It was nice to meet you, Sarah.', 'いいですね。その時に会いましょう。会えて嬉しかったです、サラ。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'You too, Tom. Have a good one! I''ll look for you by the tree next Saturday.', 'こちらこそ、トム。良い1日を。来週土曜、木のあたりで待ってるわ。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'All right. See you! Take care.', 'わかりました。またね。気をつけて。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'You too. Bye!', 'あなたもね。バイバイ！' FROM conv4;
