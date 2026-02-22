-- 3分ストーリー: 飛行機（2本目）
-- 使用単語: place, single, rule, daughter, administration, south, floor, either, husband, campaign
-- theme_slug: flight | situation_type: common | theme: 飛行機

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '機内でのドリンク注文',
    '機内で客室乗務員に飲み物を注文し、軽食を頼む会話。',
    3,
    27
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '飲み物の案内', 'CAが注文を聞く', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '注文の確認', '好みを伝える', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '席の交換', '家族で隣に', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '追加のお願い', '毛布と枕', 'common', '飛行機'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. Can I have something to drink? The flight is going south. Long journey. I am thirsty.', 'すみません。何か飲み物を。南へのフライト。長い旅。喉が渇きました。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Of course. We have juice, water, tea, coffee. The rule is one drink per service. But you can ask for more. What would you like?', 'もちろん。ジュース、水、紅茶、コーヒーがあります。サービスのルールは1杯ですが、追加できます。何になさいますか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Water please. And my daughter wants orange juice. She is across the aisle. Can she have a place next to me?', '水をお願いします。娘はオレンジジュース。通路の向こうにいます。私の隣の席を交換してもらえますか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Let me check. The administration has a rule. We can try to move seats. Either before takeoff or after. I will ask the passenger in 12B.', '確認します。運営のルールでは席の移動を試みられます。離陸前か後に。12Bの乗客にお聞きします。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. My husband is in 12C. So we need one more place in our row. Our daughter is alone in 14A.', 'ありがとう。夫は12C。この列にもう1席必要です。娘は14Aに一人で。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'I understand. Family together. Let me get your water first. Single or double? We have a campaign. Free refills on long flights.', 'わかりました。ご家族一緒に。まず水を。1杯か2杯？キャンペーンがあります。長距離便はお代わり無料。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Double please. And the juice for my daughter. Can you take it to her? She is on the floor. I mean her bag fell. She is picking it up.', '2杯お願いします。娘のジュースも。届けてもらえますか？フロアに。バッグが落ちて。拾ってます。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'No problem. I will bring both. Water for you. Juice for your daughter. Row fourteen. Aisle seat. Got it.', '問題ありません。両方お持ちします。あなたに水。娘さんにジュース。14列。通路側。わかりました。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. The administration on this airline is great. Very helpful. Better than last time. We took a different carrier south.', 'ありがとう。この航空会社の運営は素晴らしい。とても親切。前回より良い。前回は別の会社で南へ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Thank you. We try. So water and juice. Anything else? We have snacks. No extra cost. Part of our service campaign.', 'ありがとう。努力しています。水とジュース。他に？スナックもあります。追加料金なし。サービスキャンペーンの一部です。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Snacks would be great. Peanuts or crackers? Either is fine. And can my husband get a blanket? He is cold. The floor vent is strong.', 'スナックいいですね。ピーナッツかクラッカー？どちらでも。夫に毛布を？寒い。床のベントが強い。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'I will bring crackers. And a blanket for your husband. Row twelve. The rule is one blanket per passenger. But I can get another if needed.', 'クラッカーをお持ちします。旦那様に毛布。12列。1人1枚がルールですが、必要ならもう1枚。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'One is enough. Thank you. About the seat. Can we swap? My daughter and the person in 12B? So we have a single row. Family place.', '1枚で十分。ありがとう。席について。交換できますか？娘と12Bの方。1列を家族で。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'I asked. The passenger agreed. After we finish service. Your daughter can move. Either now or when we level off. Your choice.', 'お聞きしました。乗客は同意。サービス終了後。娘さんが移動できます。今か水平飛行のどちらか。お好きな方で。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'After service is fine. No rush. Thank you for the help. The administration really cares. We will fly with you again.', 'サービス後で大丈夫。急がなくて。助けてくれてありがとう。運営は本当に気を遣う。また利用します。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'You are welcome. Enjoy the flight. South gate arrival. We will announce. Have a good trip.', 'どういたしまして。フライトを楽しんで。南ゲート到着。アナウンスします。良い旅を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. One last thing. Is there a Congress magazine? Business read. For the trip.', 'ありがとう。最後に。コングレス雑誌は？ビジネス読み物。旅用に。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'In the seat pocket. Front of you. Page twelve has the campaign offers. Safe travels.', '座席ポケットに。目の前です。12ページにキャンペーン案内。良い旅を。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Perfect. Thank you.', '完璧。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You are welcome.', 'どういたしまして。' FROM conv4;
