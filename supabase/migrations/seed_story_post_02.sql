-- 3分ストーリー: 郵便局・宅急便（2本目）
-- 使用単語: pain, apply, measure, wide, shake
-- theme_slug: post | situation_type: student | theme: 郵便局・宅急便

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '追跡と再配達の依頼',
    '届かなかった荷物の追跡と再配達の手配を宅配業者に依頼する会話。',
    3,
    72
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '問い合わせ', '荷物の状況', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '追跡結果', '現在地の確認', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '再配達', '日時の指定', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認', 'お礼', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. Pain. My package did not arrive. How do I apply for redelivery? Measure of stress high. I shake when I think lost. Wide concern.', 'こんにちは。痛い。荷物届かなかった。再配達の申請は？ストレス高い。紛失と思うと震える。幅広い心配。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'No problem. Apply online or here. Measure your tracking number? Wide range of options. Shake off worry. We help resolve the pain.', '問題ない。オンラインかここで申請。追跡番号は？幅広いオプション。心配を振り払って。痛み解決。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'My tracking number is here. I apply for redelivery. Can you measure how long? Is it a wide network? I shake with hope it comes soon. Pain is I need the package. Books for my course.', '追跡番号はこれ。再配達を申請。どのくらいか計れる？幅広いネットワーク？すぐ届く希望で震える。痛みは荷物が必要。授業の本。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Let me check. One moment. I measure the system with our wide data. I shake my head. Found it. Pain relief. Your package is at the depot. Missed delivery yesterday.', '確認する。少々。幅広いデータでシステムを計る。首を振る。見つかった。痛みの安堵。荷物はデポに。昨日配達逃した。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'At the depot. The pain is gone. Measure of relief is high. Wide smile. Can I apply for redelivery now? Shake hands. Thank you.', 'デポに。痛みは消えた。安堵の程度は高い。幅広い笑顔。今再配達を申請できる？握手。ありがとう。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Apply with this form here. I measure the time slots. We have wide choice. Tomorrow morning or afternoon. Shake and pick one. Pain will be minimal. Short wait.', 'ここで用紙に申請。時間枠を計る。幅広い選択。明日午前か午後。選んで。痛みは最小。待ちは短い。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Tomorrow afternoon. I apply for that. I measure I will be home then. A wide window from 2 to 5. I shake my schedule around it. Pain is flexible. Good.', '明日午後。それに申請。その時在宅と計る。2時から5時の幅広い窓。予定を合わせる。痛みは柔軟。いい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Apply is complete. I measure the confirmation. We offer wide support. Shake with confidence. Pain is over. Your package tomorrow afternoon. Bye.', '申請完了。確認を計る。幅広いサポート。自信で震える。痛みは終わり。荷物は明日午後。バイバイ。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. The measure of your service is excellent. Wide range. I shake with gratitude. Pain has turned to joy. I will apply again if I need. Bye.', 'ありがとう。サービスの程度は素晴らしい。幅広い範囲。感謝で震える。痛みが喜びに。必要ならまた申請。バイバイ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care. Good day to you.', 'バイバイ。お気をつけて。よい一日を。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'One more thing. Can I measure status and check? Apply for notification? Do you have wide options? Shake my phone for an alert? I do not want pain of missing again.', 'もう一つ。状況を計ってチェックできる？通知の申請？幅広いオプション？電話を震えさせるアラート？また逃す痛みを避けたい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. You apply for SMS or email. We measure updates. Wide coverage. Shake off worry. Pain free mind. We alert you on delivery day. Morning alert.', 'はい。SMSかメールに申請。アップデートを計る。幅広いカバレッジ。心配を振り払う。痛みフリーの心。配達日にアラート。朝のアラート。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Perfect. The measure of communication is a wide net. I shake off anxiety. Pain is reduced. Apply everything done. Thank you.', '完璧。コミュニケーションの程度は幅広い網。不安を振り払う。痛みは軽減。すべて申請完了。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You are welcome. Measure of success. Wide smile. Shake hands. Pain is gone. Package is coming. Good. Bye.', 'どういたしまして。成功の程度。幅広い笑顔。握手。痛みは消えた。荷物は来る。いい。バイバイ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Bye. The measure of my gratitude is wide. Heart full. I shake with relief. Pain is a memory now. Thank you. Staff help was big.', 'バイバイ。感謝の程度は幅広い。心がいっぱい。安堵で震える。痛みは今は思い出。ありがとう。スタッフの助けは大きい。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. The measure of our care is wide service. Shake with confidence. Pain resolved fast. Good day.', 'バイバイ。ケアの程度は幅広いサービス。自信で震える。痛みは速く解決。よい一日を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Good day. Measure of thanks is wide. Appreciation. Shake hands. Pain relief. Package tomorrow. Bye.', 'よい一日を。感謝の程度は幅広い。感謝。握手。痛みの安堵。荷物は明日。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Measure of success. Wide smile. Shake off the stress. Pain is over. Take care.', 'バイバイ。成功の程度。幅広い笑顔。ストレスを振り払う。痛みは終わり。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. The measure of your help is wide. Thank you. Shake with gratitude. Pain is gone. Good.', 'バイバイ。助けの程度は幅広い。ありがとう。感謝で震える。痛みは消えた。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good luck with your package.', 'バイバイ。荷物頑張って。' FROM conv4;
