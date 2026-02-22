-- 3分ストーリー: パーティーでの挨拶
-- Engrowthアプリ英単語データ（単語101-150）を使用
-- 使用単語例: keep, let, begin, help, talk, turn, start, might, show, hear, bring, happen, learn, understand, speak, read, allow, add, spend, remember, love

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'パーティーでの挨拶',
    'パーティーで初対面の人と挨拶し、会話を広げる。交流の場で使える自然なフレーズを学べます。',
    3,
    3
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '紹介される', 'ホストに紹介されて挨拶する', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '会話を始める', '共通の話題を見つけて話し始める', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '趣味や仕事の話', 'お互いの背景について話す', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '連絡先交換と別れ', 'また会う約束をして別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'B', 1, 'Hi! Let me introduce you. This is Mike. Mike, this is Emma.', 'こんにちは。紹介させて。マイクです。マイク、こちらはエマ。' FROM conv1
UNION ALL SELECT id, 'A', 2, 'Nice to meet you, Mike. I''ve heard a lot about you. Emma''s told me you love music.', '初めまして、マイク。お話はよく聞いてます。エマが音楽が大好きだって。' FROM conv1
UNION ALL SELECT id, 'B', 3, 'Nice to meet you too! Yes, it''s true. I play the guitar. Do you like music?', 'こちらこそ。ええ、その通りです。ギターを弾くんです。音楽は好きですか？' FROM conv1
UNION ALL SELECT id, 'A', 4, 'I do! I''ve been trying to learn. Maybe you could help me sometime?', '好きです。習おうとしてるんです。いつか教えてもらえたら。' FROM conv1
UNION ALL SELECT id, 'B', 5, 'Sure! I''d be happy to. Let''s talk more and I can show you a few things.', 'もちろん。喜んで。もっと話して、いくつか見せてあげるよ。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'A', 1, 'So, how do you know Emma? Did you meet at work?', 'で、エマとはどうやって知り合ったの？仕事で会ったの？' FROM conv2
UNION ALL SELECT id, 'B', 2, 'We met at a concert last year. We happen to stand next to each other. It was a great night.', '去年のコンサートで会ったんだ。偶然隣に並んでた。すごくいい夜だった。' FROM conv2
UNION ALL SELECT id, 'A', 3, 'That sounds fun. I wish I could go to more concerts. I spend too much time at home.', '楽しそう。私もコンサートにもっと行けたらいいのに。家にいる時間が多すぎるの。' FROM conv2
UNION ALL SELECT id, 'B', 4, 'You should come next time. Emma and I go often. We could bring you along.', '今度一緒に来たら。エマとよく行くんだ。君も連れて行けるよ。' FROM conv2
UNION ALL SELECT id, 'A', 5, 'I''d love that! Let me add that to my plans. When is the next one?', '嬉しい。予定に入れとく。次はいつ？' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'B', 1, 'In two weeks. So, what do you do? Emma said you teach. Is that right?', '2週間後だよ。で、君は何してる？エマが教えてたって言ってた。先生なの？' FROM conv3
UNION ALL SELECT id, 'A', 2, 'Yes, I teach English. I read a lot and try to understand different cultures. That''s part of the job.', 'ええ、英語を教えてます。たくさん本を読んで、いろんな文化を理解しようとしてる。仕事の一部なんです。' FROM conv3
UNION ALL SELECT id, 'B', 3, 'That''s interesting. I work with computers, but I speak to people all day. Different kind of talk!', '面白いね。僕はコンピュータの仕事だけど、一日中人と話してる。話し方いろいろだよね。' FROM conv3
UNION ALL SELECT id, 'A', 4, 'True! Well, I think we all need to keep learning. There''s always something new.', '本当に。でも、みんな学び続ける必要があると思う。いつも何か新しいことがあるから。' FROM conv3
UNION ALL SELECT id, 'B', 5, 'I agree. That''s why I started playing music again. It allows me to try new things.', '同感。だからまた音楽を始めたんだ。新しいことに挑戦できる。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'A', 1, 'Well, it was really nice to meet you. I''ll remember this conversation. We should meet again.', '会えて本当に良かった。この会話覚えておくわ。また会いましょう。' FROM conv4
UNION ALL SELECT id, 'B', 2, 'Same here. Here, take my card. You can reach me anytime. Let''s begin with that concert.', 'こちらこそ。ほら、名刺。いつでも連絡して。まずはあのコンサートから始めよう。' FROM conv4
UNION ALL SELECT id, 'A', 3, 'Thanks! I''ll be in touch. Have a great evening. I hope the rest of the party goes well.', 'ありがとう。連絡するわ。良い夜を。パーティーの残りも楽しんでね。' FROM conv4
UNION ALL SELECT id, 'B', 4, 'You too. See you soon!', '君もね。またすぐに。' FROM conv4;
