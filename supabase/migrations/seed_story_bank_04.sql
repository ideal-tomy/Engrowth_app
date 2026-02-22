-- 3分ストーリー: 銀行口座開設（4本目）
-- 使用単語: statement, maintain, charge, popular, traditional
-- theme_slug: bank | situation_type: student | theme: 銀行口座開設

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '入金と送金の方法',
    '最初の入金の仕方や海外送金について銀行員に尋ねる会話。',
    3,
    69
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '入金の方法', '現金か振込か', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '海外送金', '両親から', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '月次明細', 'ステートメント', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '手数料の確認', '維持・送金', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'I opened. My account. Last week. Popular. Choice. Student. Package. Now. How. To. Deposit? Traditional. Cash? Or. Transfer? Statement. Of. Options?', '開いた。口座。先週。人気。選択。学生。パッケージ。では。預入方法？伝統的。現金？振込？オプションの声明？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Both. Work. Traditional. Cash. At. Counter. No. Charge. For. Deposit. Popular. Method. Students. Maintain. Balance. Easy. Statement. Monthly. Free.', '両方。可能。伝統的。現金。窓口で。手数料なし。預入。人気。方法。学生。維持。残高。簡単。声明。月次。無料。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Transfer. From. Another. Bank? Charge? How much? Popular? Or. Traditional. Cash. Better? Statement. Of. Fees?', '振込。他行から？手数料？いくら？人気？伝統的。現金。 better？手数料の声明？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Transfer. Popular. Now. Charge. Five. Dollars. Per. Transfer. Maintain. Account. Free. Student. Traditional. Branch. Deposit. No. Charge. Statement. Online. Or. Paper.', '振込。人気。今。手数料。5ドル。1回あたり。維持。口座。無料。学生。伝統的。支店。預入。手数料なし。声明。オンライン。または紙。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'International. Transfer? Parents. Japan. Send. Money? Charge? Popular? Students? Statement. Common?', '国際振込？両親。日本。送る。お金？手数料？人気？学生？声明。一般的？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Yes. Popular. Many. Students. Traditional. Method. Wire. Charge. Twenty. Five. Dollars. Per. Transfer. Maintain. Low. Cost. Use. Once. Month. Statement. Shows. All. Fees.', 'はい。人気。多くの。学生。伝統的。方法。送金。手数料。25ドル。1回あたり。維持。低コスト。月1回使う。声明。示す。すべての手数料。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Twenty five. Charge. High. For. Student. Popular. Alternative? Maintain. Budget? Statement. Of. Options?', '25。手数料。高い。学生に。人気の代替？維持。予算？オプションの声明？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Wise. Or. PayPal. Popular. Lower. Charge. Ten. Or. Less. Maintain. More. Money. Traditional. Wire. Secure. But. Charge. Higher. Statement. Compare. Online.', 'Wise。またはPayPal。人気。低い。手数料。10以下。維持。もっと。お金。伝統的。送金。安全。でも。手数料。高い。声明。比較。オンライン。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Monthly. Statement. How? Paper? Or. Digital? Charge? Popular? Choice? Maintain. Record?', '月次。声明。どう？紙？デジタル？手数料？人気？選択？維持。記録？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Digital. Popular. No. Charge. Maintain. Environment. Too. Traditional. Paper. Available. Charge. Two. Dollars. Statement. Email. Free. Every. Month.', 'デジタル。人気。手数料なし。維持。環境も。伝統的。紙。利用可能。手数料2ドル。声明。メール。無料。毎月。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Good. Digital. Statement. Popular. Choice. Maintain. Record. Online. Charge. Nothing. Traditional. Go. Paperless. Modern.', 'いい。デジタル。声明。人気。選択。維持。記録。オンライン。手数料。なし。伝統的。紙レスへ。現代。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Statement. Shows. Balance. Transactions. Charge. List. All. Maintain. Transparency. Popular. With. Students. Traditional. Banks. Same. But. Digital. Faster.', '声明。示す。残高。取引。手数料。リスト。すべて。維持。透明性。人気。学生に。伝統的。銀行。同じ。でも。デジタル。速い。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Minimum. Balance? Charge? If. Below? Popular. Question? Maintain. How. Much?', '最低残高？手数料？下回ったら？人気。質問？維持。いくら？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Student. Account. Zero. Minimum. No. Charge. Maintain. Any. Balance. Popular. Benefit. Traditional. Accounts. Require. Five hundred. Statement. Explains. All.', '学生口座。ゼロ。最低。手数料なし。維持。任意の残高。人気。メリット。伝統的。口座。必要。500。声明。説明。すべて。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Perfect. Statement. Clear. Charge. Transparent. Popular. Bank. Maintain. Trust. Traditional. Values. Modern. Service. Good.', '完璧。声明。明確。手数料。透明。人気。銀行。維持。信頼。伝統的。価値観。現代。サービス。いい。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Summary. Statement. Digital. Free. Charge. Minimal. Popular. Students. Maintain. Easy. Traditional. Quality. Modern. Convenience. Bye.', 'サマリー。声明。デジタル。無料。手数料。最小。人気。学生。維持。簡単。伝統的。品質。現代。便利。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Statement. Helpful. Charge. Understand. Popular. Choice. Maintain. Budget. Traditional. Advice. Good. Bye.', 'ありがとう。声明。有用。手数料。理解。人気。選択。維持。予算。伝統的。アドバイス。いい。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Statement. Questions? Anytime. Charge. None. For. Advice. Popular. Service. Maintain. Happy. Customers. Bye.', 'どういたしまして。声明。質問？いつでも。手数料。なし。アドバイス。人気。サービス。維持。幸せ。顧客。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Statement. Clear. Charge. Fair. Popular. Reason. Maintain. Account. Here. Thank you.', 'バイバイ。声明。明確。手数料。公正。人気。理由。維持。口座。ここ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care. Good luck.', 'バイバイ。お気をつけて。頑張って。' FROM conv4;
