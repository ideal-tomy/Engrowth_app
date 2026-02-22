-- 3分ストーリー: 飛行機（5本目）
-- 使用単語: place, single, rule, daughter, administration, south, floor, either, husband, Congress, campaign
-- theme_slug: flight | situation_type: common | theme: 飛行機

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '到着後の案内',
    '飛行機到着後、乗り継ぎゲートや荷物受取を尋ねる会話。',
    3,
    30
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '到着後の質問', '乗り継ぎを聞く', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '乗り継ぎの案内', 'ゲートまでの道順', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '荷物受取の案内', 'バゲージクレーム', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '出口の案内', 'タクシー乗り場', 'common', '飛行機'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. We just arrived from the north. Connecting flight to the south. Where do we go? My husband and daughter are with me.', 'すみません。北から到着しました。南行き乗り継ぎ。どこへ？夫と娘が一緒です。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. Do you have checked bags? The rule is you need to collect them first. Then recheck for the south flight. Or go direct to the gate if no bags.', 'ようこそ。預け荷物は？ルールでは先に受け取ること。それから南行きに再チェック。荷物なしならゲート直行。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'We have two bags. So collect first. Where is baggage claim? Which floor? The administration said something about a shuttle. Either walk or ride?', '2つ預けました。だから先に受け取り。バゲージクレームは？何階？運営がシャトルと言ってた。歩くか乗るか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Baggage is on floor one. Follow the signs. South direction. The shuttle runs every five minutes. Or it is a ten-minute walk. Either way works.', '荷物は1階。看板に従って。南方向。シャトルは5分おき。歩いて10分。どちらでも。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We will walk. Need to stretch. Long flight. My daughter is tired. Single parent for this leg. Husband stayed home. Congress next week for him.', '歩きます。ストレッチが必要。長いフライト。娘は疲れてる。この区間は単独。夫は家に。来週コングレスで。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Floor one. South. You will see carousel five. Your flight number. Place your bags on the cart. Free. Near the exit. Then recheck at counter seven.', '1階。南。5番のキャロセルが見える。あなたの便名。カートに荷物を。無料。出口近く。それから7番カウンターで再チェック。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Counter seven. Got it. Is there a place to eat? We are hungry. Campaign for delayed flights? Any vouchers?', '7番カウンター。わかりました。食べる場所は？お腹が空いた。遅延便のキャンペーン？ヴァウチャーは？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'The cafe is on floor two. South side. Part of our customer campaign. Show your boarding pass. Ten percent off. Rule for connecting passengers.', 'カフェは2階。南側。顧客キャンペーンの一部。搭乗券を提示。10%オフ。乗り継ぎ客のルール。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. We have two hours. Time for a meal. Single parent and a child. Need energy. South flight is at four. Gate?', 'いいですね。2時間ある。食事の時間。一人親と子供。エネルギー必要。南行きは4時。ゲートは？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Gate B20. Floor two. South terminal. Same as your arrival. Easy. Follow the green line. Administration puts signs everywhere. You will find it.', 'B20ゲート。2階。南ターミナル。到着と同じ。簡単。緑の線に従って。運営が看板をたくさん。見つかる。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Green line. B20. Floor two. South. Perfect. One more thing. Taxi to the Congress center? After our south flight. Where do we go?', '緑の線。B20。2階。南。完璧。もう一つ。コングレスセンターへのタクシー？南行きの後。どこへ？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Exit on floor one. South exit. Taxi rank. The rule is use the official rank. No private cars. Safe. Fair price. Congress center is twenty minutes.', '1階の出口。南出口。タクシー乗り場。ルールは公式乗り場を。私車なし。安全。公正価格。コングレスセンターは20分。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thank you. The administration here is helpful. We fly this route often. Your campaign for families is good. Daughter travels free. Saves us money.', 'ありがとう。ここの運営は親切。この路線よく飛ぶ。家族向けキャンペーンは良い。娘は無料。節約になる。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Thank you. We try. Safe travels. South flight. Congress. Enjoy. Have a good trip.', 'ありがとう。努力しています。良い旅を。南行き。コングレス。楽しんで。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. Goodbye.', 'ありがとう。さようなら。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye.', 'さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks again.', 'もう一度ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Anytime.', 'いつでも。' FROM conv4;
