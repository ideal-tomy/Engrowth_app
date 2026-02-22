-- 3分ストーリー: プレゼンテーション①（3本目）
-- 使用単語: hang, entire, rock, forget, claim, note, remove, help, close
-- theme_slug: presentation1 | situation_type: business | theme: プレゼンテーション①

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '課題の提示と問題提起',
    'プロジェクトの課題を明確に提示し、聴衆に問題意識を共有するプレゼンの練習。',
    3,
    58
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '課題の紹介', '何が問題か', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'データで示す', '定量的な根拠', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '影響の説明', 'ビジネスへの影響', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '解決の必要性', 'アクションの緊急性', 'business', 'プレゼンテーション①'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Thank you. Now. The challenges. We claim. Three main issues. I will note. Each. Please hang on. Entire picture. Then we discuss.', 'ありがとう。では。課題。主張する。3つの主要問題。注記する。それぞれ。ついてきて。全体像。議論する。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Three issues. What are they? We need to understand. The entire scope. Before solutions.', '3つの問題。何？理解する必要。全体のスコープ。解決策の前に。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Issue one. Cost. Rising. Entire supply chain. We cannot forget. Twenty percent. Up. Last year. Rock solid data. Slide ten.', '問題1。コスト。上昇。サプライチェーン全体。忘れられない。20パーセント。増。去年。揺るがないデータ。スライド10。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Twenty percent. Entire chain? That hurts. We need to remove. Waste. Inefficiency. Help the margin.', '20パーセント。チェーン全体？痛い。除去する必要。無駄。非効率。マージンを助ける。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Exactly. Issue two. Quality. Complaints. Up. We claim. Customer data. Note the trend. Slide eleven. Close to crisis.', 'その通り。問題2。品質。苦情。増。主張する。顧客データ。トレンドに注記。スライド11。危機に近い。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Crisis? Really? Do not forget. We need facts. Rock solid. Not panic. Calm analysis.', '危機？本当？忘れるな。事実が必要。揺るがない。パニックじゃない。冷静な分析。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Fair. I said close. Not there yet. But trend. Entire picture. Clear. We need help. Action. Remove the root cause. Before it rocks. The company.', 'フェア。近いと言った。まだそこじゃない。でもトレンド。全体像。明確。助けが必要。アクション。根本原因を除去。揺らす前に。会社を。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Root cause. What? We need to know. Note it. For the team. Entire organization. Must understand.', '根本原因。何？知る必要。注記。チームに。組織全体。理解 must。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Slide twelve. Three causes. We claim. Training. Lack. Process. Outdated. Technology. Gap. Entire system. Needs update. We will discuss. Solutions. Next.', 'スライド12。3つの原因。主張。訓練。欠如。プロセス。時代遅れ。技術。ギャップ。システム全体。更新が必要。議論する。解決策。次。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Hang on. Training. Process. Technology. Entire picture. Makes sense. We cannot forget. People. Also.', '待って。訓練。プロセス。技術。全体像。筋が通る。忘れられない。人。も。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Yes. People. Part of it. We claim. Culture. Change. Needed. Entire organization. Rock the boat. Gently. But. Move. Forward.', 'はい。人。その一部。主張。文化。変化。必要。組織全体。波を立てる。優しく。でも。前進。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Rock the boat. Careful. Remove resistance. Help people. Understand. Entire plan. Note. Communication. Key.', '波を立てる。注意。抵抗を除去。人を助ける。理解。全体プラン。注記。コミュニケーション。鍵。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Exactly. Close the gap. Between. Management. Staff. Entire company. Aligned. We claim. This will help. Productivity. Quality. Cost.', 'その通り。ギャップを閉じる。との間。経営。スタッフ。会社全体。整合。主張。これは助ける。生産性。品質。コスト。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Summary. Entire challenge. Three issues. Three causes. We need help. Remove. Fix. Rock solid plan. Note. Next slide. Timeline.', 'サマリー。課題全体。3つの問題。3つの原因。助けが必要。除去。修正。揺るがないプラン。注記。次のスライド。タイムライン。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Six months. Phase one. Remove. Quick wins. Phase two. Entire system. Overhaul. Phase three. Sustain. Do not forget. Long term.', '6ヶ月。フェーズ1。除去。早い成果。フェーズ2。システム全体。オーバーホール。フェーズ3。維持。忘れるな。長期。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Six months. Tight. We need help. External? Consultants? Entire project. Big. Resource.', '6ヶ月。きつい。助けが必要。外部？コンサル？プロジェクト全体。大きい。リソース。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'We will discuss. Budget. Next section. But. We claim. ROI. Positive. Eighteen months. Rock solid. Data. Back it. Note. Appendix.', '議論する。予算。次セクション。でも。主張。ROI。プラス。18ヶ月。揺るがない。データ。裏付け。注記。付録。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. I will hang on. For solutions. Entire plan. Want to see. Remove my doubt. Help. Convince.', 'いい。待つ。解決策。プラン全体。見たい。疑いを除去。助け。納得。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Next. Solutions. Three. Match. The issues. We close. The loop. Entire picture. Complete. Thank you. Questions? After.', '次。解決策。3つ。マッチ。問題に。ループを閉じる。全体像。完全。ありがとう。質問？後で。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Thank you. Clear. Entire challenge. Noted. We will not forget. Help. Needed. Understood.', 'ありがとう。明確。課題全体。注記した。忘れない。助け。必要。理解した。' FROM conv4;
