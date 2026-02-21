-- 3分ストーリー: 職場での朝の挨拶
-- Engrowthアプリ英単語データ（単語51-100）を使用
-- 使用単語例: people, year, room, want, come, look, use, way, take, thing, give, work, find, day, tell, help, thing, way, room, good, two, new

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '職場での朝の挨拶',
    'オフィスで同僚と朝会った時の挨拶と世間話。ビジネスシーンで使えるフレーズを学べます。',
    3,
    2
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '朝の出会い', 'オフィスの廊下で会う', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '週末の話', '週末の予定を聞く', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '仕事の相談', '今日の仕事について軽く話す', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '別れと午後の約束', '席に戻る前に午後の打ち合わせを確認', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning! You look good today. Did you have a nice weekend?', 'おはよう。元気そうだね。週末は良かった？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Morning! Yes, thanks. I went to the park. Two years now I''ve been going there—good way to start the day.', 'おはよう。ええ、ありがとう。公園に行ってきたよ。もう2年通ってる。いい1日の始まり方だよ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'That sounds nice. I want to do something like that too. People say it helps.', 'それは良さそうだね。私もそういうことやってみたいな。体にいいって聞くし。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yeah. Come with me sometime. We could go together.', 'うん。いつか一緒に来ない？二人で行けるよ。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I''d like that. Thanks!', 'ぜひ。ありがとう。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'So, any plans for this weekend?', '今週末は何か予定ある？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Not yet. I need to find a new room. My lease is up. It''s the only thing on my mind now.', 'まだないの。新しい部屋を探さなくちゃ。契約が切れるんだ。今そればかり考えてる。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Oh, I can help with that. I know a guy. Let me give you his number.', 'ああ、それなら助けられるかも。知り合いがいて。電話番号教えるよ。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Really? That would be great. I''ll take any help I can get.', '本当？助かる。どんな助けでもありがたいよ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'No problem. I''ll tell you more when we have time. Maybe at lunch?', '大丈夫。時間あるときにもっと話すよ。昼飯のときとか。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'By the way, do you have the report? I need to use it for the meeting.', 'ところで、レポート持ってる？会議で使いたいの。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes, it''s in my room. I can bring it. When is the meeting?', 'うん、部屋にある。持ってくるよ。会議いつだっけ？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'This afternoon. We have work to do before that. A lot of things to go over.', '午後だよ。その前にやることある。確認すべきことがたくさん。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Right. Well, let me get the report first. I''ll find it and come to your desk.', '了解。じゃあ先にレポート取ってくる。見つけてあなたの机まで持ってくるよ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thanks. That would save me some time. I have a busy day today.', 'ありがとう。時間の節約になる。今日は忙しい日なの。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Okay, I''ll see you in a bit. Oh, and don''t forget—we have that call at three.', 'じゃあ、またすぐ会おう。あ、忘れずに—3時にあの電話あったよね。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Right, the call. I have it on my calendar. Good thing you said something.', 'そう、あの電話。カレンダーに入れてある。言ってくれて助かった。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'No problem. Have a good morning. Catch you later!', '大丈夫。良い午前中を。あとでね。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'You too. See you!', 'あなたもね。また。' FROM conv4;
