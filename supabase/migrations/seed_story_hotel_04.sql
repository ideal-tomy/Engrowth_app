-- 3分ストーリー: ホテル（4本目）
-- 使用単語: blood, upon, agency, push, nature, color, no, recently, store, reduce, sound, note
-- theme_slug: hotel | situation_type: common | theme: ホテル

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '部屋の変更依頼',
    'ノイズが気になり部屋の変更を依頼する会話。',
    3,
    34
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '問題の説明', '騒音を伝える', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '部屋の確認', '空室を探す', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '移動の案内', '新しい部屋へ', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お詫びと対応', '補償の案内', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. I have a problem. Room 305. The sound from the street is loud. I cannot sleep. I need to rest. Big meeting tomorrow. Booked through the agency.', 'すみません。問題があります。305号室。街の音が大きい。眠れない。休みが必要。明日大事な会議。旅行会社で予約。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'I am sorry. Let me check. We recently had complaints. That side faces the main road. The nature of the building. Old windows. We can move you. No charge.', '申し訳ありません。確認します。最近苦情がありました。あの側は大通りに面。建物の性質。古い窓。お移りできます。無料。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. A quiet room please. The agency said this hotel is peaceful. I did not note the room number when I booked. My fault.', 'ありがとう。静かな部屋を。旅行会社がこのホテルは静かと言ってた。予約時に部屋番号をメモしなかった。私のミス。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Not at all. We have a room. Eighth floor. Back side. Garden view. Different color scheme. Green. Nature tone. Reduces stress. No street sound.', 'とんでもない。お部屋があります。8階。裏側。庭園眺め。別のカラースキーム。グリーン。自然トーン。ストレス減。街の音なし。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Eighth floor. Garden. Green. Sounds perfect. Can I move now? I will push my bags. Or is there a cart?', '8階。庭園。グリーン。完璧に聞こえる。今移動できる？荷物を押す。カートは？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We will send a porter. No need to push. He will take your bags. Room 812. Upon arrival we will give you the new key. The old one will stop working.', 'ポーターを送る。押す必要なし。荷物を運ぶ。812号室。到着時に新しいキー。古いのは使えなくなる。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Room 812. Got it. Same floor as the restaurant? Breakfast. I had blood orange juice. It was good. The store on one has more?', '812号室。わかった。レストランと同じ階？朝食。ブラッドオレンジジュースを飲んだ。美味しかった。1階のストアにもっと？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. First floor. Store opens early. Six. Blood orange. All juices. We reduce the price for guests. Show your key. Ten percent off.', 'はい。1階。ストアは早く開く。6時。ブラッドオレンジ。全ジュース。ゲスト割引。キーを提示。10%オフ。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good to know. So 812. Porter coming. New key. I feel better already. The agency will be happy. No complaint from me. Just a note. Room change. For their records.', 'いい情報。812。ポーター来る。新しいキー。もう気分がいい。旅行会社も喜ぶ。クレームじゃなく。メモだけ。部屋変更。記録用。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I will note it in your file. And we will add a credit. Twenty dollars. For the store. Or room service. Your choice. Upon checkout we apply it. Reduces your bill.', 'ファイルにメモ。クレジット追加。20ドル。ストアかルームサービス。お選びください。チェックアウト時に適用。請求を減らす。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Twenty dollars. That is kind. Thank you. The color of your service is excellent. Green. Go. Professional. I appreciate it.', '20ドル。親切ですね。ありがとう。サービスの色は優秀。グリーン。進む。プロフェッショナル。感謝。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Thank you. The porter is on his way. Push the bell if you need anything. Or call the desk. We are here. No problem too small.', 'ありがとう。ポーターが向かってる。何かあればベルを押して。またはフロントに電話。常駐。問題は小さすぎない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Understood. I will wait. The nature of your response is impressive. Recently stayed elsewhere. They did not care. You do. Sound difference.', '承知。待つ。対応の性質は印象的。最近他に泊まった。彼らは気にしなかった。あなた方は気にする。音の違い。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We aim to please. Your new room is ready. Eighth floor. Elevator to the right. Push eight. Left from the elevator. Blue door. Soft color. You will see it.', 'お客様満足を目指す。新しい部屋は準備OK。8階。右のエレベーター。8を押して。エレベーターから左。青いドア。ソフトな色。見える。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. I will go up. Goodbye for now.', 'ありがとう。上がる。一旦さようなら。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Enjoy your stay. Rest well. Good night.', 'さようなら。ご滞在を。よく休んで。おやすみなさい。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Good night. Thank you.', 'おやすみ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
