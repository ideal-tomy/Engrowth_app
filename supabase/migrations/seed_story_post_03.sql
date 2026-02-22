-- 3分ストーリー: 郵便局・宅急便（3本目）
-- 使用単語: fly, interview, manage, bit, candidate
-- theme_slug: post | situation_type: student | theme: 郵便局・宅急便

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '書留で重要な書類を送る',
    '卒業証明書などの重要書類を書留で送る手続きを郵便局で行う会話。',
    3,
    73
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '書留の相談', 'オプション', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金と日数', '確実性', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '受取人署名', '配達証明', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '発送', 'お礼', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need to send documents. Important. Interview materials for university. I am a candidate. They must fly safe. I need to manage for on-time. A bit nervous.', 'こんにちは。書類を送りたい。重要。大学用面接資料。候補者。安全に飛ばす必要。時間通りに管理。少し緊張。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Registered mail best for documents. Candidate papers. Flies secure. We manage and track. Bit extra cost. Worth it. Interview depends on it.', '書留がベスト。候補者書類。安全に飛ぶ。管理追跡。少し追加。価値ある。面接に依存。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Registered mail. How fast does it fly? Manage the deadline? Interview in two weeks. As candidate I need it to arrive. Bit of buffer.', '書留。どれくらい速く飛ぶ？締め切り管理？面接2週間後。候補者として到着必要。少しバッファ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Express. It flies in five days. We manage the time. A bit more cost. For candidate documents we give priority. Interview is critical. Worth every penny.', '速達。5日で飛ぶ。時間を管理。少しもっとコスト。候補者書類は優先。面接は決定的。すべてのペニーの価値。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Five days. I can manage. Bit tight. But OK. As candidate documents fly express. Interview chance important.', '5日。管理できる。少しきつい。でもOK。候補者として書類は速達で飛ぶ。面接チャンス重要。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Form is here. Put the candidate name and address. Manage the recipient details. Be a bit careful with spelling. It must fly correct. University may reject wrong name.', '用紙はここ。候補者名と住所。受取人を管理。スペルに少し注意。正しく飛ぶ必要。大学は間違った名前を却下。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Signature on delivery? Can we manage proof? A bit reassuring. Interview materials are expensive. To fly a replacement is hard. As a candidate I need a backup.', '配達時の署名？証拠は管理できる？少し安心。面接資料は高価。代替を飛ばすのは難しい。候補者としてバックアップが必要。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Signature confirmation. We manage record. Bit extra. Free. Express includes it. Fly with peace of mind. Candidate secure.', 'はい。署名確認。記録を管理。少し追加。無料。速達に含む。安心して飛ぶ。候補者安全。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. You manage it well. I am a bit stressed. Interview. As a candidate it is competitive. Documents must fly perfect. Good.', 'ありがとう。うまく管理する。少しストレス。面接。候補者として競争的。書類は完璧に飛ぶ必要。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'You are welcome. We manage tracking online. Bit of update daily. Documents fly with status. As candidate relax. Check anytime.', 'どういたしまして。オンラインで追跡管理。少し毎日アップデート。書類は状況と飛ぶ。候補者としてリラックス。いつでもチェック。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'What is the total? Can I manage the cost? I am on a bit of a budget. As a student candidate I pay what is necessary. Interview future is worth it.', '合計は？コストは管理できる？少し予算内。学生候補者として必要分払う。面接の未来は価値ある。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Thirty five for express. Documents fly. We manage the total. A bit high but for candidate documents it is safe. Interview depends on it. Good investment.', '35で速達。書類は飛ぶ。合計を管理。少し高いが候補者書類は安全。面接はそれに依存。良い投資。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thirty five. I can manage that. OK. A bit of a stretch. But as a candidate the interview chance is important. Documents must arrive. I pay gladly.', '35。管理できる。OK。少し無理だが候補者として面接チャンスは重要。書類は到着 must。喜んで払う。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Here is your receipt. We manage tracking. Check with a bit of patience. Documents fly five days. As a candidate relax. Interview prep. Documents are on the way.', '領収書。追跡を管理。少し忍耐でチェック。書類は5日で飛ぶ。候補者としてリラックス。面接準備。書類は途中。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. You manage the service well. I am a bit relieved. As a candidate my documents fly safe. Interview hope. Success. Bye.', 'ありがとう。サービスをうまく管理。少し安心。候補者として書類は安全に飛ぶ。面接の希望。成功。バイバイ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Manage your luck. A bit of advice. As a candidate go to the interview with confidence. Fly high. Documents will arrive. Success is certain.', 'バイバイ。運を管理。少しのアドバイス。候補者として自信を持って面接へ。高く飛ぶ。書類は到着。成功は確実。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I manage my thanks. I am a bit grateful. As a candidate your help was big. Interview chance. Documents fly safe. Good.', 'バイバイ。感謝を管理。少し感謝。候補者として助けは大きい。面接チャンス。書類は安全に飛ぶ。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Take care. Good luck with your interview.', 'バイバイ。お気をつけて。面接頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Manage well. Bit by bit. As a candidate the journey flies forward. Thank you.', 'バイバイ。うまく管理。少しずつ。候補者として旅は前へ飛ぶ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good day to you.', 'バイバイ。よい一日を。' FROM conv4;
