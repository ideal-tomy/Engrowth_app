-- 3分ストーリー: 道案内（2本目）
-- 使用単語: open, support, simply, third, technology, catch, step, baby, computer, type, attention, film
-- theme_slug: directions
-- situation_type: common

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '美術館への道案内',
    '観光客が地元の人に美術館への道を尋ねる会話。',
    3,
    22
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '道を尋ねる', '美術館の場所を聞く', 'common', '道案内'
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
  SELECT id, 3, '営業時間の確認', '開館時間と注意事項', 'common', '道案内'
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
SELECT id, 'A', 1, 'Excuse me. I need help. I am looking for the film museum. The one with the old technology exhibit. Do you know it?', 'すみません。助けが必要です。映画ミュージアムを探しています。古い技術の展示があるところ。ご存じですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. I know it. Pay attention. Go straight for two blocks. Then turn right. You will see a big building. The third one on the left.', 'はい。知っています。注意して。2ブロックまっすぐ。それから右に曲がって。大きなビルが見える。左側の3番目。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Third on the left. OK. Is it open today? I have a baby with me. I hope it is not too far.', '左の3番目。OK。今日開いてますか？赤ちゃんを連れてます。遠すぎないといい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'It opens at ten. You have time. The step from here is easy. Maybe fifteen minutes. Your baby will be fine. They have support for strollers.', '10時に開きます。時間はある。ここからの道のりは簡単。15分くらい。赤ちゃんも大丈夫。ベビーカー対応してる。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Good. I use technology for maps. But my computer died. My phone too. So I need old style directions. Thank you for the support.', 'いいですね。地図は技術で見ます。でもパソコンがダメになった。携帯も。だから昔ながらの案内が必要。サポートありがとう。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'No problem. So straight. Two blocks. Right turn. Third building. Big. You cannot miss it. The film museum has a special sign.', '問題ない。まっすぐ。2ブロック。右折。3番目の建物。大きい。見逃せない。映画ミュージアムは特別な看板がある。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'What type of sign? I want to catch it from far. My baby gets tired. I need to find it fast.', 'どんな看板？遠くからキャッチしたい。赤ちゃんが疲れる。早く見つけたい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'A big film reel. Old school. You will see it. Simply look left after the turn. The building is open and bright. Lots of glass.', '大きなフィルムリール。オールドスクール。見える。曲がったら左を見るだけ。建物は開放的に明るい。ガラスが多い。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Film reel. Got it. So the technology exhibit is inside? I read about it. Old cameras. Early film. I love that type of stuff.', 'フィルムリール。わかった。技術の展示は中？読んだ。古いカメラ。初期の映画。そういうのが好き。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. They have old computers too. From the early days. The baby might not care. But you will love it. Pay attention to the third floor. Best exhibits there.', 'はい。古いコンピュータもある。初期のもの。赤ちゃんは興味ないかも。でもあなたは気に入る。3階に注意。最高の展示がそこ。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Third floor. I will remember. One more step. Is there a cafe? For the baby. Milk. Something simple.', '3階。覚えておく。もう一歩。カフェは？赤ちゃん用。ミルク。シンプルなもの。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Second floor. They have support for families. High chairs. Baby change. Open all day. You will be fine.', 'はい。2階。家族向けのサポートがある。ハイチェア。ベビー替え。一日中開いてる。大丈夫。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Perfect. So straight, right, third building. Film reel sign. Second floor cafe. Third floor exhibits. I think I can catch it now.', '完璧。まっすぐ、右、3番目の建物。フィルムリールの看板。2階カフェ。3階展示。もうわかる。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You got it. Simply follow those steps. Do not miss the old film section. It is special. Technology from a hundred years ago. Amazing.', 'その通り。そのステップに従うだけ。古い映画セクションを見逃さないで。特別だ。100年前の技術。すごい。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will pay attention. Thank you. You have been a great support. Old style help. No computer. Just kind people. I love that.', '注意します。ありがとう。素晴らしいサポートだった。昔ながらの助け。コンピュータなし。親切な人だけ。好きです。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'You are welcome. Enjoy the museum. The baby might like the film lights. Colorful. Catches everyone''s attention.', 'どういたしまして。ミュージアムを楽しんで。赤ちゃんは映画の光が好きかも。カラフル。皆の注目を引く。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I hope so. Thanks again. Straight. Right. Third building. Got it. Goodbye.', 'そう願います。もう一度ありがとう。まっすぐ。右。3番目の建物。わかった。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Have fun. The museum is open until six. Plenty of time.', 'さようなら。楽しんで。ミュージアムは6時まで開いてる。十分な時間。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Perfect. Thank you. Bye.', '完璧。ありがとう。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
