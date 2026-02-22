-- 3分ストーリー: 道案内（3本目）
-- 使用単語: open, support, simply, third, technology, catch, step, baby, computer, type, attention, film
-- theme_slug: directions
-- situation_type: common

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '最寄り駅への道案内',
    'ビジネスパーソンが会議場から最寄り駅への道を尋ねる会話。',
    3,
    23
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '道を尋ねる', '駅の方向を聞く', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'ルートの説明', '目印を伝える', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '所要時間の確認', '歩いて何分か', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '感謝と別れ', 'お礼を伝える', 'common', '道案内'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Excuse me. I need to catch a train. Where is the nearest station? My phone died. No support from technology today.', 'すみません。電車に乗りたい。最寄り駅はどこですか？携帯がダメになった。今日は技術のサポートなし。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'No problem. The station is close. Pay attention. Go out that door. Turn left. You will see a computer store. Big sign. The third block.', '問題ない。駅は近い。注意して。あのドアから出て。左に曲がって。コンピュータ店が見える。大きな看板。3ブロック目。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Computer store. Third block. OK. Then what? What type of building is the station? Is it easy to spot?', 'コンピュータ店。3ブロック目。OK。それから？駅はどんな建物？見つけやすい？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Simply walk past the store. The station is on the right. Open building. Glass front. You cannot miss it. Five minutes on foot.', '店を過ぎて歩くだけ。駅は右側。開放的な建物。ガラス張り。見逃せない。徒歩5分。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Five minutes. Good. I have a meeting soon. I need to step it up. Thank you for the directions. Old style. No map. Just words.', '5分。いい。もうすぐ会議がある。急がなきゃ。道案内ありがとう。昔ながら。地図なし。言葉だけ。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'You are welcome. One more step. After the computer store you will see a film theater. Old building. The station is right next to it.', 'どういたしまして。もう一歩。コンピュータ店の後に映画館が見える。古い建物。駅は隣。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Film theater. Good landmark. I will catch that. So computer store, film theater, station. In that order.', '映画館。いい目印。把握した。コンピュータ店、映画館、駅。その順番。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Exactly. The theater shows old films. Classic type. It catches your attention. Big neon sign. You cannot miss it.', 'その通り。劇場は古い映画を上映。クラシックなタイプ。注目を引く。大きなネオン看板。見逃せない。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Perfect. So left at the door. Third block has the computer store. Then the film theater. Station next door. Got it.', '完璧。ドアで左。3ブロック目にコンピュータ店。それから映画館。駅は隣。わかった。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Simply follow that. The station is open twenty-four hours. Ticket machines. Staff support. You will be fine.', 'はい。それに従うだけ。駅は24時間開いてる。券売機。スタッフのサポート。大丈夫。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Good. One question. Is there a cafe in the station? I need coffee. Baby level tired. Long meeting.', 'いいですね。一つ質問。駅にカフェは？コーヒーが必要。赤ちゃん並みに疲れた。長い会議だった。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Second floor. Near the gates. Open early. Good coffee. Quick step in and out. You can catch your train after.', 'はい。2階。改札近く。早く開いてる。いいコーヒー。素早く出入り。その後に電車に乗れる。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Perfect. I will pay attention. Left, computer store, film theater, station. Coffee on the second floor. I have the full picture.', '完璧。注意する。左、コンピュータ店、映画館、駅。2階でコーヒー。全体像がわかった。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You got it. The technology in the station is good. Digital boards. But the old film theater is a better landmark. More visible.', 'その通り。駅の技術はいい。デジタル案内。でも古い映画館の方が良い目印。より見える。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I agree. Sometimes old is better. No battery needed. Just look. Thank you. You have been a great support.', '同感。時々古い方がいい。電池不要。見るだけ。ありがとう。素晴らしいサポートだった。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'No problem. Good luck with your meeting. Or was it after the meeting? Either way. Safe travels.', '問題ない。会議頑張って。終わった後だった？いずれにせよ。良い旅を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'After. Long day. I need to catch my train home. Thanks again. Your directions were clear. Simply perfect.', '終わった後。長い一日。家への電車に乗らなきゃ。もう一度ありがとう。案内は明確だった。 simply 完璧。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Have a good trip. The third block. Do not forget.', 'どういたしまして。良い旅を。3ブロック目。忘れないで。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will remember. Goodbye.', '覚えておく。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye.', 'さようなら。' FROM conv4;
