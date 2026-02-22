-- 3分ストーリー: 病院（1本目）
-- 使用単語: discover, candidate, production, treat, trip
-- theme_slug: hospital | situation_type: student | theme: 病院

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '病院で予約を入れる',
    '体調不良のため病院に電話で予約を入れる会話。',
    3,
    76
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '電話で予約', '症状の説明', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '日時の選択', '空き状況', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '準備するもの', '保険証など', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認', 'お礼', 'student', '病院'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I need an appointment. I discover. Sick. Two days. Throat. Pain. Candidate. For. Flu? Maybe. Trip. Abroad. Last week. Production. Of. Mucus. Heavy.', 'こんにちは。予約が必要。発見した。体調悪い。2日。のど。痛み。候補者。風邪？かも。旅行。海外。先週。生成。痰。多い。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'I see. We treat. Throat. Issues. Discover. Doctor. Available. Candidate. Slots. Tomorrow. Production. Schedule. Busy. But. Can. Fit. Treat. You.', 'なるほど。扱う。のど。問題。発見。医師。利用可能。候補者。枠。明日。生産。スケジュール。忙しい。でも。対応。扱う。あなた。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Tomorrow. Good. Discover. Worse. Today. Trip. To. Class. Hard. Production. Of. Voice. Difficult. Treat. Soon. Please.', '明日。いい。発見。悪化。今日。旅行。授業へ。大変。生成。声の。難しい。扱う。早く。お願い。' FROM conv1
UNION ALL SELECT id, 'B', 4, '9 AM. Or. 2 PM. Candidate. Slots. Treat. Early. Better? Discover. Rest. Production. Of. Recovery. Faster. Trip. To. Health.', '9時AM。2時PM。候補者。枠。扱う。早い。better？発見。休息。生産。回復の。速い。旅行。健康へ。' FROM conv1
UNION ALL SELECT id, 'A', 5, '9 AM. Treat. Morning. Discover. Rest. After. Production. Of. Energy. Low. Trip. Home. Sleep. Candidate. For. Rest. Yes.', '9時AM。扱う。朝。発見。休息。後。生産。エネルギー。低い。旅行。家。睡眠。候補者。休息。はい。' FROM conv1
UNION ALL SELECT id, 'B', 1, '9 AM. Tomorrow. Treat. Confirmed. Discover. Bring. Insurance. Card. Production. Of. ID. Passport. Trip. Document. Student. Card. Treat. Reception. First.', '9時AM。明日。扱う。確認済み。発見。持参。保険証。生産。ID。パスポート。旅行。書類。学生証。扱う。受付。まず。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Insurance. Discover. Have. Travel. Insurance. Trip. Abroad. Production. Of. Policy. At. Home. Treat. Bring. Copy?', '保険。発見。持ってる。旅行保険。旅行。海外。生産。ポリシー。家に。扱う。持ってくる。コピー？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Copy. Treat. Fine. Discover. Policy. Number. Production. Of. Details. Trip. Coverage. Treat. International. Students. Often.', 'はい。コピー。扱う。大丈夫。発見。ポリシー番号。生産。詳細。旅行。カバレッジ。扱う。留学生。よく。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. Discover. Helpful. Trip. First. Time. Production. Of. Visit. Treat. Nervous. But. Good. Info.', 'ありがとう。発見。有益。旅行。初めて。生産。受診。扱う。緊張。でも良い。情報。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Arrive. Fifteen. Minutes. Early. Treat. Paperwork. Discover. Form. Production. Of. Medical. History. Trip. First. Time. Treat. Need. Details.', '到着。15分。早く。扱う。書類。発見。用紙。生産。病歴。旅行。初めて。扱う。必要。詳細。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Medical history. Discover. Allergies? Production. Of. List? Treat. Important? Trip. Memory. Think. None. But. Check.', '病歴。発見。アレルギー？生産。リスト？扱う。重要？旅行。記憶。考える。なし。でも確認。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Treat. Important. Discover. Allergies. Production. Of. Reaction. Avoid. Trip. To. Emergency. Treat. Safe. Always.', 'はい。扱う。重要。発見。アレルギー。生産。反応。避ける。旅行。救急へ。扱う。安全。いつも。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Got it. Treat. Carefully. Discover. Notes. Production. Of. List. Tonight. Trip. Prepare. Good. Thank you.', '了解。扱う。慎重に。発見。メモ。生産。リスト。今夜。旅行。準備。いい。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, '9 AM. Tomorrow. Treat. Confirmed. Discover. Building. A. Production. Map. Email. Trip. Easy. Find. Good. Bye.', '9時AM。明日。扱う。確認済み。発見。建物。A。生産。地図。メール。旅行。簡単。見つける。いい。バイバイ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Bye. Treat. Well. Discover. Relief. Production. Of. Hope. Trip. To. Recovery. Soon. Thank you.', 'バイバイ。扱う。よく。発見。安堵。生産。希望。旅行。回復へ。 soon。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Bye. Treat. Yourself. Discover. Rest. Production. Of. Fluids. Trip. To. Better. Health. Take care.', 'バイバイ。扱う。自分。発見。休息。生産。水分。旅行。 better。健康へ。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye. Treat. Kind. Discover. Helpful. Production. Of. Good. Care. Trip. To. Clinic. Confident. Thank you.', 'バイバイ。扱う。親切。発見。有益。生産。良い。ケア。旅行。クリニックへ。自信。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye. Good luck. Get well.', 'バイバイ。頑張って。お大事に。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Treat. Tomorrow. Discover. Cause. Production. Of. Plan. Trip. To. Health. Good.', 'バイバイ。扱う。明日。発見。原因。生産。プラン。旅行。健康へ。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
