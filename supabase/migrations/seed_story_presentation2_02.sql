-- 3分ストーリー: プレゼンテーション②（2本目）
-- 使用単語: traditional, onto, reveal, direction, weapon, employee
-- theme_slug: presentation2 | situation_type: business | theme: プレゼンテーション②

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '質疑応答の対応',
    '聴衆からの質問に丁寧に答え、議論を深めるプレゼンテーションの練習。',
    3,
    62
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '質問を受ける', '最初の質問', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '回答の構成', 'データで説明', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '追加の質問', '深掘り', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '締め', 'まとめと感謝', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Thank you. Now for questions. The direction is this way. Use the microphone or raise your hand. I will call onto you one by one.', 'ありがとう。では質問を。方向はこちら。マイクか手を挙げて。指名します。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. You said we move onto the new system. I have a question about employee training. Our staff includes many senior people who prefer traditional methods.', 'はい。新システムへ移行と言った。従業員の訓練について。スタッフにはシニアが多く伝統的手法を好む。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Good question. Let me reveal slide twenty. Our training plan. The direction is clear. Each employee gets forty hours. Traditional classroom plus online. It is our weapon against resistance.', '良い質問。スライド20を明らかにする。訓練計画。方向は明確。各従業員に40時間。伝統的教室とオンライン。抵抗への武器。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Forty hours per employee. The direction onto the new process is clear. Traditional training works but what about time and cost?', '従業員あたり40時間。新プロセスへの方向は明確。伝統的訓練は機能するが時間とコストは？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Let me reveal the budget on slide twenty one. Training is included in the total project. No extra charge. Employee time is paid by the company. Our direction is onto success.', 'スライド21で予算を明らかに。訓練は合計プロジェクトに含む。追加料金なし。従業員時間は会社負担。方向は成功へ。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Another question. We have a traditional structure with departments. Will the direction change? Do we move onto a new org?', 'もう一つ。伝統的な部署構造がある。方向は変化？新組織へ？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'No. We maintain the traditional structure. Employee roles stay the same. The direction is onto process change, not people. Let me reveal the chart on slide twenty two.', 'いいえ。伝統的構造を維持。従業員の役割は同じ。方向はプロセスへ、人ではない。スライド22のチャートを明らかに。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Process not people. That is good. Employees will feel relief. The direction is clear onto implementation. It is a weapon against fear.', 'プロセスで人ではない。いい。従業員は安心する。実装への方向は明確。恐怖への武器。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Exactly. Traditional values put employee first. The direction of our culture goes onto the future with the same spirit. I reveal our commitment.', 'その通り。伝統的価値観で従業員第一。文化の方向は同じ精神で未来へ。コミットメントを明らかにする。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Last question. You said weapon against resistance. What weapon? Is it a metaphor or a real tool?', '最後の質問。抵抗への武器と言った。何の武器？比喩か本当のツールか？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'It is a metaphor. The weapon is knowledge through training and support. The direction goes onto confidence. Employees are empowered. Traditional values with modern tools. Let me reveal the strategy.', '比喩。武器は知識、訓練とサポートで。方向は自信へ。従業員に力を。伝統的価値観と現代ツール。戦略を明らかにする。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Thank you. That is clear. Direction onto success. Employees are supported. Traditional approach is maintained. Good.', 'ありがとう。明確。成功への方向。従業員は支援される。伝統的アプローチは維持。いい。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Any more questions? I am happy to reveal all now. The direction is open onto discussion. Employee questions are welcome.', '他に？今すべて明らかにする。討論への方向はオープン。従業員の質問は歓迎。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'No. Thank you. The direction is clear onto the next phase. Employees are ready. The traditional approach works.', 'いいえ。ありがとう。次フェーズへの方向は明確。従業員は準備。伝統的アプローチは機能する。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Summary. I reveal the key points. Direction is clear onto implementation. Employee training. Traditional values. The weapon is knowledge. Thank you.', 'サマリー。要点を明らかにする。実装への方向は明確。従業員訓練。伝統的価値観。武器は知識。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. Direction onto success. We support employee first. Traditional culture maintained. Good presentation.', 'ありがとう。成功への方向。従業員第一で支援。伝統的文化を維持。いいプレゼンだった。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I will reveal the materials by email tomorrow. Direction is onto action. The employee checklist is ready.', 'バイバイ。資料は明日メールで明らかにする。アクションへの方向。従業員チェックリストは準備済み。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. Traditional follow up. The direction looks professional onto implementation. Thank you.', 'いい。伝統的なフォローアップ。実装への方向はプロ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'You are welcome. Employee questions later by email. I can reveal more. The direction is always open.', 'どういたしまして。従業員の質問は後でメールで。もっと明らかにできる。方向はいつもオープン。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good day to you.', 'バイバイ。よい一日を。' FROM conv4;
