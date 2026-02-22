-- 3分ストーリー: ショッピング（5本目）
-- 使用単語: analysis, benefit, sex, forward, lawyer, present, section, environmental, skill, sister, PM, professor
-- theme_slug: shopping | situation_type: common | theme: ショッピング

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '返品と交換の相談',
    '購入したシャツのサイズが合わないため、返品と交換について店員と話す会話。',
    3,
    45
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '返品の依頼', '理由を説明', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '交換の相談', 'サイズ違い', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '新しい商品', '別のサイズを試す', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '手続き完了', '交換終了', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. I need help. I bought this yesterday. A present. For my sister. But the size is wrong. Too small. Can I exchange?', 'すみません。助けが必要。昨日これを買った。プレゼント。妹に。でもサイズが違う。小さすぎる。交換できます？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Of course. Do you have the receipt? Our policy. Thirty days. Exchange or refund. Same section. Same item. Easy.', 'もちろん。レシートある？ポリシー。30日。交換か返金。同じセクション。同じ商品。簡単。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Here. I bought it at 3 PM. For my sister. She is a professor. Busy. I wanted to present it. Birthday. But she tried. Too tight.', 'これ。3時PMに買った。妹に。教授。忙しい。贈りたかった。誕生日。でも試した。きつすぎ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'No problem. We can exchange. What size does she need? Our analysis of returns. Size issues. Common. We help. Good customer service. Our skill.', '問題ない。交換できる。必要なサイズは？返品の分析。サイズ問題。よくある。手伝う。良い顧客対応。当店の腕。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Large. She thought medium. But she needs large. Same shirt. Environmental one. Green. From that section. Forward. By the window.', 'L。Mだと思ってた。でもLが必要。同じシャツ。環境の。緑。あのセクションの。前方。窓際。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Let me check. Large. Green. Environmental line. One moment. The benefit of our policy. No stress. We want happy customers. Your sister. Happy professor.', '確認する。L。緑。環境ライン。少々。ポリシーの利点。ストレスなし。嬉しいお客様に。お妹様。嬉しい教授に。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Thanks. My sister will appreciate it. She has a meeting. With a lawyer. Tomorrow at 10 AM. Needs the shirt. Professional look.', 'ありがとう。妹は感謝する。会議がある。弁護士と。明日10時AM。シャツが必要。プロの見た目。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Here. Large. Green. Environmental. Same quality. Good skill in our products. Fits any body. Unisex. For any sex. Versatile.', 'どうぞ。L。緑。環境。同じ品質。商品の腕。どんな体型にも。ユニセックス。性別問わず。汎用。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Perfect. Can she try it here? Before I take it? Or is the exchange final? I want to get it right. Forward thinking.', '完璧。ここで試せる？持って行く前に？それとも交換で確定？正しくしたい。前向きに。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'She can try. Fitting room. That way. Or take it. Exchange again if needed. Thirty days. No problem. Present with confidence.', '試せる。試着室。あちら。または持って行く。必要ならまた交換。30日。問題ない。自信を持って贈って。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I will take it. She is not with me. At the university. Professor duties. I will bring it. 6 PM. Dinner. Her present. Hope it fits.', 'いただきます。一緒にいない。大学で。教授の仕事。持っていく。6時PM。ディナー。彼女のプレゼント。合うといい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'It will. Large is our best seller. Analysis of feedback. Comfortable. Good cut. Lawyer and professor approved. Many buy for work.', '合う。Lはベストセラー。フィードバック分析。快適。良い裁断。弁護士と教授に承認。仕事用に多く購入。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good to know. Same price? No extra? The exchange. Simple?', 'いい情報。同じ価格？追加料金なし？交換。シンプル？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Same price. No extra. Exchange is free. Benefit of shopping here. We value customers. Your sister. You. Come back. We have more. Environmental section. Growing.', '同じ価格。追加なし。交換無料。ここで買うメリット。お客様を大切に。お妹様。あなた。戻ってきて。もっとある。環境セクション。成長中。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will. My sister loves this store. Good skill in service. Really. She told me. Professor recommendation. Best in town.', 'そうする。妹はこの店が大好き。サービスの腕。本当に。言ってた。教授の推薦。街で最高。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. Here is your bag. Large. Green. Ready to present. 6 PM. She will love it. Happy birthday to her.', 'ありがとう。袋です。L。緑。贈る準備OK。6時PM。気に入る。誕生日おめでとう。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thanks for the help. The exchange was easy. Your analysis of the situation. Good. No stress. Forward to dinner.', '助けてくれてありがとう。交換は簡単だった。状況の分析。いい。ストレスなし。ディナーへ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Enjoy the dinner. 6 PM. Family time. Good present. Environmental. Thoughtful. Your sister. Lucky professor.', 'ディナー楽しんで。6時PM。家族の時間。良いプレゼント。環境。思いやり。お妹様。幸せな教授。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Thank you. I will come back. Maybe 8 PM. Another time. More shopping. For myself. Or my sister.', 'バイバイ。ありがとう。戻る。8時PMかも。別のとき。もう買い物。自分用。妹用。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. We close at 9 PM. See you. Take care.', 'バイバイ。9時PMまで。またね。お気をつけて。' FROM conv4;
