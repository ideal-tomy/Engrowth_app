-- 3分ストーリー: 飛行機（1本目）
-- 使用単語: place, single, rule, daughter, administration, south, floor, either, husband, campaign
-- theme_slug: flight | situation_type: common | theme: 飛行機

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'チェックインでの座席指定',
    '空港でチェックインし、座席の希望と手荷物を確認する会話。',
    3,
    26
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'チェックイン開始', 'カウンターで手続き', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '座席の希望', '窓側か通路側か', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '手荷物の確認', 'ルールの説明', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '搭乗ゲート案内', '出発フロアへ', 'common', '飛行機'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I am checking in for flight 205 to the south. My name is Tanaka.', 'こんにちは。南行き205便のチェックインです。田中と申します。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Good morning. One moment. I have your reservation. Single passenger. Window or aisle? We have a place for either.', 'おはようございます。少々お待ちください。予約があります。お一人様。窓側か通路側？どちらも空席があります。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Window please. I am traveling with my husband. Can we sit together? He has a separate booking.', '窓側でお願いします。夫と一緒です。並べますか？別の予約です。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Let me check. Yes. I can place you both in row twelve. The rule is we need two seats together. No problem.', '確認します。はい。12列に二人とも座席を確保できます。並んだ席が必要というルールです。問題ありません。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. Is the flight full? We are going to the Congress. Business administration meeting.', 'ありがとう。満席ですか？コングレスに行きます。経営の会議です。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'The flight has space. Row twelve is good. Now for baggage. The rule is one carry-on. Under seven kilos. Do you have a checked bag?', '空席があります。12列は良い席です。お荷物について。ルールは機内持込1個。7キロ未満。預け荷物は？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Yes. One bag each. My husband has a bigger one. For the campaign materials. He works in marketing.', 'はい。各自1つ。夫のは大きい。キャンペーン資料用。マーケティングをしています。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'No problem. The administration allows two bags per passenger. You are within the rule. Gate is on the south side. Floor two.', '問題ありません。規定ではお一人2個まで。ルール内です。ゲートは南側。2階です。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Floor two. South side. Got it. What time does boarding start? Our daughter is meeting us at the airport. She will drive us back.', '2階。南側。わかりました。搭乗開始は？娘が空港で迎えます。車で送ってくれます。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Boarding in forty minutes. Here are your passes. Gate B12. Go down to floor two. South terminal. You will see the signs.', '40分後に搭乗。 boarding passes です。B12ゲート。2階に降りて。南ターミナル。看板が見えます。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. One more question. The rule for liquids. Is it the same? Hundred milliliters?', 'ありがとう。もう一つ。液体のルール。同じですか？100ミリリットル？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Same rule. Clear bag. One liter total. Either in carry-on or checked. Your bags look fine.', 'はい。同じルール。透明の袋。合計1リットル。機内持込か預けのどちらか。お荷物は大丈夫そうです。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good. I packed light. Single bag. The administration at the other airport was strict. I want to follow every rule.', 'いいですね。軽く荷造り。1つのバッグ。向こうの空港の運営は厳しかった。全てのルールに従いたい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You will be fine. Have a good flight. Gate B12. Floor two. South. Enjoy the conference.', '大丈夫です。良いフライトを。B12ゲート。2階。南側。会議を楽しんで。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. We will. Goodbye.', 'ありがとう。楽しみます。さようなら。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Safe travels. Enjoy the Congress. The south terminal is nice. Coffee shop on floor two. Good place to wait.', 'さようなら。良い旅を。コングレスを楽しんで。南ターミナルはいいです。2階にコーヒーショップ。待つには良い場所。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. We will check that out. Our daughter might want a snack before the flight. Either there or on the plane.', 'ありがとう。行ってみます。娘がフライト前にスナックを欲しがるかも。あそこか機内で。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Gate B12. Floor two. South side. See you on board. Goodbye.', 'どういたしまして。B12ゲート。2階。南側。機内で。さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Thank you for the help.', 'さようなら。助けてくれてありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
