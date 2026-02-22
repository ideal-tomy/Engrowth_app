-- 3分ストーリー: ショッピング（2本目）
-- 使用単語: analysis, benefit, sex, forward, lawyer, present, section, environmental, skill, sister, PM, professor
-- theme_slug: shopping | situation_type: common | theme: ショッピング

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'アクセサリーショップで姉への贈り物',
    'アクセサリーショップで姉の誕生日プレゼントを探し、店員と相談して購入する会話。',
    3,
    42
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '相談開始', '予算と好みの確認', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '商品を見る', 'ネックレスとイヤリング', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '決める', '姉のスタイルに合わせる', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '包装とお礼', 'ギフト包装を頼む', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need a present. For my sister. She is thirty next week. I want something nice. What do you recommend?', 'こんにちは。プレゼントが必要。妹用。来週30歳。いいものが欲しい。何かお勧め？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Congratulations to her. We have a gift section. Forward. Near the window. Many options. What is her style? Professional? Casual?', 'おめでとうございます。ギフトセクションがある。前方。窓際。たくさん選択肢。スタイルは？プロフェッショナル？カジュアル？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'She is a professor. Very academic. But she likes nice things. Environmental too. Recycle. Eco. That kind of thing.', '教授です。とてもアカデミック。でも素敵なものが好き。環境にも。リサイクル。エコ。そういうの。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We have an environmental line. Made from recycled materials. Good benefit for the planet. Our analysis says many customers prefer it. Especially younger women.', '環境ラインがある。リサイクル素材。地球にメリット。分析では多くのお客様が好む。特に若い女性。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Perfect. Can I see some? My sister has good skill in fashion. She will notice quality. I want the best.', '完璧。見せてくれますか？妹はファッションのセンスがある。品質に気づく。最高のものが欲しい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'This way. The jewelry section. We have bracelets. Necklaces. For any sex. Unisex designs too. Very popular.', 'こちらへ。ジュエリーセクション。ブレスレット。ネックレス。性別問わず。ユニセックスも。とても人気。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'This necklace is beautiful. Is it real? My sister had a lawyer friend. She knows about gems. I need something genuine.', 'このネックレスきれい。本物？妹に弁護士の友達がいる。宝石について知ってる。本物が欲しい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Certified. We have documents. Our skill in selection is top. Many professors and lawyers buy here. Trust us.', 'はい。認証済み。書類がある。選定の腕は一流。多くの教授や弁護士が購入。信頼を。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. What about the price? I have a budget. Forward planning. I want to stay under two hundred.', 'いい。価格は？予算がある。前もって計画。200以下にしたい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'This one is one eighty. Good value. The benefit of buying here is warranty. Two years. Free repair. Present it with confidence.', 'これは180。お得。ここで買うメリットは保証。2年。無料修理。自信を持って贈れます。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I will take the necklace. Can you wrap it? Gift wrap. For a present. My sister''s birthday. We meet at 6 PM. Dinner.', 'ネックレスにします。包装できる？ギフト包装。プレゼント用。妹の誕生日。6時PMに会う。ディナー。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Of course. Beautiful box. Ribbon. Our analysis of customer feedback. Gift wrap adds value. People appreciate it.', 'もちろん。きれいな箱。リボン。お客様フィードバックの分析。ギフト包装は価値を加える。感謝される。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Great. One more question. Do you have a card? A birthday card? To go with the present. For my sister.', 'いい。もう一つ。カードある？誕生日カード。プレゼントと一緒に。妹に。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. In that section. Near the exit. Many designs. Environmental cards. Recycled paper. Your sister will like the thought.', 'はい。あのセクション。出口近く。デザイン多数。環境カード。再生紙。お妹様その心遣い喜ぶ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Perfect. Thank you. Your skill in helping is great. I was lost. Now I have the perfect present. For my sister. The professor.', '完璧。ありがとう。サポートの腕がすごい。迷ってた。完璧なプレゼントができた。妹に。教授に。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'You are welcome. Your total. One hundred eighty. Card or cash? Here is your bag. Wrapped. Ready to present.', 'どういたしまして。合計180。カードか現金？袋です。包装済み。贈る準備OK。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Card. Thanks. The environmental options were a benefit. My sister cares. She will be happy. 6 PM. I cannot wait.', 'カード。ありがとう。環境オプションはメリットだった。妹は気にしてる。喜ぶ。6時PM。待ちきれない。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Enjoy the dinner. Happy birthday to your sister. Come again. We have new items every week.', 'ディナー楽しんで。お妹様誕生日おめでとう。またお越しを。毎週新商品。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will. Bye. Thank you for the analysis. The advice. Very helpful.', 'そうします。バイバイ。分析ありがとう。アドバイス。とても助かった。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
