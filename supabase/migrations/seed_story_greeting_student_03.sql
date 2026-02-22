-- 3分ストーリー: 国際交流イベントでの挨拶（3本目）
-- 使用単語: business, issue, side, kind, head, house, service, friend, father, power, hour, game
-- theme_slug: greeting_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際交流イベントでの交流',
    '国際交流イベントで家族や友人の話、ゲームを通じて仲良くなる会話。',
    3,
    8
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '家族の紹介', '父親や家族の話で親しくなる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '趣味とゲーム', 'ゲームや趣味の話', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'ビジネスと勉強', '将来の仕事や学びについて', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の約束と別れ', 'また遊ぶ約束をして別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! Nice to meet you. I like this kind of event. People are so friendly here.', 'こんにちは。会えて嬉しいです。こんなイベントが好きです。みんなとても親切。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Me too. My father told me to come. He said it would help my English. He runs a small business.', '私も。父が来るように言いました。英語の役に立つと言って。小さなビジネスを経営しています。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'That is kind of him. My friend invited me. She said the service here is good. Free drinks and snacks.', 'お優しいですね。友達が誘ってくれました。ここのサービスがいいと言って。飲み物やスナックが無料。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. I live in a house near the campus. It takes about an hour to walk here. But I like the exercise.', 'はい。キャンパス近くの家に住んでいます。歩いて1時間くらいです。でも運動になります。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I live on the other side of town. My father is a teacher. He has a lot of power over my study habits.', '私は町の反対側に住んでいます。父は先生です。私の勉強習慣にかなり口を出します。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'So what do you do for fun? I like to play games. Video games, board games. Any kind.', '趣味は何をしますか？ゲームが好きです。ビデオゲーム、ボードゲーム。何でも。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I like games too. I have a friend who is a game designer. He works for a big company. It is his dream job.', '私もゲームが好きです。ゲームデザイナーの友達がいます。大きな会社で働いています。夢の仕事です。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Wow. That is cool. I want to work in that kind of business. Maybe on the creative side. Not the technical side.', 'すごい。かっこいいですね。そんなビジネスで働きたいです。創造的な方かな。技術的な方ではなく。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I understand. I have the same issue. I am not sure which side to choose. Creative or business.', 'わかります。同じ悩みがあります。どっちの側を選ぶかわかりません。創造かビジネスか。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Let us not think about that for now. We have another hour. Want to play a quick game? I have cards in my bag.', '今は考えないでおきましょう。あと1時間あります。簡単なゲームしませんか？かばんにカードがあります。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Sure. But first, tell me about your head. I mean, your plans. What do you want to study?', 'いいですね。でもまず、計画を教えて。何を勉強したいですか？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'I want to study business. My father has a company. Maybe I will join him. But I need to learn English first.', 'ビジネスを勉強したいです。父に会社があります。一緒にやるかもしれません。でもまず英語を学ぶ必要が。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good plan. I want to work in service. Maybe a hotel or travel. I like to help people. That is the main issue for me.', 'いい計画ですね。サービス業で働きたいです。ホテルとか旅行かな。人を助けるのが好き。それが私の主な課題です。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You are a kind person. I can tell. I think we can be good friends. Same interests, same goals.', '優しい人ですね。わかります。いい友達になれそう。同じ興味、同じ目標。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I think so too. Let us exchange numbers. We can study together or play a game sometime. Maybe next week?', '私もそう思います。番号を交換しましょう。一緒に勉強したりゲームしたり。来週とか。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Yes. I would like that. This was a good hour. I learned a lot. Thank you for the kind words.', 'はい。ぜひ。いい1時間でした。たくさん学びました。親切な言葉をありがとう。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'You are welcome. I had fun too. See you next time. Good luck with your business studies.', 'どういたしまして。私も楽しかったです。またね。ビジネスの勉強頑張って。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thanks. You too. Take care. Bye!', 'ありがとう。あなたも。気をつけて。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye! It was nice to meet you. See you soon.', 'バイバイ。会えて嬉しかったです。また近いうちに。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye!', 'バイバイ。' FROM conv4;
