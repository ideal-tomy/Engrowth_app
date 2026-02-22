-- 3分ストーリー: 交通機関（5本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: transport | situation_type: common | theme: 交通機関

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'タクシー乗り場で相乗りを相談',
    'タクシー乗り場で相乗りや料金について運転手や係員に尋ねる会話。',
    3,
    50
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '乗り場を探す', 'タクシーエリア', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金の確認', 'メーターか定額か', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '到着の見込み', '所要時間', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '乗車', 'お礼', 'common', '交通機関'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. Where is the taxi stand? I need to get to the hotel. Do not want to miss check in. Stage one. Arrive. Stage two. Rest.', 'すみません。タクシー乗り場はどこ？ホテルへ行く必要。チェックインを逃したくない。段階1。到着。段階2。休息。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Taxi stand. That way. Left. Authority managed. Official. Safe. Low crime. Licensed drivers. Good design. Clear signs. You cannot miss it.', 'タクシー乗り場。あちら。左。当局管理。公式。安全。犯罪少ない。許可運転手。良いデザイン。明確な看板。逃さない。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Ok. How much? To the Central Hotel? Fixed price? Or meter? I want to compare. Financial. Budget. Do not want to overpay.', 'OK。いくら？セントラルホテルへ？定額？メーター？比較したい。財務。予算。払いすぎたくない。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Meter. Usually thirty to forty. Depends on traffic. Operation of taxis. Authority regulated. No crime. Fair price. Compare to Uber. Same. Maybe cheaper.', 'メーター。通常30から40。交通次第。タクシー運用。当局規制。犯罪なし。公平な価格。 Uberと比較。同じ。安いかも。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thirty to forty. Ok. My strategy. Taxi to hotel. Quick. Tired. Long flight. Then rest. Meeting tomorrow. 9 AM. Cannot miss.', '30から40。OK。戦略。タクシーでホテル。早く。疲れた。長いフライト。休息。明日会議。9時AM。逃せない。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Taxi is good. Direct. No stops. Compare to train. Slower. More stations. Taxi. Door to door. Your strategy. Right choice.', 'タクシーはいい。直行。止まらない。電車と比較。遅い。駅が多い。タクシー。ドア to ドア。戦略。正しい選択。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'How long? To Central Hotel? Traffic? Rush hour? I landed at 5 PM. Sort of late. Tired. Want to rest.', 'どのくらい？セントラルホテルまで？交通？ラッシュ？5時PMに着陸。わりと遅い。疲れた。休みたい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Twenty minutes. Maybe thirty. Rush hour. Traffic. Operation of roads. Busy. But ok. You will get there. Authority manages traffic. Sometimes slow.', '20分。30分かも。ラッシュ。交通。道路運用。混雑。でも大丈夫。着く。当局が交通管理。時々遅い。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Twenty to thirty. Ok. I can wait. In the taxi. Rest. Compare to walking. Impossible. Luggage. Taxi. Best strategy.', '20から30。OK。待てる。タクシーで。休息。徒歩と比較。無理。荷物。タクシー。最高の戦略。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Taxi stand. This way. Queue. Authority design. Fair. First come. First serve. No crime. Safe. Licensed. Official.', 'はい。タクシー乗り場。こちらへ。列。当局デザイン。公平。先着順。犯罪なし。安全。許可。公式。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I see the queue. Sort of long. But moving. Operation seems smooth. How many taxis? Station busy. Many people.', '列が見える。わりと長い。でも動いてる。運用はスムーズそう。タクシー何台？駅混雑。人が多い。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Many taxis. Constant. Authority ensures. Enough for demand. Financial. Good for city. Tourists. Business. You will not miss one. Fast.', 'タクシー多い。絶えず。当局が確保。需要に十分。財務。街にいい。観光客。ビジネス。逃さない。速い。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good. My stage one. Get taxi. Stage two. Ride to hotel. Stage three. Check in. Rest. Strategy clear. Almost there.', 'いい。段階1。タクシーに乗る。段階2。ホテルへ。段階3。チェックイン。休息。戦略明確。もうすぐ。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Next in line. You. Taxi coming. Compare to other cities. This station. Good. Clean. Safe. Low crime. Authority care. You will see.', '次の番。あなた。タクシーが来る。他都市と比較。この駅。いい。きれい。安全。犯罪少ない。当局の配慮。わかる。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thanks. The info. The design. Helpful. Sort of lost. First time. But ok now. Clear. Will not miss the hotel.', 'ありがとう。情報。デザイン。助かる。わりと迷ってた。初めて。でも今は大丈夫。明確。ホテルを逃さない。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Central Hotel. Tell the driver. Clear. He will know. Operation. Daily. Same route. Many times. Expert.', 'セントラルホテル。運転手に伝えて。明確。わかる。運用。毎日。同じルート。何度も。熟練。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I will. Thanks. Financial. Good value. Meter. Fair. Authority. Trust. Ok. Bye.', '伝える。ありがとう。財務。良い価値。メーター。公平。当局。信頼。OK。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye. Safe ride. Rest well. Meeting tomorrow. 9 AM. Do not miss. Stage two. Work. Good luck.', 'バイバイ。安全な乗車。よく休んで。明日会議。9時AM。逃さないで。段階2。仕事。頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks. Strategy set. Taxi. Hotel. Rest. Tomorrow. Meeting. Compare to stress. Better. Clear plan.', 'ありがとう。戦略確定。タクシー。ホテル。休息。明日。会議。ストレスと比較。マシ。明確なプラン。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
