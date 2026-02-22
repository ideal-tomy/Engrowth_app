-- 3分ストーリー: プレゼンテーション②（5本目）
-- 使用単語: manage, perform, bit, candidate
-- theme_slug: presentation2 | situation_type: business | theme: プレゼンテーション②

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'チーム紹介と役割分担',
    'プロジェクトチームのメンバーと役割を紹介し、協力体制を説明するプレゼンの練習。',
    3,
    65
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'チームの紹介', 'メンバー', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '役割の説明', '各担当', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '実績の共有', '過去の成果', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '連携体制', 'コミュニケーション', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Let me introduce our team. We manage this project. Four people. Each performs a role. A bit different but complementary. Our candidate selection was rigorous.', 'チームを紹介する。このプロジェクトを管理。4人。それぞれ役割を演じる。少し違うが相補的。候補者選択は厳格だった。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Four people to manage the whole project? A bit small, no? Can they perform enough?', '4人で全体のプロジェクトを管理？少し小さいのでは？十分演じられる？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'A bit lean, yes. But our candidate quality is high. Each performs multiple roles. We manage time well. We have a proven track record.', '少しリーン。でも候補者の品質は高い。それぞれ複数役割を演じる。時間をうまく管理。実績あり。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'How did candidate selection work? Did they perform an assessment? How did you manage the process? I am a bit curious.', '候補者選択はどう？アセスメントを演じた？プロセスをどう管理？少し興味。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We manage interviews. Five rounds. Each candidate must perform tasks in real scenarios. A bit tough. But we find the best. They manage pressure well.', '面接を管理。5ラウンド。候補者は実シナリオでタスクを演じる必要。少し厳しい。でも最高を見つける。プレッシャーをうまく管理。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'What roles does each perform? What does each manage? Specifically?', 'それぞれどんな役割を演じる？何を管理？具体的に？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Slide thirty. Person one manages technical. Performs design and a bit of development. Our candidate is an expert in both. Person two manages client relations. Performs communication and a bit of sales.', 'スライド30。1人目は技術を管理。デザインと少し開発を演じる。候補者は両方のエキスパート。2人目はクライアント管理。コミュニケーションと少し営業を演じる。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'A bit of overlap is good. They can perform backup. That helps manage risk. The candidate sounds flexible. Cross training.', '少し重複はいい。バックアップを演じられる。リスク管理に。候補者は柔軟。クロストレーニング。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Exactly. Person three manages budget. Performs finance and a bit of admin. Our candidate has a strong CPA. Person four manages timeline. Performs coordination and a bit of PM.', 'その通り。3人目は予算管理。財務と少しadminを演じる。候補者は強いCPA。4人目はタイムライン管理。調整と少しPMを演じる。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Four people manage key areas. They perform together. A bit of each. Strong candidates. Good team.', '4人が主要エリアを管理。一緒に演じる。それぞれ少しずつ。強い候補者。いいチーム。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Past performance on slide thirty one. Last project. We managed similar scope. The team performed above target. A bit ahead of schedule. Same candidates. Eighty percent of the team.', '過去のパフォーマンスはスライド31。前プロジェクト。似たスコープを管理。目標以上を演じた。スケジュールより少し前。同じ候補者。チームの80パーセント。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Eighty percent same team. That helps manage continuity. Perform is proven. A bit reassuring. Our candidates are a known quantity.', '80パーセント同じチーム。継続性の管理に。実証済みの演じ方。少し安心。候補者は知られた量。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Yes. We manage expectations. We perform and deliver. A bit more each time. Our candidates have a growth mindset.', 'はい。期待を管理。演じて届ける。毎回少しずつ。候補者は成長マインドセット。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'How do we manage communication? How do they perform? A bit more detail? Cadence?', 'コミュニケーションはどう管理？どう演じる？少し詳細を？リズムは？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Daily stand up. We manage progress. Each performs updates. A bit short. Fifteen min. Each candidate is present. Weekly deep dive to manage risks and perform review.', '毎日スタンドアップ。進捗を管理。それぞれアップデートを演じる。少し短く15分。候補者は全員出席。週次で深掘り、リスク管理とレビューを演じる。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. The manage structure is clear. They perform strong. I am a bit more confident. Good candidates. Good team. Understood.', 'ありがとう。管理構造は明確。演じ方は強い。少し自信が湧いた。いい候補者。いいチーム。理解した。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Summary. We manage four areas. We perform as one team. A bit of flexibility. Our candidates are top quality. Thank you.', 'サマリー。4エリアを管理。チームとして演じる。少しの柔軟性。候補者は最高品質。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Any questions? Do we manage concerns? Can you perform and answer? A bit now?', '質問は？懸念を管理？演じて答えられる？少し今？' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Yes. We manage Q and A. We perform our best. A bit more time. All candidates are ready.', 'はい。Q&Aを管理。ベストを演じる。少し時間を。候補者全員準備済み。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Manage well. Perform for success. Bit by bit. We trust the candidates. Good.', 'バイバイ。うまく管理。成功のために演じる。少しずつ。候補者を信頼。いい。' FROM conv4;
