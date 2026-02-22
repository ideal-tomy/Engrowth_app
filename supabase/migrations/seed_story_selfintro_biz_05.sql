-- 3分ストーリー: ビジネス自己紹介（5本目）
-- 使用単語: control, care, field, check, role, better, economic, strong, possible, heart, leader
-- theme_slug: selfintro_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '経営層への自己紹介',
    '取締役会で新しいマネージャーが、リーダーとしての役割と経済的貢献を伝える会話。',
    3,
    15
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と役割', '取締役会で自己紹介', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'リーダー経験', 'これまでのリーダーシップ', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '経済的成果', 'チームの貢献と成果', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の計画', 'より良くするための方針', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning. I am Lisa. I am the new leader for the operations team. Thank you for this chance to introduce myself.', 'おはようございます。リサです。オペレーションチームの新しいリーダーです。自己紹介の機会をありがとうございます。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Lisa. We need a strong leader. The field has changed. We want to hear your plan. What is your role?', 'ようこそリサ。強いリーダーが必要です。現場が変わった。計画を聞きたい。あなたの役割は？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'I control the day-to-day operations. I check the process. My job is to make everything better. With care for the team.', '日々のオペレーションを統括しています。プロセスをチェックします。全てをより良くするのが仕事です。チームへのケアを持って。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. The economic pressure is strong. We need better results. Is it possible to improve this quarter?', 'いいですね。経済的圧力は強い。より良い結果が必要。今四半期の改善は可能か？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Yes. I have a plan. The heart of it is control. We check each step. We find the weak points. Then we fix them.', 'はい。計画があります。その中心は統制です。各ステップをチェック。弱点を見つける。そして修正する。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'What experience do you have as a leader? We need someone who can drive change.', 'リーダーとしての経験は？変革を推進できる人が必要です。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I led a team of twenty before. In the same field. We improved the process. The economic return was strong.', '前に20人のチームを率いました。同じ分野で。プロセスを改善しました。経済的リターンは大きかった。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'That sounds like the right role. We care about results. But we also care about people. Can you balance both?', 'それが正しい役割のようですね。結果を大事にします。でも人も大事にする。両方バランスできるか？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I believe so. A good leader has to have a heart for the team. But we also need to check the numbers. Both matter.', 'そう信じています。良いリーダーはチームへの心を持たなければ。でも数字もチェックする必要がある。両方重要です。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We want better control of costs. Can you do that without losing the team?', 'コストのより良い統制が欲しい。チームを失わずにできるか？' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Yes. It is possible. The key is to involve the team. They know the field. They have the ideas. We listen. We improve together.', 'はい。可能です。鍵はチームを巻き込むこと。彼らは現場を知っている。アイデアがある。聞く。一緒に改善する。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'That is a strong approach. The economic gains from engaged teams are real. We have seen the data.', 'それは強いアプローチですね。関与したチームからの経済的成果は本当です。データを見てきた。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'My role as leader is to create that space. Care for people. Check the process. Control the waste. Better outcomes for everyone.', 'リーダーとしての役割はその場を作ること。人へのケア。プロセスのチェック。無駄の統制。皆により良い結果。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We like what we hear. One more check. Can you start next week? We need a leader in the field right away.', '聞いたことに満足しています。もう一つの確認。来週始められるか？現場にリーダーがすぐ必要です。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Yes. I am ready. I will meet the team. We will have a strong start. I give you my word.', 'はい。準備できています。チームに会います。強いスタートを切ります。約束します。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Good. Welcome aboard. We expect better results. But we also expect you to care for the team. That is our culture.', 'いいですね。おかえりなさい。より良い結果を期待している。でもチームへのケアも期待する。それが私たちの文化です。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I understand. The heart of good leadership is care. Control without care does not work. I have learned that.', '理解しています。良いリーダーシップの中心はケアです。ケアのない統制は機能しない。それを学びました。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'We are glad to have you. The economic outlook is tough. But with strong leaders like you we can do better.', '来てくれて嬉しい。経済見通しは厳しい。でもあなたのような強いリーダーがいればより良くできる。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. I will do my best. Check in with me in a month. You will see progress.', 'ありがとう。最善を尽くします。1ヶ月後にチェックしてください。進捗が見えます。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'We will. Good luck. Goodbye.', 'そうします。頑張って。さようなら。' FROM conv4;
