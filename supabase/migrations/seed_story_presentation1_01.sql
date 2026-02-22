-- 3分ストーリー: プレゼンテーション①（1本目）
-- 使用単語: discuss, indeed, force, truth, example, democratic, check, environment, leg, dark, public
-- theme_slug: presentation1 | situation_type: business | theme: プレゼンテーション①

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'プレゼンの導入と現状分析',
    '国際会議でプレゼンテーションの冒頭で聴衆の注意を引き、目的と現状分析を伝える練習。',
    3,
    56
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'オープニング', '聴衆への挨拶', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '目的の説明', '本日のゴール', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '現状分析', 'データの提示', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '質疑の誘導', '質問を促す', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good morning everyone. Thank you for coming. Today we will discuss our project. The truth about our progress. And the challenges. Please check the handout.', 'おはようございます。お越しありがとう。本日私たちのプロジェクトを議論します。進捗の真実。そして課題。資料をご確認ください。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'What is the main point? I want to understand. The environment part. Sustainability. Is that the focus?', '主なポイントは？理解したい。環境の部分。持続可能性。それが焦点？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. Indeed. Environment is key. We will discuss three legs. First. Current state. Second. Challenges. Third. Solutions. Democratic approach. Everyone''s input matters.', 'はい。確かに。環境が鍵。3つの脚を議論。1。現状。2。課題。3。解決策。民主的アプローチ。皆の意見が大事。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. No dark areas. I hope. Transparent. Public data. The truth. We need facts.', 'いい。暗い領域なしで。願う。透明。公開データ。真実。事実が必要。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Absolutely. The force of our data. Real numbers. I will show. Example. Last year. Carbon. Down ten percent. True. Verified.', 'もちろん。データの力。実数。示す。例。去年。炭素。10パーセント減。真実。検証済み。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Ten percent? That is good. But what about the dark side? Problems? We need the full picture.', '10パーセント？いい。でも暗い側は？問題？全体像が必要。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Fair point. We will discuss. Leg one. Success. Leg two. Problems. Indeed. We have some. Cost. Technology. Leg three. Path forward.', ' fair point。議論する。脚1。成功。脚2。問題。確かに。いくつかある。コスト。技術。脚3。前進の道。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Check the timeline. When? Public commitment. We need dates. Democratic. Accountability.', 'タイムラインを確認。いつ？公約。日付が必要。民主的。説明責任。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Slide five. Timeline. Q4. This year. Next. Force of change. We are committed. Environment. Our priority. Truth. No hiding.', 'スライド5。タイムライン。Q4。今年。次。変化の力。コミットしてる。環境。最優先。真実。隠さない。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Good. Example? Another company? Did this work? Before?', 'いい。例？他社？うまくいった？以前？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Yes. Example. Company X. Europe. Similar project. Environment focus. Reduced emissions. Thirty percent. Five years. Public data. You can check.', 'はい。例。会社X。ヨーロッパ。似たプロジェクト。環境焦点。排出削減。30パーセント。5年。公開データ。確認できる。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Thirty percent. Strong. The force of regulation? Or voluntary? Democratic choice?', '30パーセント。強い。規制の力？自主的？民主的選択？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Both. Regulation. Leg one. Voluntary. Leg two. Truth. They did both. Public pressure. Consumer demand. Environment. Main driver.', '両方。規制。脚1。自主的。脚2。真実。両方した。世論の圧力。消費者需要。環境。主な原動力。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Our dark areas? Where do we lag? Be honest. Discuss. Open.', '私たちの暗い領域？どこが遅れてる？正直に。議論。オープンに。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Slide eight. Our gaps. Supply chain. Leg one. Transportation. Leg two. Packaging. Leg three. We discuss. Today. Solutions. Next section.', 'スライド8。私たちのギャップ。サプライチェーン。脚1。輸送。脚2。包装。脚3。議論する。今日。解決策。次セクション。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Questions now? Or later? Democratic. I have one. The cost. Who pays? Public? Company?', '今質問？後で？民主的に。1つある。コスト。誰が払う？公的？会社？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Good question. We will discuss. In Q and A. After. But briefly. Shared. Indeed. Company. Government. Customers. Force of collective. Environment. Everyone.', '良い質問。議論する。Q&Aで。後で。でも簡潔に。共有。確かに。会社。政府。顧客。集合の力。環境。皆。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Check. So we continue? Next section? Solutions? I am ready.', '確認。続ける？次セクション？解決策？準備できてる。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Yes. Next. Solutions. The truth. We have a plan. Three legs. I will show. Example. Timeline. Force. Let us move.', 'はい。次。解決策。真実。プランがある。3つの脚。示す。例。タイムライン。力。進もう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Thank you. Clear. Public. Democratic. No dark corners. I appreciate.', 'ありがとう。明確。公開。民主的。暗い隅なし。感謝。' FROM conv4;
