-- 3分ストーリー: 病院（2本目）
-- 使用単語: evening, treat, trip, structure, politics
-- theme_slug: hospital | situation_type: student | theme: 病院

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '受付で保険を提示',
    '病院の受付で保険証を提示し、問診票に記入する会話。',
    3,
    77
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '受付で', '保険証提示', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '問診票', '記入の説明', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '待合室', '順番を待つ', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '呼ばれる', '診察室へ', 'student', '病院'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good morning. I have an appointment at 9 AM. What is the structure of the visit? It is my first time. The politics of the health system might be different. How do you treat me as a patient? I took a trip from Japan.', 'おはよう。9時AMの予約。受診の構造は？初めて。医療制度の政治は違う？患者として扱う？日本から旅行。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. We treat you now. The structure is simple. Politics of our form. First we take a quick trip through. Your insurance card please. We treat and verify.', 'ようこそ。今扱う。構造はシンプル。用紙の政治。まず速い旅行を通る。保険証お願い。扱って確認。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Insurance is here. What is the structure for a travel policy? The politics of international trip coverage? Do you treat students? Is it valid?', '保険はこれ。旅行ポリシーの構造は？国際旅行カバレッジの政治？学生を扱う？有効？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. We treat that as fine. The structure is common. Politics of many students who trip abroad. We treat the same policy. We need a copy for the file.', 'はい。大丈夫として扱う。構造は一般的。海外へ旅行する学生の政治。同じポリシーを扱う。ファイル用にコピー必要。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'A form? What is the structure? Politics of medical? Trip history? Do you treat it as long?', '用紙？構造は何？医療の政治？旅行履歴？長いとして扱う？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Two pages. The structure is simple. Politics of the form. Name, address, symptoms. Trip timeline. We treat when it started. Production of info is quick.', '2ページ。構造はシンプル。用紙の政治。名前、住所、症状。旅行タイムライン。いつ始まったか扱う。情報の生産は速い。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Symptoms. The structure. Throat pain. Politics of two days. Trip. Do I have fever? You treat slight. Production of mucus. Yes.', '症状。構造。のどの痛み。2日の政治。旅行。熱ある？微かとして扱う。痰の生産。はい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Take a seat. The structure is the waiting room. Politics of calling your name. We treat your turn. The trip is about twenty minutes. Evening shift. Doctor is busy.', 'お座り。構造は待合室。名前を呼ぶ政治。順番を扱う。旅行は約20分。夕方シフト。医師は忙しい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Evening shift? Is the structure different? Politics of the morning doctor? Do you treat the same? Trip concern?', '夕方シフト？構造は違う？午前医師の政治？同じように扱う？旅行の心配？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'No. We treat the same quality. The structure is our team. Politics of sharing notes. Trip continuity. Our evening doctor is good. We treat well.', 'いいえ。同じ品質で扱う。構造はチーム。メモ共有の政治。旅行の継続性。夕方医師はいい。よく扱う。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. The structure is clear. Politics. I relax. My trip to wait. You treat patients. Good.', 'ありがとう。構造は明確。政治。リラックス。待つ旅行。患者を扱う。いい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Is the form complete? Please treat and bring it when we call. Structure and order. Politics of the doctor. We need trip info before we treat you.', '用紙は完了？呼ばれた時に持ってくる。構造と順序。医師の政治。扱う前に旅行情報が必要。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Complete. The structure. All politics sections. Trip medical. I treat it honest. Production of details. Good.', '完了。構造。すべての政治セクション。旅行医療。正直に扱う。詳細の生産。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. Structure of your wait. Politics. Relax. The trip is short. We treat. Magazine over there. Evening. Coffee machine in the corner.', 'いい。待ちの構造。政治。リラックス。旅行は短い。扱う。雑誌はあそこ。夕方。角にコーヒーマシン。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. The structure is comfortable. Politics clean. Trip pleasant. You treat well. Good. Bye for now.', 'ありがとう。構造は快適。政治はきれい。旅行は心地よい。よく扱う。いい。一旦バイバイ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'We will call you. Structure soon. Politics of order. Trip is FIFO. We treat fair. Evening shift is quick often. Good.', '呼ぶ。構造は soon。政治の順序。旅行は先着順。公平に扱う。夕方シフトはよく速い。いい。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Structure understood. Politics. I wait. Trip ready. Treat by doctor soon. Thank you.', 'バイバイ。構造は理解。政治。待つ。旅行準備。医師に soon 扱われる。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Good luck. Get well. We treat with care.', 'バイバイ。頑張って。お大事に。ケアで扱う。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. The structure was good. Politics helpful. Trip was smooth. I appreciate how you treat. Thank you.', 'バイバイ。構造はよかった。政治は有益。旅行はスムーズ。扱い方に感謝。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
