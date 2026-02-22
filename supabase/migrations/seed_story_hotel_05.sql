-- 3分ストーリー: ホテル（5本目）
-- 使用単語: blood, upon, agency, push, nature, color, no, recently, store, reduce, sound, note
-- theme_slug: hotel | situation_type: common | theme: ホテル

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'レイトチェックアウトの相談',
    '出発が遅れるためレイトチェックアウトを依頼する会話。',
    3,
    35
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '延長の依頼', 'フロントで相談', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金の確認', '延長の費用', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '荷物の預かり', 'ルームキー返却', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認とお礼', '出発の案内', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I need to extend my stay. Just a few hours. My flight was delayed. The agency called. New flight at four. Check out is twelve. Can I stay until two?', 'こんにちは。滞在を延長したい。数時間だけ。フライトが遅れた。旅行会社から連絡。新便は4時。チェックアウトは12時。2時まで泊まれますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Let me check. We have availability. Late checkout is possible. Upon request. We recently changed the policy. Two hours extra. Thirty dollars. Or we can reduce it. Half price for agency bookings.', '確認します。空きあり。レイトチェックアウト可能。リクエストで。最近ポリシー変更。2時間延長。30ドル。割引可能。旅行会社予約は半額。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Fifteen dollars. That sounds fair. The agency booked. I have the confirmation. I can push it to you. Email. Or do you have it on file?', '15ドル。妥当に聞こえる。旅行会社が予約。確認書がある。送れる。メール。ファイルにある？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We have it. Your booking. Agency rate. I will note the late checkout. Two o clock. Room 505. No problem. The nature of our service. We accommodate.', 'ある。予約。旅行会社レート。レイトチェックアウトをメモ。2時。505号室。問題ない。サービスの性質。対応する。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. One more thing. Can I leave my bags? After two. Until three thirty? I want to walk. Get some air. Maybe the store. Buy blood orange juice. For the flight.', 'ありがとう。もう一つ。荷物を預けられる？2時以降。3時半まで？歩きたい。空気を吸う。ストアかも。ブラッドオレンジジュースを買う。フライト用。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Yes. Bell desk. Free for guests. We will store your bags. Upon return just show your receipt. The color is yellow. You cannot miss it. No fee for three hours.', 'はい。ベルデスク。ゲスト無料。荷物を保管。戻ったらレシートを提示。色は黄色。見逃せない。3時間無料。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Yellow receipt. Got it. So checkout at two. Bags at bell desk. Pick up by three thirty. Flight at four. I have it all. Sound good?', '黄色のレシート。わかった。2時にチェックアウト。荷物はベルデスク。3時半までに受け取り。4時のフライト。全て把握。いい？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Perfect. One note. The store has blood orange. Fresh. Good for travel. Reduces thirst. Long flight. We get it daily. No extra charge for the bag if you buy something.', '完璧。一つメモ。ストアにブラッドオレンジ。フレッシュ。旅行に良い。喉の渇きを減らす。長いフライト。毎日仕入れ。何か買えば荷物無料。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I will buy some. The juice here is great. I had it at breakfast. The color. Deep. Rich. Better than the agency recommended place. That one was no good.', '買う。ここのジュースは最高。朝食で飲んだ。色。深い。リッチ。旅行会社おすすめより良い。あれはダメだった。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Thank you. We try. So two o clock. Key at the desk. Or leave in the room. Push the key slot. We will confirm. Late checkout. Fifteen dollars. Added to your bill.', 'ありがとう。努力してる。2時。キーはデスクへ。または部屋に。キースロットに押して。確認する。レイトチェックアウト。15ドル。請求に追加。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Understood. Thank you. The flexibility is appreciated. My blood pressure was rising. Stressed about the flight. Now I can relax. Take my time.', '承知。ありがとう。柔軟性に感謝。血圧が上がってた。フライトでストレス。もうリラックスできる。ゆっくり。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We understand. Travel stress. No fun. The nature of delays. We do what we can. Reduce the worry. Our job.', 'わかります。旅行のストレス。楽しくない。遅延の性質。できることをする。心配を減らす。仕事です。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'You do it well. I will note this hotel. For next time. Agency will hear good things. No complaint. Just praise. The room color. Blue. So calm.', '上手です。このホテルをメモする。次回用。旅行会社に良いことを伝える。クレームなし。称賛だけ。部屋の色。ブルー。とても落ち着く。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Thank you. Enjoy your extra time. The store. The walk. See you at two. Goodbye for now.', 'ありがとう。追加時間を楽しんで。ストア。散歩。2時に。一旦さようなら。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. Thank you.', 'さようなら。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks again.', 'もう一度ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Anytime.', 'いつでも。' FROM conv4;
