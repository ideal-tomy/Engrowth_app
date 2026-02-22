-- 3分ストーリー: ショッピング（1本目）
-- 使用単語: analysis, benefit, sex, forward, lawyer, present, section, environmental, skill, sister, PM, professor
-- theme_slug: shopping | situation_type: common | theme: ショッピング

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '服飾店での試着と購入',
    '海外の服飾店で商品を試着し、店員にアドバイスを求め、購入を決めて会計する会話。',
    3,
    41
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '店に入る', '店員に挨拶', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '試着を頼む', 'サイズの確認', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'アドバイスを受ける', '色やスタイルの相談', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '会計', '支払いと袋詰め', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. I am looking for a present for my sister. Her birthday is next week. Do you have a women''s section?', 'すみません。妹へのプレゼントを探しています。来週誕生日なんです。レディースのセクションはありますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. The women''s section is forward. Left side. We have many options. What is your sister''s size? Any particular style?', 'はい。レディースは前方。左側です。たくさんの選択肢があります。お妹様のサイズは？特定のスタイルは？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'She is medium. She likes environmental brands. Eco friendly. She works at a university. Her boss is a professor. Very academic style.', 'Mサイズです。環境に配慮したブランドが好き。エコフレンドリー。大学で働いてる。上司は教授。とてもアカデミックなスタイル。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We have an environmental line. This section. Organic cotton. Good for the planet. Many customers like it. A lawyer came yesterday. Bought three items.', '環境に配慮したラインがあります。このセクション。オーガニックコットン。地球に優しい。多くのお客様に人気。昨日弁護士の方が来て。3点購入されました。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Great. Can I try something on? I want to check the skill of the tailors. The quality. Before I buy for my sister.', 'いいですね。試着できますか？職人の腕を確認したい。品質。妹に買う前に。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Of course. The fitting room is that way. Let me get you a few options. Medium size. What benefit are you looking for? Warmth? Style?', 'もちろん。試着室はあちら。いくつかお持ちします。Mサイズ。どんなメリットを求めてます？暖かさ？スタイル？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Style mainly. But warm too. It is cold now. My sister works late. Sometimes until 9 PM. She needs a good coat.', '主にスタイル。でも暖かく。今は寒い。妹は遅くまで働く。時々9時PMまで。良いコートが必要。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'This coat is popular. Good analysis from our customers. High ratings. Unisex design. Works for any sex. Very versatile.', 'このコートは人気。お客様からの良い分析。高評価。ユニセックスデザイン。性別問わず。とても汎用的。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Unisex. Good. She can share with her brother. Maybe. Let me try it. What about the color? We have similar taste. Professor types. Simple.', 'ユニセックス。いい。兄弟と共有できるかも。試着させて。色は？似た趣味。教授タイプ。シンプル。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Navy or gray. Both are classic. Forward thinking but traditional. Many professionals choose these. Lawyers. Professors. Your sister will like it.', 'ネイビーかグレー。どちらもクラシック。進歩的だが伝統的。多くのプロが選ぶ。弁護士。教授。お妹様も気に入るでしょう。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I tried the navy. It fits well. Good skill in the cut. The environmental aspect is a plus. My sister cares about that. She studies climate.', 'ネイビーを試した。よく合う。裁断の腕がいい。環境面はプラス。妹は気にしてる。気候を研究してる。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Perfect. The benefit of this brand is quality and ethics. We have a full analysis report. In the store. You can read it. Very transparent.', '完璧。このブランドの利点は品質と倫理。完全な分析レポートがある。店内に。読めます。とても透明性が高い。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I will take it. One more thing. Do you have a gift section? I need a card. Something to present it nicely. For my sister.', 'いただきます。もう一つ。ギフトセクションは？カードが必要。きれいに贈るために。妹に。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Near the front. Cards and wrap. Free service. We can wrap it. Gift box. Nice for a present. Your sister will be happy. Birthday at 9 PM? Late celebration?', 'はい。入口近く。カードと包装。無料サービス。包装します。ギフトボックス。プレゼントに最適。お妹様喜びます。9時PMの誕生日？遅いお祝い？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'No. Lunch. She has a meeting with a lawyer at 2 PM. Busy schedule. Professor life. I will wrap it. Thanks.', 'いいえ。ランチ。2時PMに弁護士と会議。忙しいスケジュール。教授生活。包装お願い。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'No problem. Your total is eighty dollars. Card or cash? We have an environmental program. One percent to charity. Your benefit.', '問題ない。合計80ドル。カードか現金？環境プログラムがある。1パーセントを寄付。あなたの利益にも。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Card please. The present is for my sister. She will love it. Good skill in your selection. Really helpful.', 'カードで。プレゼントは妹用。気に入る。選んでくれて腕がいい。本当に助かった。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thank you. Here is your bag. Wrapped. Ready to present. Happy birthday to your sister. Enjoy.', 'ありがとう。袋です。包装済み。贈る準備OK。お妹様お誕生日おめでとう。楽しんで。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks. The environmental section was great. Good analysis of the products. I will come back. Bye.', 'ありがとう。環境セクション良かった。商品の分析がいい。また来ます。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
