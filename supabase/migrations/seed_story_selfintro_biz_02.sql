-- 3分ストーリー: ビジネス自己紹介（2本目）
-- 使用単語: moment, air, teacher, force, education, foot, boy, age, policy, everything, process, music
-- theme_slug: selfintro_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '外部ネットワーキングでの自己紹介',
    '業界イベントで初対面の相手に、所属・役割・教育背景・貢献を簡潔に伝える会話。',
    3,
    12
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と名前', 'イベントで自己紹介を始める', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '教育背景と経歴', '学歴とキャリアの入口', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '役割とプロセス', '現在の業務と貢献', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '方針と今後の連絡', '社の方針と今後の協力', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hello. Nice to meet you. I wanted to take a moment to introduce myself. My name is Ken.', 'こんにちは。よろしくお願いします。少しお時間をいただいて自己紹介したくて。健と申します。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Hi Ken. Welcome. The air in this room is a bit stuffy. But it is a good event. So what do you do?', 'こんにちは健さん。ようこそ。この部屋の空気は少しこもっていますね。でもいいイベントです。何をされていますか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'I work in HR. New policy and training. I have been with the company for five years now. Since I was twenty-three.', '人事部門です。新しい方針と研修を担当しています。会社には5年勤めています。23歳の時からです。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Interesting. So you handle everything related to people? Training must be a big part.', '興味深いですね。人のこと全般を担当されているんですね。研修が大きな部分でしょう。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Yes. Education is our focus. We want to give every employee a good start. A solid foot in the door.', 'はい。教育が焦点です。全社員に良いスタートを。しっかりした足がかりを提供したいんです。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'I like that. What was your background before HR? Were you a teacher or something?', 'いいですね。人事以前の経歴は？先生とかされていたんですか？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'No. I was a boy who loved music. But I studied business in college. Then I joined this company. The force behind my choice was the people.', 'いいえ。音楽が好きな少年でした。でも大学でビジネスを学びました。そしてこの会社に入りました。選択の原動力は人でした。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'At this age you have a clear vision. That is rare. How do you design the training process?', 'この年齢で明確なビジョンを持っているのは珍しい。研修のプロセスはどう設計しているんですか？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'We listen first. Then we build step by step. Each program has a clear goal. We measure everything at the end.', 'まず聞きます。そして段階的に構築します。各プログラムに明確な目標があります。最後に全てを測定します。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Sounds like a good process. I might need your help one day. Our team could use better training.', '良いプロセスのようですね。いつかお力が必要かもしれません。うちのチームは研修がもっと要ります。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I would be happy to help. Our policy is to support all departments. We do not force a one-size-fits-all approach.', '喜んでお手伝いします。私たちの方針は全部門をサポートすることです。画一的なアプローチは押し付けません。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'That is the right way. Every team is different. Like music. Each band has its own sound.', 'それが正しいやり方ですね。チームごとに違う。音楽のように。バンドごとに音が違う。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Exactly. We adapt the training to the team. The education we provide has to fit. No wasted moment.', 'その通りです。研修をチームに合わせます。提供する教育は合致しなければ。無駄な瞬間はありません。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'I appreciate that. Time is precious. So who is your main contact in our division?', '感謝します。時間は貴重です。私たちの部門の窓口は誰ですか？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Sarah. She handles everything on the operations side. I can put you in touch. Would you like her email?', 'サラです。業務側の全てを担当しています。ご紹介できます。メールアドレスをお渡ししましょうか？' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Yes please. This has been a useful moment. I learned a lot about your process.', 'お願いします。役に立つ時間でした。あなたのプロセスについてたくさん学びました。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. I enjoyed our talk. Our company policy on networking is to build real connections. Not just business cards.', 'ありがとう。お話しできて嬉しかったです。当社のネットワーキング方針は本当のつながりを築くこと。名刺交換だけでなく。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'That is the right force. Good education starts with good people. I am glad we met.', 'それが正しい力ですね。良い教育は良い人から始まる。お会いできて嬉しいです。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Same here. I will send you Sarah''s contact. Enjoy the rest of the event. The air should get better after the break.', 'こちらこそ。サラの連絡先をお送りします。残りのイベントを楽しんでください。休憩後は空気も良くなると思います。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Thanks. Goodbye.', 'ありがとう。さようなら。' FROM conv4;
