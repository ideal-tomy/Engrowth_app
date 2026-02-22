-- 3分ストーリー: カスタム（5本目）
-- 使用単語: treat, trip, evening, establish
-- theme_slug: custom | situation_type: common | theme: カスタム

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '長期プランの確認',
    '3ヶ月後の目標と学習プランの最終確認をする会話。',
    3,
    85
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '目標の再確認', '3ヶ月後', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'マイルストーン', '月ごと', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'サポート体制', 'いつ相談できるか', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'スタート', 'お礼', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Three months for the plan. Do you treat me as realistic? Is it a trip to fluency? Are evening sessions enough? Can I establish a routine?', '3ヶ月のプラン。現実的として扱う？流暢への旅？夕方セッションは十分？ルーティンを開設できる？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'We establish the goal. We treat it as achievable. The trip is step by step. Evening sessions are consistent. We establish habit. We treat three months. The trip gives solid foundation. Evening practice. We establish confidence.', '目標を開設。達成可能として扱う。旅はステップごと。夕方は一貫。習慣を開設。3ヶ月を扱う。旅がsolidな基盤。夕方練習。自信を開設。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Do we establish milestones? Treat monthly? Can we trip and track? Evening review? Do we establish progress?', 'マイルストーンを開設？月次として扱う？旅して追跡できる？夕方レビュー？進捗を開設？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We establish month one. We treat the basics. Trip vocabulary. Evening core. We establish month two. We treat conversation. Trip to fluency. Evening practice. We establish month three. We treat real scenarios. Trip application. Evening mastery.', '1ヶ月目を開設。基礎を扱う。語彙の旅。夕方コア。2ヶ月目を開設。会話を扱う。流暢さへの旅。夕方練習。3ヶ月目を開設。実際のシナリオを扱う。応用の旅。夕方習得。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We establish it clear. You treat it as a roadmap. The trip is exciting. Evening to start? When do we establish?', '明確に開設。ロードマップとして扱う。旅はワクワク。夕方から開始？いつ開設？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We establish tonight. We treat it as the first session. The trip begins. Evening 7 PM. We establish the link. I treat and email it now. Trip. Evening. Are you ready?', '今夜開設。最初のセッションとして扱う。旅が開始。夕方7時PM。リンクを開設。今メールで扱う。旅。夕方。準備？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I establish I am ready. You treat me excited. The trip begins. Evening I am free. I establish my commitment. You treat me as serious. Thank you.', '準備だと開設。ワクワクとして扱う。旅が開始。夕方は空いてる。コミットメントを開設。真剣として扱う。ありがとう。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'We establish support. We treat always. Trip stuck? Evening message us. We establish response. We treat within 24 hours. On your trip you are never alone. Custom care.', 'サポートを開設。いつも扱う。旅で詰まった？夕方メッセージ。返信を開設。24時間で扱う。旅で決して一人じゃない。カスタムケア。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'That establishes reassurance. You treat with support. The trip gives confidence. Evening comfort. We establish a partnership. You treat it as real. Good.', '安心を開設。サポートで扱う。旅が自信を。夕方の快適さ。パートナーシップを開設。本当として扱う。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We establish the summary. We treat the plan. Trip three months. Evening sessions. We establish milestones. We treat monthly. Trip support. Evening always. We establish. Start tonight. Goodbye.', 'サマリーを開設。プランを扱う。旅は3ヶ月。夕方セッション。マイルストーンを開設。月次で扱う。旅サポート。夕方はいつも。開設。今夜開始。バイバイ。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Goodbye. I establish my thanks. You treat it clear. The trip and plan. Evening 7 PM. I establish I am ready. Thank you.', 'バイバイ。感謝を開設。明確に扱う。旅とプラン。夕方7時PM。準備だと開設。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Goodbye. We establish for success. We treat the journey. Enjoy your trip. Evening learning. We establish it as fun. Take care.', 'バイバイ。成功のために開設。旅を扱う。旅行を楽しんで。夕方の学習。楽しいと開設。お気をつけて。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Goodbye. We establish a partnership. You treat it as valuable. The trip moves forward. Evening I am excited. Good.', 'バイバイ。パートナーシップを開設。価値あるとして扱う。旅は前へ。夕方ワクワク。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Goodbye. Good luck. We establish goals. We treat to achieve. Your trip to success. Evening soon.', 'バイバイ。頑張って。目標を開設。達成として扱う。成功への旅。夕方 soon。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. I establish I am grateful. You treat with custom. The trip and plan. Evening we start. Thank you.', 'バイバイ。感謝だと開設。カスタムで扱う。旅とプラン。夕方開始。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. See you this evening at 7 PM. We establish the session. We treat it as productive. Your trip to fluency. Good.', 'バイバイ。夕方7時PMで。セッションを開設。生産的として扱う。流暢への旅。いい。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I establish I am confident. You treat the plan right. The trip. Evening I am ready. Thank you.', 'バイバイ。自信だと開設。プランを正しく扱う。旅。夕方準備。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. We establish soon. You treat tonight. The trip begins. Good day.', 'バイバイ。 soon 開設。今夜を扱う。旅が開始。よい一日を。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good day to you.', 'バイバイ。よい一日を。' FROM conv4;
