-- 3分ストーリー: プレゼンテーション①（2本目）
-- 使用単語: various, rather, laugh, guess, executive, set, study, prove
-- theme_slug: presentation1 | situation_type: business | theme: プレゼンテーション①

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '市場分析の発表',
    '市場の現状とトレンドを分析し、データに基づいて説明するプレゼンテーションの練習。',
    3,
    57
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'テーマの提示', '市場概要', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'データの提示', '数値で示す', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '解釈', '意味の説明', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'まとめ', '主要メッセージ', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good afternoon. Today we present. Market study. Our executive team. Set the goals. Various segments. We will cover. Rather comprehensive.', 'こんにちは。本日発表。市場調査。当社幹部チーム。目標をセット。様々なセグメント。カバーする。むしろ包括的。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Executive? Who approved? We need to know. The study. Credibility.', '幹部？誰が承認？知る必要。調査。信頼性。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'CEO. CFO. Full approval. We studied. Six months. Various sources. Data. Interviews. Set methodology. Prove our work. Rigorous.', 'CEO。CFO。完全承認。研究した。6ヶ月。様々な情報源。データ。インタビュー。手法をセット。成果を証明。厳格。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Various sources. Good. Not just one. Rather diverse. I guess. More reliable.', '様々な情報源。いい。1つじゃない。むしろ多様。推測する。より信頼できる。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Exactly. No guess work. Facts. Numbers. Executive summary. Page one. Set the stage. Then details. Various sections.', 'その通り。推測なし。事実。数字。エグゼクティブサマリー。1ページ。場をセット。次に詳細。様々なセクション。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Slide three. Growth. Fifteen percent. Is that real? Or guess? Prove it.', 'スライド3。成長。15パーセント。本当？推測？証明して。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Real. We studied. Five hundred companies. Various industries. Set criteria. Strict. Prove the number. Audit. External. Executive reviewed.', '本当。研究した。500社。様々な産業。基準をセット。厳格。数字を証明。監査。外部。幹部レビュー。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Various industries. Rather broad. Does that work? Different sectors. Different rules.', '様々な産業。むしろ広い。機能する？異なるセクター。異なるルール。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'We segmented. By sector. Various charts. Slide five. Six. Seven. Each. Executive can dig. Deep. Study. Prove. Your point.', 'セグメント化した。セクター別。様々なチャート。スライド5。6。7。それぞれ。幹部は掘れる。深く。研究。証明。あなたの論点。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Do not make me laugh. Slide seven. That number. Really? Various ways to read it. Right?', '笑わせるな。スライド7。あの数字。本当？様々な読み方。だよね？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Fair. Various interpretations. We present. Our study. Our conclusion. Executive agreed. You can disagree. Debate. Prove your view. Data. Not guess.', 'フェア。様々な解釈。提示する。私たちの研究。私たちの結論。幹部同意。反対できる。議論。あなたの見解を証明。データ。推測じゃない。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Okay. I will study. The full report. Set aside time. Various sections. Dig in. Rather long. But important.', 'OK。研究する。完全レポート。時間を確保。様々なセクション。掘る。むしろ長い。でも重要。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good. Executive summary. Ten pages. Main points. Set. Clear. Prove. Our case. Then. Full report. Two hundred. Various appendices.', 'いい。エグゼクティブサマリー。10ページ。要点。セット。明確。証明。私たちの主張。次に。完全レポート。200。様々な付録。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Rather impressive. The work. Six months. Various sources. Set methodology. Prove results. I guess. You are confident.', 'むしろ印象的。仕事。6ヶ月。様々な情報源。手法をセット。結果を証明。推測する。自信がある。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'We are. Executive backing. Full. Study. Rigorous. Various checks. Prove. Every claim. No guess. Facts. Always.', 'ある。幹部の後押し。完全。研究。厳格。様々なチェック。証明。あらゆる主張。推測なし。事実。常に。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Summary. Main message? For executive? One thing. What?', 'サマリー。主なメッセージ？幹部に？1つ。何？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Growth. Sustainable. Proven. Various markets. Study shows. Set strategy. Works. Executive decision. Invest. Or not. Data. Not guess.', '成長。持続可能。証明済み。様々な市場。研究が示す。戦略をセット。機能する。幹部の決定。投資。しない。データ。推測じゃない。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Clear. Thank you. I will study. Report. Various angles. Prove. To myself. Then decide.', '明確。ありがとう。研究する。レポート。様々な角度。証明。自分に。決める。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good. Questions? Now? Or later? Executive. We are here. Set time. Discuss. Prove. Answer.', 'いい。質問？今？後で？幹部。こちらに。時間をセット。議論。証明。答える。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Later. Need to study. First. Rather complex. Various points. Thank you.', '後で。研究が必要。まず。むしろ複雑。様々なポイント。ありがとう。' FROM conv4;
