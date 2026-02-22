-- 3分ストーリー: 道案内（5本目）
-- 使用単語: open, support, simply, third, technology, catch, step, baby, computer, type, attention, film
-- theme_slug: directions
-- situation_type: common

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '郵便局への道案内',
    '観光客がハガキを送るため郵便局への道を尋ねる会話。',
    3,
    25
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '郵便局を探す', '場所を聞く', 'common', '道案内'
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
SELECT id, 'A', 1, 'Excuse me. I need the post office. I have postcards to send. My baby at home. I want to mail them today. Can you help?', 'すみません。郵便局が必要です。送るハガキがある。家の赤ちゃんに。今日投函したい。助けてもらえますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Sure. The post office is close. Pay attention. Go down this street. The third block. You will see a film museum. The post office is next to it.', 'もちろん。郵便局は近い。注意して。この道を下って。3ブロック目。映画ミュージアムが見える。郵便局は隣。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Film museum. Third block. OK. What type of building is the post office? Will it catch my eye?', '映画ミュージアム。3ブロック目。OK。郵便局はどんな建物？目に入る？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'It is open and bright. Red sign. Big. You cannot miss it. They have support for international mail. Stamps. Everything. Good technology. Fast service.', '開放的に明るい。赤い看板。大きい。見逃せない。国際郵便のサポートがある。切手。何でも。良い技術。速いサービス。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Perfect. So down the street. Third block. Film museum. Post office next door. How many steps? I mean minutes.', '完璧。道を下る。3ブロック目。映画ミュージアム。郵便局は隣。何歩？いや何分？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Simply five minutes. Maybe less. You will pass a computer shop. Small. Then the film museum. Big. The post office will catch your attention. Red. Official.', '5分だけ。もっと短いかも。コンピュータ店を通る。小さい。それから映画ミュージアム。大きい。郵便局が目に入る。赤。公式。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Computer shop. Film museum. Post office. Got the order. Is the film museum open today? Nice landmark. I like that type of place.', 'コンピュータ店。映画ミュージアム。郵便局。順番わかった。映画ミュージアムは今日開いてる？いい目印。そんな場所好き。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. Open every day. The museum has old film technology. Cameras. Projectors. Catches everyone''s attention. But the post office is your goal. Right next door.', 'はい。毎日開いてる。ミュージアムは古い映画技術がある。カメラ。プロジェクター。皆の注目を引く。でも郵便局が目的。すぐ隣。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. I will pay attention. Third block. Computer shop first. Then film museum. Post office. I have the full picture.', 'いいですね。注意する。3ブロック目。まずコンピュータ店。それから映画ミュージアム。郵便局。全体像わかった。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Exactly. One more step. The post office has a machine for stamps. Self service. But for international they have staff support. Use the desk.', 'その通り。もう一歩。郵便局に切手の機械がある。セルフサービス。でも国際はスタッフのサポート。窓口を使って。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I need international. Baby''s first photo. Sending to grandma. So I will use the desk. What time do they close?', '国際が必要。赤ちゃんの最初の写真。おばあちゃんに送る。窓口使う。何時まで？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Open until five. Plenty of time. The technology at the desk is quick. They will help you. Step right up. No wait usually.', '5時まで開いてる。時間は十分。窓口の技術は速い。助けてくれる。進み出て。待ちは通常なし。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good. Thank you. You have been a great support. No phone. No computer map. Just clear directions. I love it.', 'いいですね。ありがとう。素晴らしいサポートだった。携帯なし。コンピュータの地図なし。明確な案内だけ。好き。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'No problem. Sometimes simple is best. Third block. Film museum. Post office. You will catch it. Easy.', '問題ない。時々シンプルが最高。3ブロック目。映画ミュージアム。郵便局。見つかる。簡単。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will. Straight down. Third block. Red sign. Post office. Got it. Thanks again. Your baby will love the postcards. I mean my baby. At home.', 'そうする。まっすぐ下って。3ブロック目。赤い看板。郵便局。わかった。もう一度ありがとう。あなたの赤ちゃんがハガキを喜ぶ。いや私の赤ちゃん。家に。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'I am sure. Grandma will love them too. Safe travels. The post office has good support. You will be fine.', 'きっと。おばあちゃんも喜ぶ。良い旅を。郵便局はサポートがいい。大丈夫。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Goodbye. Down the street. Third block. I will remember.', 'ありがとう。さようなら。道を下って。3ブロック目。覚えておく。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Enjoy mailing. The film museum is worth a visit too. If you have time.', 'さようなら。郵送楽しんで。映画ミュージアムも訪れる価値あり。時間があれば。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Maybe next time. Thanks. Bye.', '今度かも。ありがとう。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
