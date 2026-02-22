-- 3分ストーリー: 交通機関（2本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: transport | situation_type: common | theme: 交通機関

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'バス停で行き先を確認',
    'バス停で運転手や他の乗客に行き先、料金、乗り換えを尋ねる会話。',
    3,
    47
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'バス停で待つ', '路線の確認', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金を聞く', '支払い方法', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '乗車', '降りる場所', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '到着', 'お礼', 'common', '交通機関'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. Is this the right stop? For the airport? I do not want to miss my flight. First stage of my trip. Important.', 'すみません。このバス停で合ってます？空港行き？飛行機を逃したくない。旅行の第一段階。重要。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. This is the right stop. Airport bus. Every thirty minutes. Operation is regular. Compare to train. Slower. But cheaper. Good financial choice.', 'はい。正しいバス停。空港バス。30分おき。運用は定期的。電車と比較。遅い。でも安い。良い財務選択。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Ok. How much? Cash? Card? The design of the fare system. I am confused. Different from my country.', 'OK。いくら？現金？カード？料金制度のデザイン。混乱してる。自国と違う。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Fifteen dollars. Cash or card. Driver takes both. Authority of the transit. Official. Safe. Low crime on this route. Tourists use it.', '15ドル。現金かカード。運転手が両方受け付ける。運輸当局。公式。安全。この路線は犯罪少ない。観光客が使う。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Fifteen. Ok. How long? To the airport? I have a strategy. Arrive two hours early. Security. Check in. Do not miss flight.', '15。OK。どのくらい？空港まで？戦略がある。2時間前に到着。セキュリティ。チェックイン。飛行機を逃さない。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'About forty minutes. Depends on traffic. Sort of reliable. Compare to taxi. Same time. But taxi is fifty. Financial. Bus is better.', '約40分。交通次第。わりと信頼できる。タクシーと比較。同じ時間。でもタクシーは50。財務。バスがお得。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I will take the bus. When is the next one? I do not want to miss it. Stage one. Get to airport. Stage two. Fly. Stage three. Arrive.', 'バスに乗る。次の便はいつ？逃したくない。段階1。空港へ。段階2。飛行。段階3。到着。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Ten minutes. Bus will come. Red. Big. Airport design. Hard to miss. Station name on the side. Authority logo. Official bus.', '10分。バスが来る。赤。大きい。空港デザイン。逃しにくい。側面に駅名。当局ロゴ。公式バス。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. I will wait. The station here. Safe? At night? I might come back late. Flight at 11 PM. Return trip.', 'いい。待つ。ここの駅。安全？夜？遅く戻るかも。11時PMの便。帰り。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Ok. Safe area. Low crime. Authority patrols. Sort of busy. Tourists. Workers. Operation runs until midnight. You will be ok.', 'OK。安全なエリア。犯罪少ない。当局パトロール。わりと賑やか。観光客。労働者。運用は深夜まで。大丈夫。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Here is the bus. Red. Airport. I see it. Good strategy. Early. No stress. Will not miss my flight.', 'バスだ。赤。空港。見える。良い戦略。早め。ストレスなし。飛行機を逃さない。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Get on. Front door. Pay the driver. Card or cash. Fifteen. They will tell you. When to get off. Airport. Last stop. Cannot miss it.', '乗って。前ドア。運転手に支払い。カードか現金。15。教えてくれる。どこで降りるか。空港。最終。逃さない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Last stop. Simple. Compare to the train. More stops. More confusing. Bus is clear. Good design. Straight forward.', '最終。シンプル。電車と比較。駅が多い。紛らわしい。バスは明確。良いデザイン。 straightforward。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Bus operation is simple. One route. Airport. That is it. Authority runs it. Reliable. Financial. Good for tourists. Save money.', 'はい。バス運用はシンプル。1路線。空港。それだけ。当局が運営。信頼できる。財務。観光客にいい。節約。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thanks. I will get on. Stage one complete. Waiting. Stage two. Ride. Stage three. Airport. Strategy works.', 'ありがとう。乗る。段階1完了。待機。段階2。乗車。段階3。空港。戦略は機能する。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Good luck. Safe trip. Do not miss your flight. Bye.', '頑張って。安全な旅を。飛行機を逃さないで。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye. Thank you for the help. The station. The info. Sort of confusing. But you made it ok. Clear now.', 'バイバイ。助けてくれてありがとう。駅。情報。わりと紛らわしい。でも大丈夫にした。今は明確。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Compare routes. Bus is best. Financial. For airport. Trust me.', 'どういたしまして。路線を比較。バスがベスト。財務。空港用。信じて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I do. Thanks. Authority info. Official. Good. Bye.', '信じる。ありがとう。当局情報。公式。いい。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
