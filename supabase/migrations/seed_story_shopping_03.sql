-- 3分ストーリー: ショッピング（3本目）
-- 使用単語: analysis, benefit, sex, forward, lawyer, present, section, environmental, skill, sister, PM, professor
-- theme_slug: shopping | situation_type: common | theme: ショッピング

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '免税手続き付きの買い物',
    '海外のショッピングモールで買い物をし、免税手続きについて店員に尋ねる会話。',
    3,
    43
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '免税の確認', '条件を聞く', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '商品を選ぶ', '姉と自分用', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'レジで支払い', 'パスポート提示', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '手続き完了', 'レシートと袋', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. Do you have tax free? For tourists? I am visiting. I want to buy a present. For my sister. Back home.', 'すみません。免税はありますか？観光客向け？旅行中です。プレゼントを買いたい。妹に。故郷に。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. Tax free over fifty dollars. Passport required. Forward to the cashier. They will help. What section are you looking for?', 'はい。50ドル以上で免税。パスポート必要。レジへ。手伝います。どのセクションを探してます？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Women''s section. A scarf. Environmental material if possible. My sister is a professor. She likes quality. Good skill in her choice.', 'レディース。スカーフ。可能なら環境素材。妹は教授。品質が好き。選ぶ腕がある。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Scarves are there. Left side. We have organic cotton. Benefit for the environment. Our analysis shows high demand. Popular with professionals.', 'スカーフはあそこ。左側。オーガニックコットンある。環境にメリット。分析で高需要。プロに人気。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Great. And for myself? I need a shirt. Business style. I have a meeting at 2 PM. With a lawyer. Need to look good.', 'いい。自分用は？シャツが必要。ビジネススタイル。2時PMに会議。弁護士と。きれいに見える必要。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Men''s section. Forward. Near the window. We have dress shirts. Any sex can wear our unisex line. Very flexible. Good present for yourself.', 'メンズセクション。前方。窓際。ドレスシャツある。性別問わずユニセックスライン。とても柔軟。自分へのいいプレゼント。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'This blue one. Size medium. Can I try it? I want to check the skill. The stitching. Professor level quality.', 'この青いの。Mサイズ。試着できる？腕を確認したい。ステッチ。教授レベルの品質。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Fitting room. That way. The benefit of this brand is durability. Long lasting. Good for the environment. Less waste. Environmental choice.', '試着室。あちら。このブランドの利点は耐久性。長持ち。環境に優しい。無駄が少ない。環境に配慮した選択。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'It fits. I will take both. The scarf for my sister. Shirt for me. Present for her. Treat for me. 2 PM meeting. Ready.', '合う。両方いただく。スカーフは妹に。シャツは自分に。彼女へのプレゼント。自分へのご褒美。2時PMの会議。準備OK。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Perfect. Follow me to the cashier. Passport ready. Tax free form. We will do the analysis. Check your eligibility. Fast process.', '完璧。レジへ。パスポート準備。免税フォーム。分析する。資格確認。速い手続き。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Here is my passport. Total? The benefit of tax free is big. Save money. More to spend. On my sister''s present. And mine.', 'パスポートです。合計？免税のメリットは大きい。節約。もっと使える。妹のプレゼントに。自分のに。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'One twenty. With tax free. One five. Saved. Sign here. Present your receipt at the airport. Seal the bag. Do not open until you leave.', '120。免税で。15節約。ここにサイン。空港でレシート提示。袋を封印。出国まで開けない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Understood. My sister will love the scarf. Environmental. Her style. Professor of ecology. Perfect match.', 'わかりました。妹はスカーフを気に入る。環境。彼女のスタイル。生態学の教授。完璧なマッチ。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good choice. Your shirt too. The lawyer at 2 PM. You will look professional. Skill in appearance. Matters in business.', '良い選択。シャツも。2時PMの弁護士。プロフェッショナルに見える。見た目の腕。ビジネスで大事。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thanks. One question. What time do you close? I might come back. Late. Maybe 9 PM. More presents. For other family.', 'ありがとう。一つ。何時まで？戻るかも。遅く。9時PMかも。もうプレゼント。他の家族に。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'We close at 10 PM. Plenty of time. Come any time. The environmental section has new items. Weekly. Your benefit. Fresh stock.', '10時PMまで。十分時間ある。いつでも。環境セクションに新商品。毎週。あなたのメリット。新鮮な在庫。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Great. Thank you for the help. The analysis of my needs. Spot on. Good skill. Really.', 'いい。助けてくれてありがとう。ニーズの分析。ぴったり。腕がいい。本当に。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Enjoy your stay. Happy shopping. Present the receipt at the airport. Do not forget.', 'どういたしまして。滞在楽しんで。ショッピング楽しんで。空港でレシート提示。忘れずに。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I won''t. Bye. Good luck with the 2 PM. Lawyer meeting. Forward with confidence.', '忘れない。バイバイ。2時PM頑張って。弁護士との会議。自信を持って前に進んで。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
