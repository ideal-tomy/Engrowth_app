-- 3分ストーリー: 道案内（4本目）
-- 使用単語: open, support, simply, third, technology, catch, step, baby, computer, type, attention, film
-- theme_slug: directions
-- situation_type: common

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '銀行への道案内',
    '観光客が両替のため銀行への道を尋ねる会話。',
    3,
    24
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '銀行を探す', '両替できる場所を聞く', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '道順の説明', '目印を伝える', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '営業時間の確認', '開いている時間', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お礼と別れ', '感謝を伝える', 'common', '道案内'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Excuse me. I need a bank. For currency exchange. My phone has no support. The map app died. Can you help?', 'すみません。銀行が必要です。両替用。携帯のサポートがない。地図アプリがダメになった。助けてもらえますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Sure. There is a bank nearby. Pay attention. Go straight. The third building on your right. Big. Glass. You will catch it.', 'もちろん。近くに銀行がある。注意して。まっすぐ。右側の3番目の建物。大きい。ガラス。見つかる。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Third on the right. OK. What type of bank? I need exchange. Not just an ATM. Do they have a desk for that?', '右の3番目。OK。どんな銀行？両替が必要。ATMだけじゃなく。窓口がある？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. They have full service. Open until four. Staff support. The technology there is good. Fast. You will be fine.', 'はい。フルサービスのある。4時まで開いてる。スタッフのサポート。技術はいい。速い。大丈夫。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Good. So straight. Third building. Right side. How many steps? I mean minutes. How long to walk?', 'いいですね。まっすぐ。3番目の建物。右側。何歩？いや何分？歩いてどのくらい？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Simply three minutes. Maybe less. You will pass a film shop. Then a computer store. The bank is after that. Baby steps. Very close.', '3分だけ。もっと短いかも。映画ショップを通る。それからコンピュータ店。銀行はその先。赤ちゃんの歩幅でも。とても近い。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Film shop. Computer store. Bank. Got it. Is the film shop a good landmark? Does it catch your attention?', '映画ショップ。コンピュータ店。銀行。わかった。映画ショップは良い目印？注目を引く？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Big sign. Old film reels in the window. You cannot miss it. Simply look right. The bank has a similar style. Open. Bright.', 'はい。大きな看板。窓に古いフィルムリール。見逃せない。右を見るだけ。銀行も似たスタイル。開放的に明るい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I will pay attention. Third building. Film shop before. Computer store before that. I have the order.', '注意する。3番目の建物。その前に映画ショップ。その前にコンピュータ店。順番わかった。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Exactly. One more step. The bank has a machine for quick exchange. But for large amounts use the desk. Better rate. Staff will support you.', 'その通り。もう一歩。銀行にクイック両替の機械がある。でも大口は窓口を。レートがいい。スタッフがサポートする。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Good to know. I have a fair amount. I will use the desk. So the bank is open until four? I need to step on it then.', 'いい情報。かなりの額がある。窓口使う。銀行は4時まで開いてる？急がなきゃ。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Plenty of time. It is only two now. The technology at the desk is fast. You will catch your flight. No problem.', 'はい。時間は十分。今2時だけ。窓口の技術は速い。飛行機に間に合う。問題ない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I hope so. Thank you. You are a lifesaver. No phone. No computer. Just kind directions. I love this city.', 'そう願います。ありがとう。命の恩人だ。携帯なし。コンピュータなし。親切な案内だけ。この街が好き。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You are welcome. Enjoy your stay. The bank is reliable. Third building. You will see it. Big. Professional.', 'どういたしまして。楽しんで。銀行は信頼できる。3番目の建物。見える。大きい。プロフェッショナル。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will. Straight. Third on the right. Film shop. Computer store. Bank. Got the full picture. Thanks again.', 'そうします。まっすぐ。右の3番目。映画ショップ。コンピュータ店。銀行。全体像わかった。もう一度ありがとう。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'No problem. Safe travels. Good exchange rates at that bank. They use good technology. You will be happy.', '問題ない。良い旅を。あの銀行はレートがいい。良い技術を使ってる。満足するよ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Perfect. Thank you. Your support means a lot. Really. Goodbye.', '完璧。ありがとう。サポートは本当に助かる。本当に。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Have a good trip.', 'さようなら。良い旅を。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'You too. Bye.', 'あなたも。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
