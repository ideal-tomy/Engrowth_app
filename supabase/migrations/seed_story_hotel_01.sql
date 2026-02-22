-- 3分ストーリー: ホテル（1本目）
-- 使用単語: blood, upon, agency, push, nature, color, no, recently, store, reduce, sound, note
-- theme_slug: hotel | situation_type: common | theme: ホテル

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ホテルチェックイン',
    '海外ホテルでチェックインし、部屋の希望を伝える会話。',
    3,
    31
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'チェックイン開始', 'フロントで手続き', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '部屋の希望', '階数と眺め', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '施設の案内', 'レストランとプール', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'ルームキー受け取り', 'エレベーターの案内', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I have a reservation. Name is Sato. I booked through the travel agency. Two nights. Arriving upon the date we confirmed.', 'こんにちは。予約があります。佐藤です。旅行会社経由で予約。2泊。確認した日付通りに到着。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. Let me pull up your booking. Yes. Sato. Two nights. I note you requested a quiet room. We have one. High floor. No street sound.', 'ようこそ。予約を表示します。はい。佐藤様。2泊。静かな部屋のご希望をメモしています。あります。高層。街の音なし。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Perfect. That sounds good. I need to reduce stress. Business trip. The agency said this hotel is quiet. Good for rest.', '完璧。いいですね。ストレスを減らしたい。出張。旅行会社がこのホテルは静かと言ってた。休息に良い。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. We recently renovated. New windows. They reduce outside noise. The room color is soft blue. Calm. Good for sleep.', 'はい。最近リノベーションしました。新しい窓。外の音を減らします。部屋の色はソフトブルー。落ち着く。睡眠に良い。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Blue. I like that. Nature tone. Can I request a room with a view? Garden or park? The agency did not note that.', 'ブルー。好きです。ナチュラルなトーン。眺めの部屋をリクエストできますか？庭か公園？旅行会社はメモしてなかった。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Let me check. We have a room. Eighth floor. Garden view. No extra charge. Upon arrival we can upgrade if you like. Just push the button for front desk.', '確認します。お部屋があります。8階。庭園眺め。追加料金なし。到着時にアップグレードも。フロントのボタンを押すだけ。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Eighth floor. Garden view. No extra cost. Sounds perfect. Does the room have a store? Mini bar? I need water. Blood orange juice in the morning.', '8階。庭園眺め。追加料金なし。完璧に聞こえる。部屋にストアは？ミニバー？水が要る。朝はブラッドオレンジジュース。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Mini bar. We have juice. Blood orange. Regular orange. Water. No problem. The store on the first floor has more. Open twenty-four hours.', 'はい。ミニバー。ジュースがある。ブラッドオレンジ。通常オレンジ。水。問題ない。1階のストアにもっと。24時間営業。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. I will note that. So room 801? Garden view. Quiet. Blue color. Mini bar. I am all set.', 'いいですね。メモする。801号室？庭園眺め。静か。ブルーの色。ミニバー。準備できた。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Room 812 actually. Same floor. Same view. Slightly larger. The agency booked a standard. We upgraded. No charge. Upon our recent campaign.', '実は812号室。同じ階。同じ眺め。少し広い。旅行会社はスタンダードを予約。アップグレード。料金なし。最近のキャンペーンで。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. That is kind. So 812. Eighth floor. How do I get there? Elevator? I do not want to push my bags up stairs.', 'ありがとう。親切ですね。812。8階。どう行く？エレベーター？階段で荷物を押し上げたくない。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Elevator to your right. Push floor eight. The room is left from the elevator. You will see the sign. Blue color on the door. Soft. Easy to spot.', '右のエレベーター。8階のボタンを押して。部屋はエレベーターから左。看板が見える。ドアはブルー。ソフト。見つけやすい。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Got it. Breakfast? What time? The agency note said seven to ten. Is that still the rule?', 'わかりました。朝食は？何時？旅行会社のメモに7時から10時と。まだそのルール？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Seven to ten. First floor. Restaurant. Great spread. Blood orange juice. Fresh. Reduce the price if you book tonight. Twenty percent off.', 'はい。7時から10時。1階。レストラン。豪華なブッフェ。ブラッドオレンジジュース。フレッシュ。今夜予約すれば料金減。20%オフ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will book. Thank you. The nature of this hotel is very welcoming. I feel relaxed already. No stress. Just sound sleep ahead.', '予約する。ありがとう。このホテルの性質はとても歓迎的。もうリラックス。ストレスなし。快眠が待ってる。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. Here is your key. Room 812. Eighth floor. Upon check out just leave the key in the room. Or drop at the desk. No need to push the bell.', 'ありがとう。キーです。812号室。8階。チェックアウト時は部屋にキーを。またはフロントに。ベルを押す必要なし。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Understood. Thank you for everything. The agency chose well. I will note this for my next trip. Good hotel.', '承知。全てありがとう。旅行会社は良い選択。次の旅行用にメモする。良いホテル。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Enjoy your stay. Goodbye.', 'どういたしまして。ご滞在を。さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Thank you.', 'さようなら。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
