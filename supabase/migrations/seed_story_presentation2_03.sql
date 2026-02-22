-- 3分ストーリー: プレゼンテーション②（3本目）
-- 使用単語: cultural, contain, peace, pain, apply
-- theme_slug: presentation2 | situation_type: business | theme: プレゼンテーション②

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '結論の提示',
    'プレゼンテーションの結論を明確に述べ、聴衆の賛同を得る練習。',
    3,
    63
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '結論の導入', 'まとめに入る', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '主要メッセージ', '3つのポイント', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '提案の呼びかけ', 'アクションを促す', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '感謝と締め', '質疑へ', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'We reach the conclusion now. Our summary contains three points that apply to our situation. Cultural change is needed. We need peace with the past and we must accept the pain of transition.', '結論に達する。サマリーは3つのポイントを含む。私たちの状況に適用。文化的変化が必要。過去との平和と移行の痛みの受容。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Cultural change and the pain of transition. Does that apply to all of us? What does the scope contain? Who is affected?', '文化的変化と移行の痛み。全員に適用？スコープに何が含む？誰が？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'It applies company wide. It contains all departments. The cultural shift brings peace after the pain. Short term pain, long term gain. The plan contains patience.', '社内全体に適用。すべての部署を含む。文化的シフトは痛みの後に平和。短期の痛み、長期の利益。計画には忍耐を含む。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Pain is short term. Peace is long term. The message contains hope. We apply it to ourselves. It is a cultural mindset shift.', '痛みは短期。平和は長期。メッセージは希望を含む。自分たちに適用。文化的マインドセット。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Exactly. Point one is to acknowledge the pain. Point two is to support the transition. Point three is peace with the new normal. The plan contains all of this. We apply it together.', 'その通り。ポイント1は痛みを認める。2は移行を支援。3は新しい常態との平和。計画はすべて含む。一緒に適用。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'What is your recommendation? When do we apply it? Does the plan contain a timeline? Cultural change takes time.', '推奨は？いつ適用？タイムラインを含む？文化的変化は時間がかかる。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'We apply in Q1. We start with a pilot that contains two teams. We do a cultural assessment first. The pain is manageable. We reach peace by Q3.', 'Q1に適用。2チームのパイロット含む。まず文化的アセスメント。痛みは管理可能。Q3で平和へ。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'A pilot that contains risk management. We test the cultural change. We apply small first. Less pain. Peace faster. Good.', 'リスクを含むパイロット。文化的変化をテスト。まず小さく適用。痛みは少なく。平和は早く。いい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'This is our call to action. Please apply your support. The plan contains our commitment. Cultural change needs everyone. Peace comes after pain. We do it together.', '行動の呼びかけ。あなたの支援を適用して。計画はコミットメントを含む。文化的変化は皆が必要。平和は痛みの後に来る。一緒に。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We support it. We will apply it to ourselves. The plan contains our energy. Cultural shift. Pain is temporary. Peace is the goal. Understood.', '支援する。自分たちに適用。計画はエネルギーを含む。文化的シフト。痛みは一時的。平和が目標。理解した。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. Any questions? Please apply your thoughts. Does the plan contain your concerns? Cultural perspective? Pain points? Peace vision?', 'ありがとう。質問は？考えを適用して。計画は懸念を含む？文化的視点？痛みのポイント？平和のビジョン？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'One question. Does the training apply cultural sensitivity? Does it contain that? Can we avoid the pain of misunderstanding?', '1つ。訓練は文化的感受性に適用？それを含む？誤解の痛みは避けられる？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Yes. We apply training that contains a cultural module. It reduces the pain of conflict. It promotes peace. Good question.', 'はい。文化的モジュールを含む訓練を適用。対立の痛みを減らす。平和を促進。良い質問。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Thank you. The plan to apply is clear. It contains everything. Cultural change. Pain is acknowledged. Peace ahead. Good.', 'ありがとう。適用するプランは明確。すべて含む。文化的変化。痛みは認めた。平和は先に。いい。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Summary. We apply the three points. The plan contains the full approach. Cultural commitment. Pain support. Peace as goal. Thank you all.', 'サマリー。3つのポイントを適用。計画は完全なアプローチを含む。文化的コミットメント。痛みへの支援。平和が目標。ありがとう皆さん。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. We will apply the plan. It will contain our feedback. Cultural notes. Pain is heard. Peace and hope ahead.', 'ありがとう。計画を適用する。フィードバックを含む。文化的メモ。痛みは聞いた。平和と希望が先に。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Materials go out by email tomorrow. They contain the slides and cultural resources. Something to ease the pain. Peace and reference for all.', '資料は明日メールで。スライドと文化的リソースを含む。痛みを和らげる。平和と参照を。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. We apply it to ourselves. We contain it in our team. We will share and discuss. Cultural change. Pain and peace. We build. Thank you.', 'いい。自分たちに適用。チームに含める。共有して議論。文化的変化。痛みと平和。構築する。ありがとう。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Apply with success. The plan contains hope. Cultural change. The pain is worth it. Peace ahead. Good day.', 'バイバイ。成功裡に適用。計画は希望を含む。文化的変化。痛みは価値ある。平和が先に。よい一日を。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Thank you. Good presentation.', 'バイバイ。ありがとう。いいプレゼンだった。' FROM conv4;
