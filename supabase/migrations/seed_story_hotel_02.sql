-- 3分ストーリー: ホテル（2本目）
-- 使用単語: blood, upon, agency, push, nature, color, no, recently, store, reduce, sound, note
-- theme_slug: hotel | situation_type: common | theme: ホテル

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ルームサービスでの注文',
    'ホテルのルームサービスに電話で注文する会話。',
    3,
    32
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '注文の開始', 'メニューを聞く', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'メニューの確認', '料理とドリンク', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '配達時間の確認', 'いつ届くか', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '注文の確定', 'ルーム番号と支払い', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. Room service please. Room 412. I would like to order. Do you have a menu? I did not note the number. Had to push zero for the front desk.', 'こんにちは。ルームサービスをお願いします。412号室。注文したい。メニューは？番号をメモしてなかった。フロントにゼロを押した。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Of course. I can read the menu to you. We recently updated. New items. The nature of our food is fresh. Local. Would you like to hear the options?', 'もちろん。メニューを読みます。最近更新。新メニュー。食事の性質はフレッシュ。地元。選択肢をお聞きになりますか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes please. Something light. Maybe salad. And a drink. Do you have blood orange juice? I had it at breakfast. It was good.', 'お願いします。軽いもの。サラダかも。飲み物も。ブラッドオレンジジュースは？朝食で飲んだ。美味しかった。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. Blood orange. Fresh. We get it from the store downstairs. The color is deep. Sweet. No sugar added. Sound good?', 'はい。ブラッドオレンジ。フレッシュ。階下のストアから。色は濃い。甘い。砂糖なし。いいですか？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Perfect. And a garden salad. Can you reduce the dressing? Light on the sauce. The agency said the food here is healthy. I believe it.', '完璧。ガーデンサラダも。ドレッシングを減らしてもらえる？ソースは控えめに。旅行会社がここの食事はヘルシーと言ってた。信じる。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'No problem. Light dressing. One salad. One blood orange juice. Room 412. Anything else? We have a promotion. Order two items. Reduce the total by ten percent.', '問題ない。ライトドレッシング。サラダ1つ。ブラッドオレンジジュース1杯。412号室。他に？プロモーションあり。2品注文で10%割引。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Ten percent off. Good. Maybe add a soup. What color is the soup today? Tomato? Or something else?', '10%オフ。いいですね。スープも。今日のスープの色は？トマト？他に？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Cream of mushroom. White. Light. Or vegetable. Green color. Both reduce the chill. Cold day. Good for the blood. Warm you up.', 'キノコのクリーム。白。軽い。または野菜。緑色。どちらも寒さを減らす。寒い日。血の巡りにいい。温まる。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Vegetable soup. Green. Sounds healthy. So salad, soup, juice. Three items. I get the discount. Upon delivery can you call first? I might be in the shower.', '野菜スープ。緑。ヘルシーに聞こえる。サラダ、スープ、ジュース。3品。割引適用。配達時に先に電話？シャワー中かも。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. We will call from the lobby. Give you time. Then push the cart up. No rush. Usually twenty minutes. I will note that. Call before delivery.', 'はい。ロビーから電話。お時間を。それからカートを押して上がる。急がなくて。通常20分。メモする。配達前に電話。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Twenty minutes. Good. I have a meeting at four. Plenty of time. The agency has a car at five. So I am fine. No stress.', '20分。いい。4時に会議。時間は十分。旅行会社の車が5時。だから大丈夫。ストレスなし。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Understood. So salad, vegetable soup, blood orange juice. Light dressing. Room 412. Call before delivery. I have it all. The total will be reduced. Ten percent off.', '承知。サラダ、野菜スープ、ブラッドオレンジジュース。ライトドレッシング。412号室。配達前に電話。全て記録。合計は割引。10%オフ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Perfect. How do I pay? Charge to the room? I noted my card at check-in. Is that on file?', '完璧。支払いは？ルームチャージ？チェックインでカードをメモした。記録されてる？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Your card is on file. We will charge upon delivery. No need to sign. We push the receipt under the door. Or you can get it at the store. Your choice.', 'はい。カードは記録済み。配達時にチャージ。サイン不要。レシートをドアの下に。またはストアで。お選びください。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Under the door is fine. Thank you. The nature of your service is excellent. Recently stayed at another chain. Not as good.', 'ドアの下でいい。ありがとう。サービスの性質は素晴らしい。最近別チェーンに泊まった。あまり良くなかった。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. We try. Your order will arrive soon. Enjoy your meal. Goodbye.', 'ありがとう。努力しています。注文はすぐ届く。食事を楽しんで。さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Thank you.', 'さようなら。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
