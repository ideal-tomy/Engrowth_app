-- 3分ストーリー: 学生・新職場自己紹介（1本目）
-- 使用単語: view, relationship, town, road, arm, true, federal, difference, value, international, building, action
-- theme_slug: selfintro_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '新プロジェクトでの自己紹介',
    '新しいプロジェクトチームに配属され、同僚に自己紹介する会話。経験と意気込みを伝える。',
    3,
    16
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と名前', 'オフィスで自己紹介を始める', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '経験とスキル', 'これまでの仕事と強み', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '価値観と目標', '仕事への思いと目標', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の連携', 'チームとの関係づくり', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi everyone. I am new to the team. My name is Saki. I just moved to this building last week. Nice to meet you all.', '皆さんこんにちは。チームに新しく入りました。咲希と申します。先週このビルに移ってきました。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Saki. So you are from a different town? I heard we have a new member. This is an international project.', 'ようこそ咲希さん。別の町から？新しいメンバーがいると聞いていました。これは国際プロジェクトです。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. I used to work in a small town. A federal office actually. Different from here. This building is much bigger.', 'はい。小さな町で働いていました。連邦オフィスでした。こことは違います。このビルはずっと大きい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'The road to this project was long. We are glad you joined. What is your view on the work we do here?', 'このプロジェクトへの道のりは長かった。参加してくれて嬉しい。ここでの仕事についてどうお考えですか？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I think the value of international work is huge. Building relationships across borders. That is my view. I want to learn more.', '国際的な仕事の価値は大きいと思います。国境を越えた関係を築く。それが私の見方です。もっと学びたい。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Good. So what experience do you have? We need people who can take action. Not just ideas.', 'いいですね。経験は？行動できる人が必要です。アイデアだけじゃなく。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I worked on federal projects before. Policy and research. I learned to work with different teams. The difference was always in the people.', '以前連邦プロジェクトで働きました。政策とリサーチ。様々なチームと働くことを学びました。違いはいつも人にありました。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'That is true. So you have an arm in research. We could use that. Our team lacks that side.', 'それは本当ですね。リサーチの腕があるわけだ。役に立つかも。私たちのチームにはそちらが不足している。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I hope to help. I value teamwork. A good relationship with colleagues is important. I will do my best.', 'お役に立てれば。チームワークを大事にしています。同僚との良い関係が重要。最善を尽くします。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We like that. The action we need now is to finish the report. Can you join the meeting tomorrow?', 'いいですね。今必要な行動はレポートを仕上げること。明日の会議に参加できる？' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Of course. What time? I want to be ready. My view is that good preparation makes a difference.', 'もちろん。何時ですか？準備しておきたい。良い準備が差をつけるのが私の見方です。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Nine in the morning. Same building. Third floor. We will show you the road. The meeting room is near the arm of the corridor.', '朝9時。同じビル。3階。道は案内します。会議室は廊下の突き当たり近くです。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thank you. I value clear direction. The federal office was different. Everything was according to strict rules.', 'ありがとう。明確な指示を大事にします。連邦オフィスは違いました。全て厳格なルールに従って。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Here we are more flexible. But we still need action. Ideas are good. Execution is better. True for any project.', 'ここはもっと柔軟です。でも行動は必要。アイデアはいい。実行がより良い。どのプロジェクトにも当てはまる。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I agree. I learned that in my old town. Small office. Big responsibility. The value of each action was clear.', '同感です。古い町で学びました。小さなオフィス。大きな責任。各行動の価値が明確だった。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'We need that mindset. The international side of this project is growing. We want people who see the whole picture.', 'その考え方が必要です。このプロジェクトの国際側は拡大中。全体像が見える人が欲しい。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I hope to build that view. A good relationship with the team will help. I am ready to learn. Ready for action.', 'その見方を築きたい。チームとの良い関係が助けになる。学ぶ準備はできています。行動する準備も。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. One more thing. The building has a cafe on the first floor. We sometimes meet there. Less formal. Good for relationships.', 'いいですね。もう一つ。ビル1階にカフェがあります。時々そこで会います。カジュアルに。関係づくりにいい。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will check it out. Thank you for the welcome. I feel at home already. Different town. Same goal.', '行ってみます。歓迎ありがとう。もう居心地がいい。違う町。同じ目標。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Welcome to the team. See you tomorrow. Goodbye.', 'チームへようこそ。明日また。さようなら。' FROM conv4;
