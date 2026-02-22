-- 3分ストーリー: カフェ&レストラン（1本目）
-- 使用単語: serious, occur, media, ready, sign, thought, list, individual, simple, quality, pressure, accept
-- theme_slug: cafe | situation_type: common | theme: カフェ&レストラン

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'レストランでの注文',
    'レストランで席に着き、メニューを確認して注文する会話。',
    3,
    36
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '着席とメニュー', 'ウェイターが案内', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '注文の相談', 'メニューから選ぶ', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'アレルギーの伝達', '食材の確認', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '注文の確定', 'ドリンクの追加', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good evening. Table for two please. We have a reservation. Name is Wilson. Under media department. Company dinner.', 'こんばんは。2名で。予約があります。ウィルソンです。メディア部門で。会社の夕食。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. Yes. Wilson. Table for two. This way. The sign says reserved. Your table is ready. Here is the menu. Individual menus. One for each.', 'ようこそ。はい。ウィルソン様。2名。こちらへ。看板に予約済み。テーブルの準備ができた。メニューです。各自用。お一人様ずつ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I thought we might be late. Traffic. Pressure at work. But we made it. Is the kitchen ready? We are hungry. Serious hunger.', 'ありがとう。遅れると思った。渋滞。仕事のプレッシャー。でも間に合った。キッチンは準備OK？お腹が空いてる。本気で空いてる。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'The kitchen is ready. No pressure. Take your time. Quality is our focus. Simple dishes. Fresh. Let me know when you are ready to order. I will accept your order then.', 'キッチンは準備OK。プレッシャーなし。ゆっくり。品質が焦点。シンプルな料理。フレッシュ。注文の準備ができたら。その時にお受けします。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We need a few minutes. The list is long. So many options. I did not think it would occur. So many choices. Hard to pick.', '数分必要。リストが長い。選択肢が多い。起こると思わなかった。こんなに選べる。選びにくい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'No rush. Our special today is the fish. Simple preparation. High quality. Media coverage last week. Article in the food section. Many customers order it.', '急がなくて。本日のスペシャルは魚。シンプルな調理。高品質。先週メディア取材。食セクションの記事。多くのお客様が注文。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'The fish. Sounds good. I accept that. What about the starter? Something light. Individual portion. Not too big. We have dessert plans.', '魚。いいですね。受け入れる。前菜は？軽いもの。一人前。大きくなく。デザートの予定がある。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'The soup is simple. Good quality. Or the salad. Individual size. Light. No serious commitment. You will have room. For dessert.', 'スープはシンプル。良い品質。またはサラダ。一人前サイズ。軽い。重いコミットなし。余裕がある。デザート用。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Salad for me. My friend will have the soup. So two mains. Both fish. One salad. One soup. We are ready. Can you note any allergies? I have a nut allergy. Serious. Must avoid.', '私はサラダ。友達はスープ。メイン2つ。両方魚。サラダ1つ。スープ1つ。準備できた。アレルギーをメモできる？ナッツアレルギーがある。深刻。避けなければ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I will note that. Nut allergy. Serious. We will inform the kitchen. No nuts in your dishes. The pressure to get it right. We take it seriously. Quality and safety.', 'メモする。ナッツアレルギー。深刻。キッチンに伝える。あなたの料理にナッツなし。正確さへのプレッシャー。真剣に。品質と安全。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. I thought I should mention it. Allergies can occur suddenly. Better to list them. Simple step. Prevents problems.', 'ありがとう。言うべきと思った。アレルギーは突然起こりうる。リストにして伝える。シンプルなステップ。問題を防ぐ。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We accept that. Standard practice. Individual needs. We accommodate. Your order. Two fish. Salad. Soup. No nuts. Correct?', '受け入れます。標準のやり方。個々のニーズ。対応する。ご注文。魚2つ。サラダ。スープ。ナッツなし。正しい？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Yes. Correct. One more thing. Drinks? I thought we might have wine. Something to reduce the pressure. Long day. Media deadlines. Need to unwind.', 'はい。正しい。もう一つ。ドリンクは？ワインを思ってた。プレッシャーを減らす何か。長い一日。メディアの締め切り。くつろぎたい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We have a good wine list. Red. White. By the glass or bottle. Individual preference. Simple choice. Quality selection. I can recommend.', 'ワインリストがいい。赤。白。グラスかボトル。個人の好み。シンプルな選択。品質のセレクション。お勧めできる。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'One bottle. White. For both. We will share. No pressure to finish. Just enjoy. The thought of good food. Good wine. Perfect end to the day.', '1本。白。二人で。シェアする。飲み切るプレッシャーなし。楽しむだけ。良い食事の考え。良いワイン。完璧な一日の締めくくり。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'One white. For two. Got it. Your order is complete. Kitchen will sign off. No nuts. Quality checked. Ready in twenty minutes.', '白1本。2人用。承知。ご注文完了。キッチンがサインオフ。ナッツなし。品質確認済み。20分で準備。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Twenty minutes. Perfect. We can relax. The media can wait. No pressure for the next hour. Just us. Good food.', '20分。完璧。リラックスできる。メディアは待てる。次の1時間はプレッシャーなし。私たちだけ。良い食事。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Enjoy. I will bring the wine shortly. Simple and good. You will like it. Goodbye for now.', '楽しんで。ワインをすぐお持ちする。シンプルで良い。気に入る。一旦さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. Goodbye.', 'ありがとう。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
