-- 3分ストーリー: ビジネス自己紹介（4本目）
-- 使用単語: control, care, field, check, role, better, economic, strong, possible, heart, drug, leader
-- theme_slug: selfintro_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '製薬業界での自己紹介',
    '製薬会社の部門会議で、品質管理の役割と貢献を伝える会話。',
    3,
    14
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と役割', '会議で自己紹介を始める', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '品質管理の経験', '品質統制のフィールド経験', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '経済的インパクト', '品質改善のビジネス効果', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'リーダーとして', '今後の方針と連携', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good afternoon. I am Tom. I lead the quality control team. This is my first meeting with this group. Nice to meet you all.', 'こんにちは。トムです。品質管理チームを率いています。このグループとの初ミーティングです。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Tom. We need a strong leader in quality. Our drug pipeline is growing. We must check everything.', 'ようこそトム。品質に強いリーダーが必要なんです。医薬品パイプラインが拡大しています。全てをチェックしなければ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'That is my role. Quality control is at the heart of what we do. Every drug must be safe. I take that care seriously.', 'それが私の役割です。品質管理は私たちの仕事の中心です。全ての医薬品が安全でなければ。そのケアを真剣に考えています。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. We have had some issues in the field. Not major. But we want better processes. Is that possible?', 'いいですね。現場でいくつか問題がありました。大きなものではない。でもより良いプロセスが欲しい。可能ですか？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Yes. I have experience with this. We can make it better. I will check the current system first. Then propose changes.', 'はい。この経験があります。より良くできます。まず現行システムをチェックします。それから変更を提案します。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'What was your background? The drug field is special. We need people who understand.', '経歴は？医薬品の分野は特殊です。理解している人が必要です。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I worked in the field for ten years. Lab work. Then I moved to quality control. I learned that care at every step matters.', '現場で10年働きました。ラボ業務。それから品質管理に移りました。各ステップでのケアが重要だと学びました。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'That is the right heart. We cannot cut corners with drug safety. The economic cost of a recall is huge.', 'それが正しい心構えです。医薬品の安全で手を抜けません。リコールの経済的コストは莫大です。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Exactly. Strong control prevents problems. We check the process at each stage. Better early than late.', 'その通りです。強力な統制が問題を防ぎます。各段階でプロセスをチェック。遅くより早い方がいい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'So you see yourself as a leader in this field? We need someone to drive change.', 'つまりこの分野のリーダーとしてご自身を見ている？変革を推進する人が必要です。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I do. My role is to lead the team. We will make our control systems stronger. It is possible with the right plan.', 'そうです。私の役割はチームを率いることです。管理体制をより強くします。適切な計画で可能です。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'The economic impact of better quality is clear. Fewer recalls. Lower costs. Happier clients.', '品質向上の経済的影響は明確です。リコール削減。コスト低減。より満足する顧客。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'That is what I care about. Quality is not just a check box. It is the heart of our business. Every drug we make.', 'それを大事にしています。品質はチェックボックスじゃない。ビジネスの中心です。作る全ての医薬品。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Well said. We have a strong team. With you as leader we can do better. I will put you in touch with the field managers.', 'おっしゃる通り。強力なチームがあります。あなたがリーダーならより良くできる。現場マネージャーをご紹介します。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. I will check in with them this week. We need to understand the current control points. Then we improve.', 'ありがとう。今週彼らに連絡します。現在の統制ポイントを理解する必要があります。それから改善します。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Good. One more thing. Our new drug is in the final stage. Can you review the control data?', 'いいですね。もう一つ。新薬が最終段階にあります。統制データをレビューしてもらえますか？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Of course. I will give it my full care. Drug approval depends on strong data. I understand the role.', 'もちろん。全力でケアします。医薬品承認は強力なデータに依存します。役割は理解しています。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Perfect. You have the right heart for this. Welcome to the team. We are glad to have a leader like you.', '完璧。正しい心構えを持っている。チームへようこそ。あなたのようなリーダーを得て嬉しい。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. I will do my best. Better quality. Stronger control. That is the goal.', 'ありがとう。最善を尽くします。より良い品質。より強い統制。それが目標です。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'We are aligned. See you at the next meeting. Goodbye.', '一致しています。次回の会議で。さようなら。' FROM conv4;
