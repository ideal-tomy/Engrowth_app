-- 3分ストーリー: 交通機関（4本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: transport | situation_type: common | theme: 交通機関

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '地下鉄の定期券を購入',
    '地下鉄の駅で定期券や週パスを購入し、使い方を駅員に尋ねる会話。',
    3,
    49
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '券売機の前', '種類を聞く', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '定期券の選択', '週か月か', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '使い方', '改札の通り方', 'common', '交通機関'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認', 'お礼', 'common', '交通機関'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need a pass. For the metro. I am here for two weeks. Business. Financial meetings. Different stations. Every day.', 'こんにちは。パスが必要。地下鉄用。2週間滞在。仕事。財務会議。様々な駅。毎日。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'We have weekly passes. Two weeks. Two passes. Or monthly. Compare the price. Weekly is forty. Monthly is one twenty. Financial benefit. Monthly if you stay long.', '週パスある。2週間。2枚。または月額。価格を比較。週40。月120。財務メリット。長くいるなら月額。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Two weeks. Two weekly passes. Ok. How do I use it? The design. The machine. First time. Sort of confusing. Different from home.', '2週間。週パス2枚。OK。使い方は？デザイン。機械。初めて。わりと紛らわしい。自国と違う。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Tap at the gate. Green light. Go through. Operation is simple. Authority system. Official. Cannot miss. One tap. In and out. Same card.', 'ゲートでタップ。緑。通る。運用はシンプル。当局システム。公式。逃さない。1タップ。入退場。同じカード。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Tap in. Tap out. Got it. My strategy. Week one. These stations. Meetings. Week two. Different. More meetings. Both stages. Covered.', 'タップイン。タップアウト。了解。戦略。1週目。これらの駅。会議。2週目。別。もっと会議。両段階。カバー。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Eighty dollars. Two weekly passes. Card or cash? The machine. Or here. I can do it. Same price. Official. Authority approved.', '80ドル。週パス2枚。カードか現金？機械。またはここ。できる。同じ価格。公式。当局承認。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Card. Here. The station. Is it safe? At night? I might have late meetings. 9 PM. 10 PM. Crime? Any issues?', 'カード。どうぞ。駅。安全？夜？遅い会議あるかも。9時PM。10時PM。犯罪？問題？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Generally ok. Low crime. Authority patrols. Cameras. Good design. Safe. Sort of busy. Financial district. Workers. Tourists. You will be ok.', '概ね大丈夫。犯罪少ない。当局パトロール。カメラ。良いデザイン。安全。わりと賑やか。金融地区。労働者。観光客。大丈夫。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. Compare to my city. Similar. Maybe safer. Different operation. But same idea. Public transit. Authority runs it.', 'いい。自分の街と比較。似てる。もっと安全かも。運用は違う。でも同じ考え。公共交通。当局が運営。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Operation is smooth. On time. Rarely miss schedule. Reliable. Good for business. Financial people use it. Daily. Same strategy.', 'はい。運用はスムーズ。時間通り。遅れは稀。信頼できる。ビジネス向け。財務関係者が使う。毎日。同じ戦略。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Here is the card. Two passes. Week one. Week two. My strategy is set. Cannot miss any meetings. All stations. Covered.', 'カードです。2枚。1週目。2週目。戦略確定。会議を逃さない。全駅。カバー。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Tap at gate. Each station. In. Out. Simple. Design is clear. Green. Go. Red. Stop. Authority standard. Same everywhere.', 'ゲートでタップ。各駅。イン。アウト。シンプル。デザインは明確。緑。進む。赤。止まる。当局標準。どこも同じ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Same everywhere. Good. I will not get lost. Sort of nervous. First time. New city. New station. New operation. But ok now.', 'どこも同じ。いい。迷わない。わりと緊張。初めて。新しい街。新しい駅。新しい運用。でも今は大丈夫。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You will be fine. Stage one. Learn the system. Stage two. Use it daily. Stage three. Expert. Easy. Many do it. Financial district. Common.', '大丈夫。段階1。システムを学ぶ。段階2。毎日使う。段階3。熟練。簡単。多くの人が。金融地区。一般的。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thanks. I feel better. The design. The info. Clear. Will not miss my first meeting. Tomorrow. 9 AM. Central station.', 'ありがとう。気分が楽に。デザイン。情報。明確。初会議を逃さない。明日。9時AM。セントラル駅。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Central. Easy. Red line. From here. Three stops. You cannot miss it. Big station. Authority hub. Main design. Clear.', 'セントラル。簡単。赤線。ここから。3駅。逃さない。大きな駅。当局ハブ。メインデザイン。明確。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Red line. Three stops. Compare to taxi. Cheaper. Faster maybe. Rush hour. Metro. Good strategy. Financial. Save money.', '赤線。3駅。タクシーと比較。安い。速いかも。ラッシュ。地下鉄。良い戦略。財務。節約。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Exactly. Smart. Operation runs well. You will not miss a thing. Good luck. Meetings. Both weeks. Busy. But ok.', 'その通り。賢い。運用は良好。逃さない。頑張って。会議。両週。忙しい。でも大丈夫。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks. Bye. Appreciate the help. Station was confusing. New. But you made it clear. Strategy set.', 'ありがとう。バイバイ。助けに感謝。駅は紛らわしかった。新しい。でも明確にした。戦略確定。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care. Enjoy the city.', 'バイバイ。お気をつけて。街楽しんで。' FROM conv4;
