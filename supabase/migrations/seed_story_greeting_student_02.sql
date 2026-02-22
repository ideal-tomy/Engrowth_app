-- 3分ストーリー: 国際交流イベントでの挨拶（2本目）
-- 使用単語: area, money, story, fact, month, lot, right, study, book, eye, job, word
-- theme_slug: greeting_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際交流イベントでの自己紹介',
    '国際交流イベントで趣味や勉強について話し合う。本や仕事の話を通じて仲を深める会話。',
    3,
    7
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '趣味の話', '本や読書の話で盛り上がる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '勉強と仕事', '学業や仕事について語る', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '地域や生活', '出身地域や生活費の話', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '別れと今後の約束', 'また会う約束をして別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! Nice to meet you. So what do you like to do? Do you read a lot?', 'こんにちは。会えて嬉しいです。趣味は何ですか？本をたくさん読みますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes, I love to read. I have a book with me right now. I study English through stories. It helps me learn new words.', 'はい、読むのが大好きです。今ちょうど本を持っています。物語を通じて英語を勉強しています。新しい単語を学べます。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'That is a good idea. What kind of story do you like? I read a lot of fact-based books. History and science.', 'いい方法ですね。どんな物語が好きですか？私は事実に基づく本をたくさん読みます。歴史や科学。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'I like fiction. But I also read for my job. I work in publishing. So I have to read a lot of books.', '小説が好きです。仕事でも読んでいます。出版の仕事をしているので、たくさんの本を読む必要があるんです。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Wow, that sounds like the right job for you. How long have you been here?', 'すごい、ぴったりの仕事ですね。こちらにはどのくらいいますか？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'About two months. I came to study and improve my English. I need it for my job. What about you?', '2ヶ月くらいです。勉強しに来て、英語を上達させたいんです。仕事に必要なんです。あなたは？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Six months. I study at the university in this area. I do part-time work too. I need money for books and rent.', '6ヶ月です。この地域の大学で勉強しています。アルバイトもしています。本や家賃にお金が必要なんです。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'I understand. Money is a fact of life when you study abroad. What is your job?', 'わかります。留学中のお金は現実的な問題ですね。どんな仕事をしていますか？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I work at a cafe. It is a lot of fun. I get to talk to people and practice my English. That is the right way to learn, I think.', 'カフェで働いています。とても楽しいです。人と話して英語の練習ができます。それが正しい学び方だと思います。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I agree. Speaking is the key. I want to find a job here too. Maybe for a month or two.', '同感です。話すことが鍵ですね。私もここで仕事を探したいです。1、2ヶ月ほど。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'What area are you from? I am from the north of Japan. It is a nice area. A lot of nature.', 'どちらの地域からですか？私は日本の北部です。いい地域です。自然がたくさん。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'I am from New York. Big city. Very different from here. I like this area. It is quiet. Good for study.', 'ニューヨークからです。大きな街。こことは全然違います。この地域が好きです。静かで。勉強にいいです。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Yes. And the people are kind. I learned a new word today from you. Thank you.', 'はい。それに人は親切です。今日あなたから新しい単語を学びました。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You are welcome. I like your eye for good books. We have that in common. Maybe we can go to a book shop together?', 'どういたしまして。いい本を見る目のいいですね。共通点があります。一緒に本屋に行きませんか？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'That would be great. I know a good one. Not far from here. It does not cost a lot of money.', 'いいですね。いい店を知っています。ここから遠くないです。お金もそんなにかかりません。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Perfect. How about next week? Same day, same time? I will bring a book to share. A good story.', '完璧です。来週はどうですか？同じ曜日、同じ時間で。共有する本を持ってきます。いい物語です。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I would like that. In fact, I have been looking for a study partner. You seem right for the job.', 'ぜひ。実は勉強仲間を探していたんです。あなたがぴったりのようです。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thank you. Well, I have to go. It was nice to meet you. See you next week. Keep up the good study!', 'ありがとう。では、行かなくては。会えて嬉しかったです。来週また。勉強頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'You too. Goodbye. I will see you at the book shop. Bye!', 'こちらこそ。さようなら。本屋で会いましょう。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye! Take care.', 'バイバイ。気をつけて。' FROM conv4;
