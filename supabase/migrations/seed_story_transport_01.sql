-- 3分ストーリー: 交通機関（1本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: transport | situation_type: common | theme: 交通機関

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '駅で切符の買い方を尋ねる',
    '海外の駅で電車の切符の買い方、行き先、乗り換えを駅員に尋ねる会話。',
    3,
    46
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '切符カウンター', '乗車券を買う', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '行き先の確認', 'どの電車に乗るか', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '乗り換え案内', 'プラットフォーム番号', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お礼と確認', '出発時刻', 'common', '交通機関'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. I need a ticket. To the city center. How does it work? First time at this station. The operation confuses me.', 'すみません。切符が必要。市内中心へ。どうやって？この駅は初めて。運用がわからない。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'No problem. We have a few options. Single trip. Day pass. Compare the prices. Day pass is good if you travel a lot. Financial benefit.', '問題ない。いくつかある。片道。1日券。価格を比較。1日券はたくさん乗るならお得。財務的にメリット。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Day pass. Ok. How much? I want to see the city. Several stops. Maybe the museum. The design district. Different stages of the tour.', '1日券。いくら？街を見たい。いくつか駅。美術館かも。デザイン地区。ツアーの様々な段階。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Twenty dollars. Unlimited. All day. Good strategy for tourists. You will not miss anything. Safe area. Low crime. No worry.', '20ドル。無制限。終日。観光客に良い戦略。逃さない。安全なエリア。犯罪少ない。心配なし。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Twenty. Ok. I will take it. Where do I go? Which platform? I do not want to miss my train. First day. Nervous.', '20。OK。いただきます。どこに行く？どこのホーム？電車を逃したくない。初日。緊張。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Platform 3. The red line. City center. Trains every ten minutes. Sort of easy. Check the screen. Departure times. Authority info. Official.', '3番ホーム。赤線。市内中心。10分おき。わりと簡単。画面を見て。出発時刻。当局情報。公式。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Platform 3. Red line. Got it. The station is big. I was lost. Your design. The signs. Helpful. But still confusing. First time.', '3番。赤線。了解。駅が大きい。迷った。デザイン。看板。助かる。でもまだ紛らわしい。初めて。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Many people say that. We are improving. New signs. Better strategy. Less crime in the station too. Safe. Police. Authority presence.', '多くの人が言う。改善中。新しい看板。より良い戦略。駅内の犯罪も減った。安全。警察。当局の存在。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. I feel safe. Compare to my city. Different. Less crime maybe. Or same. Hard to tell. First visit.', 'いい。安全に感じる。自分の街と比較。違う。犯罪少ないかも。同じかも。わからない。初訪問。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'This city is ok. Generally safe. Financial district. Tourists. Business people. Station operation runs smooth. On time. Rarely miss schedule.', 'この街は大丈夫。概ね安全。金融地区。観光客。ビジネスパーソン。駅の運用はスムーズ。時間通り。遅れは稀。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'What about transfer? I want to go to the museum. Stage two of my trip. Do I need to change? Another line?', '乗り換えは？美術館へ行きたい。旅行の第2段階。乗り換え必要？別の線？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Change at Central. Platform 5. Blue line. Three stops. Museum station. Clear design. You cannot miss it. Big sign. Authority managed.', 'はい。セントラルで乗り換え。5番ホーム。青線。3駅。美術館駅。明確なデザイン。逃さない。大きな看板。当局管理。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Central. Platform 5. Blue. Three stops. My strategy is set. City center first. Then museum. Then design district. Full day.', 'セントラル。5番。青。3駅。戦略が決まった。まず市内。次美術館。次デザイン地区。丸一日。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good plan. Sort of popular route. Many tourists. Same strategy. Day pass. Compare to taxi. Much cheaper. Financial sense.', '良いプラン。人気ルート。多くの観光客。同じ戦略。1日券。タクシーと比較。ずっと安い。財務的に理にかなう。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Ok. Thank you. I will not miss my train now. Platform 3. Red line. You helped a lot. Station was confusing. Clear now.', 'OK。ありがとう。もう電車を逃さない。3番。赤線。たくさん助かった。駅は紛らわしかった。今は明確。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'You are welcome. Next train. Five minutes. Check the screen. Operation status. On time. Enjoy your day. Safe travel.', 'どういたしまして。次は5分。画面を見て。運用状況。時間通り。良い一日を。安全な旅を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thanks. One more thing. Is there crime? On the train? At night? I might stay late. Museum. Design district. 9 PM maybe.', 'ありがとう。もう一つ。犯罪は？電車で？夜？遅くまでいるかも。美術館。デザイン地区。9時PMかも。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Generally ok. Low crime. Authority patrols. Sort of safe. Compare to day. A bit more careful. But ok. Design district. Nice area.', '概ね大丈夫。犯罪少ない。当局のパトロール。わりと安全。日中と比較。少し注意。でも大丈夫。デザイン地区。いいエリア。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good. I will not miss the last train. Check the schedule. My strategy. Back by 11 PM. Financial. Save on taxi.', 'いい。終電は逃さない。時刻表確認。戦略。11時PMまでに戻る。財務。タクシー代節約。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Smart. Bye. Enjoy the city. Stage by stage.', '賢い。バイバイ。街楽しんで。段階ごとに。' FROM conv4;
