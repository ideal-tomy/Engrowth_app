-- 3分ストーリー: プレゼンテーション①（5本目）
-- 使用単語: science, green, memory, card, above, seat
-- theme_slug: presentation1 | situation_type: business | theme: プレゼンテーション①

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '研究結果の発表',
    '調査・研究の結果を聴衆に分かりやすく説明するプレゼンテーションの練習。',
    3,
    60
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '研究の概要', '目的と方法', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '主要発見', 'データの提示', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '解釈', '意味づけ', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '推奨事項', 'アクション提案', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good afternoon, everyone. Today I will present our science research on green technology. The key findings are above expectations. Please take a seat and get comfortable. We have plenty of time.', 'こんにちは、皆さん。本日グリーン技術の科学研究を発表します。主な発見は期待以上。どうぞお座りください。時間は十分あります。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Green technology is interesting. Is it science based? We need real evidence and data, not just marketing. We want to see actual research.', 'グリーン技術は興味深い。科学ベース？証拠とデータが必要。マーケティングだけじゃなく本当の研究を。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Absolutely. Let me show slide two. Our methodology is rigorous science. Six months in the lab and field. All data is stored in memory and verified. There is a card on your seat with a summary.', 'もちろん。スライド2へ。方法論は厳格な科学。6ヶ月のラボとフィールド。データはメモリに保存し検証済み。座席にサマリーのカードあり。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'The card on my seat is helpful. I have it here. The summary shows the main points. The details must be in the slides.', '座席のカードは便利。持ってる。サマリーで要点が分かる。詳細はスライドに。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Our main findings are three. All above our target. First, efficiency is up thirty percent. Science has proven the green impact is real.', '主な発見は3つ。全て目標以上。1つ目は効率30パーセント増。科学でグリーンの影響が証明された。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Thirty percent above target? What was the original target?', '30パーセント目標以上？元の目標は何だった？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'We said twenty percent. That was our target. But we hit thirty. Above our goal. Science surprised us too. Green tech works better than we expected.', '20パーセントと言っていた。目標だった。でも30を達成。以上。科学でも驚いた。グリーン技術は予想より良く機能。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'What about the second finding? The card says cost went down. Is that correct from memory?', '2つ目の発見は？カードにコスト減とある。メモリ通り正しい？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Yes. Cost is down fifteen percent. Green materials are cheaper now. Science and development at scale went above our forecast.', 'はい。コスト15パーセント減。グリーン素材は今安い。科学と開発のスケールは予測以上。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'And the third finding? The card has limited space. Is there more above on the slide?', '3つ目は？カードはスペースが限られてる。スライドにもっと以上に？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Slide six shows the third finding. Customer satisfaction is up forty percent. Our science survey data is stored in memory. Green products are preferred above competitors.', 'スライド6が3つ目。顧客満足度40パーセント増。科学調査データはメモリに保存。グリーン製品は競合以上に好まれる。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Forty percent above competitors is strong. Science backs our marketing claim. Green is real, not just words.', '競合40パーセント以上は強い。科学がマーケティング主張を裏付ける。グリーンは本当、言葉だけじゃない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Exactly. Please sit back and relax. Good news. All three findings are above target. Science shows a green future is bright.', 'その通り。座り直してリラックス。良い知らせ。3つとも目標以上。科学がグリーンの未来は明るいと示す。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'What about your recommendations? The card mentions next steps above the summary. What are they?', '推奨事項は？カードのサマリー以上に次ステップとある。何？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Slide eight covers that. We should scale production of green tech. Science supports investing more above our current level. Memory and budget details are in the card appendix.', 'スライド8で。グリーン技術の生産をスケールすべき。科学が現レベル以上の投資を支援。メモリと予算はカード付録に。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Invest more above current levels. Science says go green and it pays. I will keep that in memory for the decision.', '現レベル以上の投資。科学はグリーンへ進めと言う。決定のためメモリに留める。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Yes. On the final slide we have the summary. Science and green. All three above target. Take the card from your seat. Memory and share it with your team. Above all, invest.', 'はい。最終スライドがサマリー。科学とグリーン。3つとも目標以上。席のカードを持って。メモリしてチームと共有。何より投資を。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thank you. It was clear. Science and green above expectations. The card is useful. Good seat. I will keep the key points in memory.', 'ありがとう。明確だった。科学とグリーンは期待以上。カードは有用。席が良かった。キーポイントをメモリする。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Any questions? Above what we covered in the slides, is there anything you would like to discuss now or later by email?', '質問は？スライドで触れた以上のことで今または後でメールで議論したいことは？' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Later, please. I need to process and review the card in memory. Then I will reply. Thank you.', '後でお願い。メモリでカードを処理してレビューしたい。それから返信する。ありがとう。' FROM conv4;
