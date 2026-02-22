-- 3分ストーリー: プレゼンテーション①（4本目）
-- 使用単語: sound, enjoy, network, legal, form, final, main
-- theme_slug: presentation1 | situation_type: business | theme: プレゼンテーション①

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'プロジェクト概要の共有',
    '新規プロジェクトの背景と目的を関係者に説明するプレゼンの練習。',
    3,
    59
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'プロジェクトの背景', 'なぜ今か', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '目的の明確化', 'ゴール設定', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'スコープの説明', '何を対象とするか', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '次のステップ', 'アクションアイテム', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good morning. Today I will form the overview of our new project. Main points: background, goals, scope, next steps. Sound good?', 'おはよう。本日、新プロジェクトの概要を形成。要点は背景、目標、スコープ、次のステップ。いい？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. The main point is why now? Legal or regulatory? We need context to form the picture.', 'はい。要点はなぜ今か。法務？規制？文脈が必要。絵を形成。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Slide two. New legal requirements. We must form our compliance. Main driver. We network with authorities and stay aligned.', 'スライド2。法務要件は新規。コンプライアンス形成が必須。主な原動力。当局とネットワークし整合。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Legal as the main driver does sound serious. What about the timeline? Do we have a form for the final deadline?', '法務が主な原動力とは真剣ですね。タイムラインは？最終日の形式は？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'December is our final deadline. We form and submit our report to the regulator by then. It is a main milestone. We enjoy the challenge but it is tight.', '12月が最終締め切り。形式を整えて規制当局に提出。主なマイルストーン。楽しむがきつい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'What are the main goals? Can you form them in a clear way? We need goals that sound achievable.', '目標は主に3つ？形式は明確に。達成可能に聞こえる必要。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Goal one: full legal compliance. We form and complete the checklist. Main priority. Goal two: streamline and network our systems. Goal three: training so the team is ready.', '目標1は法務コンプライアンス。チェックリスト形成・完了。最優先。目標2は効率化とネットワーク。目標3は訓練。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'The three main goals are clear. The form looks good. Legal, process, training. We enjoy the structure. It is logical.', '3つの主な目標は明確。形式はいい。法務、プロセス、訓練。構造を楽しむ。論理的。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Slide five scope. Main areas: finance, HR, operations. We form the core network across all departments. Final: one integrated system.', 'スライド5のスコープ。財務、人事、オペレーション。全部署で中核ネットワーク形成。最終は統合システム。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'All departments in one big network. That is complex. What about the legal implications? Does each area need its own form for contracts?', '全部署が大きなネットワーク。複雑。法務の含意は？それぞれ形式や契約？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Yes. Each area has a legal review. We update each form and contract. It is a main task. We have a checklist that must be final before we go live.', 'はい。法務レビューはそれぞれ。形式と契約を更新。主なタスク。稼働前に最終チェックリストあり。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'A checklist is good. The form follows our standard. The main items are clear. It all sounds organized.', 'チェックリストはいい。形式は標準。主要項目は明確。整理されて聞こえる。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'For the next steps we form teams with main owners for each area. We network through weekly syncs. The final go live is in December. That is our main date.', '次のステップでチーム形成、各エリアに主なオーナー。週次同期でネットワーク。最終稼働は12月。主な日付。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Weekly sync is good. We enjoy the collaboration. Building the network across departments is a main benefit of this project.', '週次同期はいい。コラボレーションを楽しむ。部署横断のネットワークが主なメリット。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Exactly. Final slide summary. Main points: legal, process, training. Network brings us together. We form one team. December deadline. We enjoy the journey.', 'その通り。最終スライドサマリー。要点は法務、プロセス、訓練。ネットワークで一つに。1チーム形成。12月締め切り。旅を楽しむ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. The main message is clear. The form and structure look good. Legal focus sounds right. The timeline is tight but achievable.', 'ありがとう。主なメッセージは明確。形式と構造はいい。法務の焦点は正しく聞こえる。タイムラインはきついが達成可能。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Questions now? Form your thoughts. Main concerns? We can discuss here. The whole network is in this room.', '質問は今？考えを形成。主な懸念は？ここで議論。皆揃っている。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Later, if you do not mind. I will form my questions after I review the slides and main points. I will reply by email.', '後で、よければ。スライドと要点をレビューして質問を形成する。メールで返信する。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good. One final note. The materials are shared on the network drive. The form for access goes to all of you tomorrow. Please enjoy the review.', 'いい。最終注記。資料はネットワークドライブで共有。アクセス形式は明日全員へ。レビューを楽しんで。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Thank you again. The main points are clear. The form was good. Goodbye.', 'ありがとう。主なポイントは明確。形式はよかった。バイバイ。' FROM conv4;
