-- 3分ストーリー: 銀行口座開設（3本目）
-- 使用単語: finish, yourself, theory, impact, respond
-- theme_slug: bank | situation_type: student | theme: 銀行口座開設

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '書類記入のサポート',
    '口座開設の書類に記入する際、わからない箇所を銀行員に尋ねる会話。',
    3,
    68
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '用紙を受け取る', '記入開始', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '不明点の確認', '質問', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '記入完了', '確認', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '次のステップ', 'カードなど', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'I have the form. To finish. Myself? Or you help? Theory. I can do. But. Impact. Of. Mistake. Scary. I want. To respond. Correctly.', '用紙がある。終える。自分で？あなたが手伝う？理論的にはできる。でも。間違いの影響。怖い。正しく対応したい。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'I will help. Section. By section. Yourself. Fill. I guide. Theory. Simple. But. Impact. Important. We respond. Together. No. Mistake.', '手伝う。セクション。ずつ。自分で。記入。私が案内。理論。シンプル。でも。影響。重要。一緒に対応。ミスなし。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Section one. Name. Theory. Easy. Myself. Can do. Impact. Of. Typo. Bad? Respond. How? If wrong?', 'セクション1。名前。理論。簡単。自分で。できる。タイプミスの影響。悪い？対応。どう？間違えたら？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We check. Before. Finish. Impact. Minimal. If. Catch. Early. Respond. Fast. Fix. Yourself. Or. I help. No. Problem.', '確認する。前に。終える。影響。最小。もし早く気づけば。対応。速い。修正。自分で。または私が。問題なし。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Good. Theory. Relax. Myself. Finish. Calm. Impact. Of. Stress. Bad. Respond. Better. When. Calm. Right?', 'いい。理論。リラックス。自分。終える。落ち着いて。ストレスの影響。悪い。対応。 better。落ち着いてる時。だよね？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Exactly. Section two. Address. Yourself. Write. Theory. Passport. Match. Impact. On. Mail. Card. Will. Come. Respond. To. Verify. Later.', 'その通り。セクション2。住所。自分で。書く。理論。パスポートに一致。影響。郵便に。カード。来る。対応。確認。後で。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Section three. Employment? Student. Theory. Unemployed? Or. Self? Employed? Impact. On. Account? How. To respond?', 'セクション3。雇用？学生。理論。無職？自営？影響。口座に？どう対応？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Student. Counts. Put. Student. Theory. Education. Investment. Impact. Positive. Bank. Likes. Students. Respond. With. Good. Rates.', '学生。カウントする。学生と書く。理論。教育。投資。影響。ポジティブ。銀行。学生好き。対応。良い金利で。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. Theory. Students. Low. Risk. Impact. On. Bank. Positive. Respond. With. Support. Nice.', 'いい。理論。学生。低リスク。影響。銀行に。ポジティブ。対応。サポートで。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Section four. Last. Finish. Soon. Yourself. Almost. Done. Theory. Simple. Impact. Great. Account. Ready. We respond. To. Application. Fast.', 'セクション4。最後。すぐ終わる。自分で。ほぼ完了。理論。シンプル。影響。大きい。口座。準備。申請に対応。速く。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Finish. Done. Myself. Theory. With. Help. Impact. Feel. Proud. Respond. To. Challenge. Good. Step. Adult. Life.', '終える。完了。自分で。理論。助けと。影響。誇りを感じる。対応。挑戦に。良い。一歩。大人の生活。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Yourself. Did. It. Theory. Correct. Impact. Account. Open. Soon. Respond. To. Email. Tomorrow. Confirmation.', 'はい。自分で。やった。理論。正しい。影響。口座。 soon 開く。対応。メールに。明日。確認。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Email. Tomorrow. Theory. Digital. First. Impact. Fast. No. Wait. Respond. Quick. Modern. Bank. Good.', 'メール。明日。理論。デジタル。第一。影響。速い。待たない。対応。速い。現代。銀行。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Card. Seven. Days. Theory. Mail. Physical. Impact. Can use. ATM. Shop. Respond. To. Any. Request. Online. First. Digital. Card.', 'カード。7日。理論。郵送。物理的。影響。使える。ATM。店。対応。あらゆる。リクエストに。オンライン。まず。デジタルカード。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Finish. Today. Theory. Account. Set. Impact. Big. Life. Here. Respond. To. Needs. Money. Management. Start. Now.', '今日終える。理論。口座。セット。影響。大きい。生活。ここで。対応。ニーズに。お金。管理。今始める。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Summary. Finish. Form. Done. Yourself. With. Help. Theory. Correct. Impact. Positive. Respond. Tomorrow. Email. Bye.', 'サマリー。終える。用紙。完了。自分で。助けと。理論。正しい。影響。ポジティブ。対応。明日。メール。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Theory. Not. So. Hard. Myself. Managed. Impact. Of. Good. Service. Big. Respond. Grateful. Bye.', 'ありがとう。理論。そんなに。難しくない。自分で。なんとか。良いサービスの影響。大きい。対応。感謝。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Finish. Strong. Yourself. Theory. Independent. Impact. Good. Life. Skill. Respond. Well. To. Future. Bye.', 'どういたしまして。終える。強く。自分で。理論。自立。影響。良い。生活スキル。うまく対応。未来に。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Theory. Good. Bank. Impact. Recommend. Friends. Respond. Same. Help. Thank you.', 'バイバイ。理論。良い。銀行。影響。勧める。友達に。対応。同じ。助け。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care. Good luck.', 'バイバイ。お気をつけて。頑張って。' FROM conv4;
