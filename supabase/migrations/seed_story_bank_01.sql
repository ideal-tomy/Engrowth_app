-- 3分ストーリー: 銀行口座開設（1本目）
-- 使用単語: establish, nice, trial, expert, spring, radio
-- theme_slug: bank | situation_type: student | theme: 銀行口座開設

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '口座開設の相談',
    '海外で銀行口座を開設するため、必要な書類と口座の種類について銀行員に相談する会話。',
    3,
    66
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '窓口へ', '開設の依頼', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '必要な書類', 'パスポートなど', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '口座の種類', '普通か貯蓄か', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'オンラインバンキング', 'アプリの案内', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I want to establish a bank account. I am new here. A student. From Japan. I heard on the radio. You help international students.', 'こんにちは。銀行口座を開設したい。新人です。学生。日本から。ラジオで聞いた。留学生を支援してると。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. Yes. We help students. Establish accounts. Nice to meet you. Spring is busy. Many new students. You are in good time.', 'ようこそ。はい。学生を支援。口座開設。お会いできて嬉しい。春は忙しい。多くの新入生。良い時期に。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Spring. Yes. Semester starts soon. I need an account. For my trial period. Six months. First. Maybe longer. Expert advice? What do I need?', '春。はい。学期が soon 始まる。口座が必要。トライアル期間のため。6ヶ月。最初。もっと長くかも。専門家のアドバイス？何が必要？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We have experts. Here. For students. Nice process. Simple. To establish. You need. Passport. Visa. Proof of address. Student ID. That is it.', '専門家がいる。ここに。学生向け。良いプロセス。シンプル。開設に。必要。パスポート。ビザ。住所証明。学生証。それだけ。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Proof of address? I just arrived. Spring. Last week. No bill yet. Radio said. Bank statement. From home. OK?', '住所証明？着いたばかり。春。先週。まだ請求書なし。ラジオが言った。銀行の明細。故郷から。OK？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Yes. That works. Establish. Identity. First. Address. Can wait. Trial. Period. Temporary. Address. OK. For now.', 'はい。それで行く。開設。身分。まず。住所。待てる。トライアル。期間。仮。住所。OK。今は。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Nice. So passport. Visa. Student ID. Bank statement. From Japan. I have. All. In my bag. Expert. Can check? Now?', 'いい。つまりパスポート。ビザ。学生証。銀行明細。日本から。持ってる。すべて。鞄に。専門家。チェックできる？今？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. One moment. I will get. The form. To establish. Your account. Nice. And quick. Spring. Rush. We are ready.', 'はい。少々。取る。用紙。開設に。あなたの口座。いい。そして速い。春。ラッシュ。準備OK。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Trial. Period. What does that mean? For the account? Expert. Explain?', 'トライアル。期間。どういう意味？口座の？専門家。説明？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'First six months. Trial. Lower fees. For students. Establish. Trust. Then. Full account. Nice. Benefit. Radio. Advertise. This. Popular.', '最初の6ヶ月。トライアル。低い手数料。学生向け。開設。信頼。その後。通常口座。いい。メリット。ラジオ。広告。これ。人気。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Two types? Checking? Savings? Which? For student? Expert. Recommend?', '2種類？当座？貯蓄？どれ？学生に？専門家。お勧め？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Both. Bundle. Nice. Package. Establish. Both. One visit. Trial. Period. Covers. Both. Spring. Special. For students.', '両方。バンドル。いい。パッケージ。開設。両方。1回の訪問。トライアル。期間。カバー。両方。春。特典。学生向け。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Both. Nice. I need. Checking. For daily. Savings. For. Trial. Budget. Spring. Semester. Expenses.', '両方。いい。必要。当座。日常用。貯蓄。トライアル。予算。春。学期。経費。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Perfect. Expert. Will process. Establish. Now. Form. Fill. Here. Nice. And easy. Radio. Said. Ten. Minutes. True.', '完璧。専門家。処理する。開設。今。用紙。記入。ここ。いい。そして簡単。ラジオ。言った。10分。本当。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Online banking? App? I heard. On radio. Mobile. Manage. Account? Establish. That. Too?', 'オンラインバンキング？アプリ？聞いた。ラジオで。モバイル。管理。口座？開設。それも？' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Yes. Automatic. When. Establish. Account. Nice. App. Free. For students. Trial. Period. No fee. Spring. Download. Today.', 'はい。自動。開設の時。口座。いい。アプリ。無料。学生向け。トライアル。期間。手数料なし。春。ダウンロード。今日。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Expert. Help. Set up? App? I am. Not. Tech. Expert. Trial. And error. Maybe.', '専門家。助け。セットアップ？アプリ？私は。そんなに。技術。専門家じゃない。試行錯誤。かも。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'No problem. We help. Establish. Everything. Nice. Staff. Expert. In app. Setup. Spring. Many. Students. Same. We know.', '問題ない。手伝う。開設。すべて。いい。スタッフ。専門家。アプリ。セットアップ。春。多くの。学生。同じ。わかってる。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. Nice. Service. Radio. Right. Good. Bank. For students. Establish. Account. Easy. Trial. Good. Start. Spring. Semester. Ready.', 'ありがとう。いい。サービス。ラジオ。正しい。良い。銀行。学生に。開設。口座。簡単。トライアル。良い。スタート。春。学期。準備。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You are welcome. Enjoy. Your stay. Spring. Nice. Time. Here. Bye.', 'どういたしまして。楽しんで。滞在。春。いい。時間。ここで。バイバイ。' FROM conv4;
