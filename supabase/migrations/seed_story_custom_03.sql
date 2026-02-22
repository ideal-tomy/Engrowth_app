-- 3分ストーリー: カスタム（3本目）
-- 使用単語: fly, interview, manage, bit, candidate
-- theme_slug: custom | situation_type: common | theme: カスタム

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '弱点の特定',
    'コンサルタントが弱点を特定し、優先順位をつける会話。',
    3,
    83
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '現状の確認', 'どこが難しいか', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '優先順位', '何から手をつけるか', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '目標設定', '3ヶ月後', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'アクションプラン', 'お礼', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'I have an interview next month. I fly to HQ. I need to manage my nerves. A bit scared. I am a candidate for promotion. Need stronger English. Can custom prep help?', '来月面接。本社へ飛ぶ。緊張を管理。少し怖い。昇進の候補者。英語がもっと必要。カスタム準備で助け？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Interview prep our specialty. We help you fly high. Manage anxiety bit by bit. Candidates ready. Custom program has mock interviews. We manage fear.', '面接準備が特長。高く飛ぶのを助ける。不安を少しずつ管理。候補者準備。カスタムにモック面接。恐れを管理。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Mock interview. Do we manage it like real? A bit intense? As a candidate I practice. Do I fly with confidence?', 'モック面接。本番みたいに管理？少し集中的？候補者として練習。自信で飛ぶ？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. Manage like the real thing. Bit of pressure. We prepare candidates. You fly to actual day. Manage better. Custom feedback after. Bit detailed.', 'はい。本番みたいに管理。少しプレッシャー。候補者準備。実際の日に飛ぶ。 better 管理。後でカスタムフィードバック。少し詳細。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I need to manage my schedule. It is a bit tight. As a candidate I have one month. Is that enough to fly? Can I manage the time?', 'スケジュールを管理する必要。少しきつい。候補者として1ヶ月。飛ぶのに十分？時間を管理できる？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We manage intensive program. Bit aggressive. As candidate you can fly. Progress fast. Four sessions per week. Committed candidates fly to success.', '集中プログラム管理。少し積極的。候補者として飛べる。進捗速い。週4回。コミットした候補者は成功へ。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Four sessions. Can I manage that? A bit much? As a candidate I work full time. Do I have fly time? Can we manage evening?', '4回。管理できる？少し多い？候補者としてフルタイム。飛ぶ時間ある？夕方を管理？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'We manage flexibly. A bit in the evening. For candidates we do 7 PM. We fly online. We manage from home. A bit easy. Custom to your pace.', '柔軟に管理。少し夕方。候補者には7時PM。オンラインで飛ぶ。自宅から管理。少し簡単。あなたのペースにカスタム。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'That manages well. I am a bit relieved. As a candidate it fits. I can fly with that schedule. I manage my life. Thank you.', 'うまく管理する。少し安心。候補者として合う。そのスケジュールで飛べる。生活を管理。ありがとう。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'First session. Bit tomorrow. For you as candidate. 7 PM. I fly you the link. Manage email. Bit of prep. Think about strengths. Fly in ready. We discuss.', '最初のセッション。少し明日。候補者として。7時PM。リンクを飛ばす。メール管理。少し準備。強みを考える。準備して飛んで。議論。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Strengths. Hard for me to manage. Bit. As candidate I am modest. Japanese culture we fly different. How manage to sell myself?', '強み。管理が難しい。少し。候補者として控えめ。日本文化では違って飛ぶ。自分を売る管理は？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We manage that. Common. Bit cultural. As candidate you learn. Fly American style. Manage assertive. Bit of practice. Candidates get comfortable. Fly with your achievements.', 'それを管理。一般的。少し文化的。候補者として学ぶ。アメリカスタイルで飛ぶ。アサーティブ管理。少し練習。候補者は快適に。成果で飛ぶ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'You manage custom approach. Bit cultural. As candidate I want to bridge. Fly both styles. Manage to stay authentic. Thank you.', 'カスタムアプローチを管理。少し文化的。候補者として橋をかけたい。両方のスタイルで飛ぶ。本物を管理。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We manage the goal. Bit clear. As candidate for interview you fly confident. Manage toward promotion. Bit closer. Custom plan works. Goodbye.', '目標を管理。少し明確。面接候補者として自信で飛ぶ。昇進を管理。少し近い。カスタムプラン機能。バイバイ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. I manage my thanks. I am a bit grateful. As a candidate I feel ready. I will fly high. I manage my nerves. Thank you.', 'バイバイ。感謝を管理。少し感謝。候補者として準備。高く飛ぶ。緊張を管理。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Manage your luck. A bit of advice. As a candidate breathe. Fly calm. Manage for success. Take care.', 'バイバイ。運を管理。少しのアドバイス。候補者として呼吸。落ち着いて飛ぶ。成功を管理。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I manage for tomorrow. A bit of prep. As a candidate I work on strengths. I fly with confidence. Thank you.', 'バイバイ。明日を管理。少し準備。候補者として強みに取り組む。自信で飛ぶ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Good luck with your interview.', 'バイバイ。面接頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. I manage my hope. A bit of success. As a candidate for promotion. I fly soon. Good.', 'バイバイ。希望を管理。少しの成功。昇進の候補者として。 soon 飛ぶ。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
