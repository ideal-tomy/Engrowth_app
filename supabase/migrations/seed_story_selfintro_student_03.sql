-- 3分ストーリー: 学生・新職場自己紹介（3本目）
-- 使用単語: full, model, season, society, tax, director, early, position, player, record, paper, special
-- theme_slug: selfintro_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'NPOでの初出勤',
    '社会福祉団体に転職し、スタッフに自己紹介する会話。',
    3,
    18
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と経歴', '事務所で自己紹介', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '動機とスキル', 'この業界を選んだ理由', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '役割と目標', '新しいポジションの理解', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'チームワーク', '今後の協力', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hello everyone. I am Miku. I joined the society this season. My position is program coordinator. Nice to meet you all.', '皆さんこんにちは。美空です。今期この団体に加わりました。ポジションはプログラムコーディネーターです。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Miku. I am the director of operations. We read your paper. Your record in youth work is strong. We need that.', 'ようこそ美空さん。運営のディレクターです。履歴書を読みました。青少年支援の記録が素晴らしい。それが必要なんです。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I started early today. I wanted to see the full picture. How does the society run? What is the model?', 'ありがとう。今日は早く出てきました。全体像を見たかった。団体はどう運営されていますか？モデルは？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We use a community model. Every staff is a player. We work with local groups. Tax exempt of course. We are an NPO.', 'コミュニティモデルを使っています。全スタッフがプレイヤー。地域団体と協力。もちろん免税。NPOです。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I understand. My last job was similar. But smaller. Here the impact is full. I am excited about this special role.', 'わかりました。前の仕事も似ていました。でも小さかった。ここではインパクトがフル。この特別な役割にワクワクしています。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'What drew you to our society? The paper said you had corporate experience. Why the switch?', '私たちの団体に惹かれた理由は？履歴書に企業経験があった。なぜ転向？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I wanted to give back. The corporate model was not for me. I need work with meaning. This position feels right. Early in my career I volunteered. That stayed with me.', '還元したかった。企業モデルは自分に合わなかった。意味のある仕事が必要。このポジションは正しいと感じる。キャリアの早い時期にボランティアをした。それが心に残った。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good. We need people with that heart. The director of programs will train you. She has a special way with new staff. You will learn the record quickly.', 'いいですね。その心を持つ人が必要です。プログラムのディレクターがトレーニングします。新人に特別なやり方がある。記録を早く学べる。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I am ready. I have studied your annual reports. The paper work. I know the numbers. But I want to learn the people. The full story.', '準備できています。年次報告書を勉強しました。書類。数字は知っています。でも人を学びたい。全体像を。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'That is the right attitude. We are not just paper. We are people. The society runs on relationships. You will see.', '正しい姿勢です。書類だけじゃない。人です。団体は関係で動く。わかるよ。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'When does the next season start? I want to be full speed by then. What projects are coming?', '次の期はいつ始まりますか？その時までにフルスピードになりたい。どんなプロジェクトが？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Next month. We have three programs. Your position will support all three. You are the key player for coordination. No one else has that role.', '来月。3つのプログラムがあります。あなたのポジションは3つすべてをサポート。調整のキープレイヤー。他にその役割の人はいない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I see. So I am the link. Between the director and the teams. I like that. Full involvement.', 'なるほど。つまり私がリンク。ディレクターとチームの間。好きです。フルに関与。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Exactly. The tax filing season is busy. We need someone who can handle paper. Grants. Reports. You have that record.', 'その通り。税申告の期は忙しい。書類を扱える人が必要。助成金。報告書。その記録がある。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I do. I managed grants at my old job. Full responsibility. I can do the same here. Maybe better. This work matters more.', 'あります。以前の仕事で助成金を管理していました。フル責任。ここでも同じことができます。もっと良くかも。この仕事の方が重要。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'We are glad to have you. The society needs fresh energy. Your special mix of skills is rare. Corp experience. Nonprofit heart.', '来てくれて嬉しい。団体に新しいエネルギーが必要。あなたの特別なスキルミックスは珍しい。企業経験。非営利の心。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. I will do my best. I came early to show that. I want to be a full member of the team. Not just on paper.', 'ありがとう。最善を尽くします。それを示すために早く来ました。チームのフルメンバーになりたい。紙の上だけでなく。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. The director will introduce you to everyone. We have a small team. But we do big work. You will fit in. Welcome.', 'いいですね。ディレクターが皆に紹介する。小さいチームだけど大きな仕事をしている。フィットするよ。ようこそ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I look forward to it. This is a special day for me. New position. New season. New start. Thank you.', '楽しみにしています。私にとって特別な日です。新しいポジション。新しい期。新しいスタート。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'See you at the team meeting. Tomorrow nine. Goodbye.', 'チームミーティングで。明日9時。さようなら。' FROM conv4;
