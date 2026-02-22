-- 3分ストーリー: 銀行口座開設（2本目）
-- 使用単語: management, cup, avoid, imagine, tonight, huge
-- theme_slug: bank | situation_type: student | theme: 銀行口座開設

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '口座の種類の選択',
    '普通預金、貯蓄預金、当座預金の違いを聞き、自分の用途に合う口座を選ぶ会話。',
    3,
    67
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '口座タイプの説明', 'それぞれの特徴', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '手数料の確認', '月額や維持手数料', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'デビットカード', 'カードの発行', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '登録完了', 'お礼', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need help. Account types. Management. Of my money. I am a student. Huge. Confused. So many options. Imagine. First time. Banking. Here.', 'こんにちは。助けが必要。口座タイプ。管理。お金の。学生です。 massive。混乱。たくさんオプション。想像して。初めて。銀行。ここで。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'No problem. Cup of tea? We have. Management. Advice. Free. For students. Avoid. Confusion. I explain. Simple. Imagine. Three. Choices. That is all.', '問題ない。お茶？ある。管理。アドバイス。無料。学生向け。避ける。混乱。説明する。シンプル。想像して。3つ。選択。それだけ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Three. Only. Nice. Management. Simple. I like. Huge. Relief. Tonight. I sleep. Better. No worry.', '3つ。だけ。いい。管理。シンプル。好き。 massive。安心。今夜。眠れる。よく。心配なし。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Choice one. Basic checking. Daily. Use. Cup. Coffee. Food. Shopping. Management. Easy. Avoid. Fees. Min. Balance. Five hundred.', '選択1。基本当座。日常。使用。コーヒー。食事。買い物。管理。簡単。避ける。手数料。最低残高。500。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Five hundred. Huge. For me. Student. Budget. Tight. Imagine. Less? Management. Option?', '500。大きい。私に。学生。予算。厳しい。想像して。少ない？管理。オプション？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Choice two. Student account. Zero. Min. Balance. Management. Free. Avoid. All. Fees. Tonight. Sign up. Special. For you.', '選択2。学生口座。ゼロ。最低残高。管理。無料。避ける。すべて。手数料。今夜。申し込み。特別。あなたに。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Student. Account. Perfect. Management. No fee. Avoid. Stress. Huge. Help. Imagine. Saving. Money. For. Course. Books.', '学生。口座。完璧。管理。手数料なし。避ける。ストレス。大きい。助け。想像して。節約。お金。授業。本に。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Choice three. Savings. Interest. Small. But. Management. Grow. Money. Avoid. Spend. Easy. Transfer. To. Checking. Cup. Of. Coffee. When. Need.', '選択3。貯蓄。利息。小さい。でも。管理。増やす。お金。避ける。使う。簡単。送金。当座へ。コーヒー。1杯。必要な時。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'So. Management. Two accounts? Checking. Savings? Both? Student. Package? Huge. Deal?', 'つまり。管理。2口座？当座。貯蓄？両方？学生。パッケージ？大きい。お得？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Both. Free. Management. One. App. Avoid. Complexity. Huge. Popular. Students. Imagine. Simple. Life.', 'はい。両方。無料。管理。1つ。アプリ。避ける。複雑さ。大きい。人気。学生。想像して。シンプル。生活。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Debit card? Tonight? Can use? Management. Cash. Avoid. Carry. Huge. Amounts. Imagine. Safe.', 'デビットカード？今夜？使える？管理。現金。避ける。持ち歩く。大量。想像して。安全。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Card. Seven. Days. Management. Mail. To. You. Avoid. Wait. Long. Huge. Relief. Students. Need. Fast. Tonight. Online. Shopping. Temporary. Card. Digital.', 'カード。7日。管理。郵送。あなたへ。避ける。待つ。長く。大きい。安心。学生。必要。速く。今夜。オンライン。ショッピング。仮。カード。デジタル。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Digital. Card. Tonight? Management. Immediate? Avoid. Wait? Huge. Great. Imagine. Order. Food. Later.', 'デジタル。カード。今夜？管理。即座？避ける。待つ？大きい。すごい。想像して。注文。食事。後で。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Setup. Now. Management. App. Avoid. Delay. Huge. Feature. Students. Love. Cup. Of. Coffee. Order. Tonight. Done.', 'はい。セットアップ。今。管理。アプリ。避ける。遅れ。大きい。機能。学生。大好き。コーヒー。1杯。注文。今夜。完了。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Management. Excellent. Avoid. All. Hassle. Huge. Thanks. Imagine. Without. This. Help. Lost. Tonight. Still. Searching.', '管理。素晴らしい。避ける。すべて。面倒。大きい。ありがとう。想像して。この助けなし。迷子。今夜。まだ。探してる。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'You are welcome. Management. Key. To. Success. Avoid. Debt. Huge. Tip. For. Students. Imagine. Budget. Stick. To. It. Tonight. Plan. Week.', 'どういたしまして。管理。鍵。成功に。避ける。借金。大きい。ヒント。学生に。想像して。予算。守る。今夜。計画。1週間。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Will do. Management. App. Setup. Tonight. Avoid. Overspend. Huge. Goal. Save. For. Trip. Spring. Break.', 'そうする。管理。アプリ。セットアップ。今夜。避ける。使いすぎ。大きい。目標。貯金。旅行。春休み。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good plan. Management. Start. Early. Avoid. Stress. Huge. Difference. Imagine. Relaxed. Spring. Break. Money. Ready.', '良いプラン。管理。早く始める。避ける。ストレス。大きい。違い。想像して。リラックス。春休み。お金。準備。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. Cup. Of. Coffee. Sometime? Maybe. Next. Visit? Management. Question? Imagine. I will. Have. Some.', 'ありがとう。コーヒー。1杯。いつか？かも。次。来店？管理。質問？想像する。ある。いくつか。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Always. Welcome. Bye. Good. Luck. Management. Success.', 'いつでも。歓迎。バイバイ。頑張って。管理。成功。' FROM conv4;
