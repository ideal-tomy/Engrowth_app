-- 3分ストーリー: 交通機関（3本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: transport | situation_type: common | theme: 交通機関

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '電車の遅延で乗り換えを尋ねる',
    '電車が遅延しているため、別の路線への乗り換え方法を駅員に尋ねる会話。',
    3,
    48
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '遅延の確認', '状況を聞く', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '代替ルート', '別の路線', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '乗り換え駅', 'どこで乗り換えるか', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '到着予定', 'お礼', 'common', '交通機関'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. The screen says delay. Twenty minutes. I have a meeting. I will miss it. What can I do? Different strategy?', 'すみません。画面に遅延。20分。会議がある。間に合わない。どうすれば？別の戦略？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Sorry. Signal problem. Operation issue. Authority is fixing it. We have an alternative. Change at North station. Different line. Faster. Maybe.', '申し訳ない。信号障害。運用問題。当局が修理中。代替がある。ノース駅で乗り換え。別の線。速いかも。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'North station. How do I get there? From here? I am lost. The design of this station. So many lines. Sort of confusing.', 'ノース駅。どう行く？ここから？迷ってる。この駅のデザイン。線が多すぎ。わりと紛らわしい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Platform 7. Green line. Two stops. North. Then change. Blue line. Your destination. Compare to waiting. Ten minutes faster. Maybe. Worth it.', '7番ホーム。緑線。2駅。ノース。そこで乗り換え。青線。目的地。待つより比較。10分速いかも。価値あり。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Ok. I will try. Do not want to miss the meeting. Financial. Important client. Stage one. Get there. Stage two. Present. Stage three. Deal.', 'OK。試す。会議を逃したくない。財務。重要クライアント。段階1。到着。段階2。プレゼン。段階3。契約。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Platform 7. Now. Train in three minutes. Green line. North station. Clear signs. Authority design. You cannot miss it.', '7番ホーム。今。3分で電車。緑線。ノース駅。はっきりした看板。当局デザイン。逃さない。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Three minutes. Ok. I will run. Strategy change. Original plan. Delayed line. New plan. Green then blue. Adapt.', '3分。OK。走る。戦略変更。元のプラン。遅延線。新プラン。緑から青。適応。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good. Operation on green line. On time. No delay. Blue line too. Smooth. Low crime in North station. Safe. You will be ok.', 'いい。緑線の運用。時間通り。遅延なし。青線も。スムーズ。ノース駅は犯罪少ない。安全。大丈夫。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. Compare to staying here. Waiting. Stressing. Better to move. Action. New strategy. Feels ok.', 'いい。ここにいるより比較。待つ。ストレス。動く方がマシ。行動。新戦略。大丈夫そう。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'You are right. Sort of common. Delays happen. Authority handles it. Alternative routes. Part of the operation. We try.', 'その通り。わりとよくある。遅延は起こる。当局が対処。代替路線。運用の一部。努力してる。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thanks. Platform 7. Green. Two stops. North. Then blue. My new strategy. Will not miss the meeting. I hope.', 'ありがとう。7番。緑。2駅。ノース。次青。新戦略。会議を逃さない。願わくば。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'You will make it. Green line. Reliable. Station to station. Fast. Design for commuters. Financial district. Business people. Same situation.', '間に合う。緑線。信頼できる。駅から駅。速い。通勤者向けデザイン。金融地区。ビジネスパーソン。同じ状況。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good. I am one of them. Business person. Meeting. Cannot miss. Authority of my boss. Strict. Must be on time.', 'いい。その一人。ビジネスパーソン。会議。逃せない。上司の権威。厳しい。時間厳守。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Understood. Platform 7. Go now. Train coming. Sort of full. But you will fit. Rush hour. Normal operation.', '了解。7番。今行って。電車が来る。わりと満員。でも乗れる。ラッシュ。通常運用。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Going. Thank you. The delay. Your help. New strategy. Appreciate it. Bye.', '行く。ありがとう。遅延。助け。新戦略。感謝。バイバイ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Bye. Good luck. Compare routes. You chose well. Green then blue. Faster. You will not miss it.', 'バイバイ。頑張って。路線比較。良い選択。緑から青。速い。逃さない。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thanks. I hope. Financial meeting. Big deal. Stage one. Get there. Fingers crossed.', 'ありがとう。願ってる。財務会議。大きな取引。段階1。到着。祈ってる。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You will. Authority runs on time. Green line. Best in the city. Reliable. Safe. Low crime. Good design. Trust the system.', '大丈夫。当局は時間通り。緑線。街で最高。信頼できる。安全。犯罪少ない。良いデザイン。システムを信じて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I do. Thanks again. Station was chaos. Delay. But you helped. New strategy. Clear. Ok now.', '信じる。またありがとう。駅は混沌。遅延。でも助けてくれた。新戦略。明確。今は大丈夫。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care. Good meeting.', 'バイバイ。お気をつけて。良い会議を。' FROM conv4;
