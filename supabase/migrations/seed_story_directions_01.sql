-- 3分ストーリー: 道案内（1本目）
-- 使用単語: activity, star, table, need, court, oil, half, situation, easy, cost, industry, figure
-- theme_slug: directions
-- situation_type: common

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '駅からホテルへの道案内',
    '道に迷った観光客が地元の人に駅からホテルへの道を尋ねる会話。',
    3,
    21
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '道に迷う', '駅の前で困っている', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '方向の説明', '目印を伝える', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '距離と時間', '歩いてどのくらいか', 'common', '道案内'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '確認とお礼', '道を確認して別れる', 'common', '道案内'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Excuse me. I need help. I am lost. I need to find my hotel. The Star Hotel. Do you know it?', 'すみません。助けが必要です。道に迷いました。ホテルを探しています。スターホテルです。ご存じですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. I know the Star Hotel. It is a popular place. Lots of activity there. Tourist area. Not far from here.', 'はい。スターホテルは知っています。人気の場所です。たくさんのアクティビティがあります。観光エリア。ここから遠くない。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Good. What is the situation? Is it easy to walk? Or do I need a taxi? The cost matters. I am on a budget.', 'いいですね。状況は？歩いて行けますか？タクシーが必要ですか？費用が重要です。予算が厳しい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'It is easy to walk. Maybe half an hour. Maybe a bit less. No need for a taxi. Save your money.', '歩いて簡単です。30分くらい。もっと短いかも。タクシーは要らない。お金を節約して。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Perfect. So which way? I cannot figure it out. My phone has no data. This situation is tough.', '完璧。どっちの方ですか？わかりません。携帯にデータがない。この状況は大変。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'No problem. Go straight from this station. You will see a big building. The industry center. Glass and white. Keep it on your left.', '問題ない。この駅からまっすぐ。大きなビルが見える。産業センター。ガラスと白。左側に保って。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Industry center. Left side. OK. What about the court? Someone said something about a court. A sports court?', '産業センター。左側。OK。コートは？誰かがコートについて言ってた。スポーツコート？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. There is a tennis court. Past the industry building. About half a mile. Turn right at the court. Then you will see the hotel. The Star. Big sign.', 'はい。テニスコートがある。産業ビルの先。約半マイル。コートで右に曲がって。するとホテルが見える。スター。大きな看板。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Tennis court. Turn right. Got it. Is there a table? Like a map table? I want to double check the route.', 'テニスコート。右に曲がる。わかりました。テーブルはある？地図のテーブルみたいな？ルートを再確認したい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'There is a info table near the station exit. Over there. You can get a paper map. No cost. Free for tourists. It will help you figure the way.', '駅出口近くに案内テーブルがある。あそこ。紙の地図がもらえる。無料。観光客向け無料。道を把握する助けになる。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Great. So half an hour on foot. Any activity I should avoid? Construction? Road work?', 'いいですね。つまり徒歩30分。避けるべきアクティビティは？工事？道路工事？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'There might be some work near the oil plant. But that is the other direction. Your route is clear. No problem. Easy walk.', 'オイルプラント近くで仕事があるかも。でもそれは別の方向。君のルートは問題ない。楽な道のり。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Oil plant. I will stay away. So industry center, tennis court, right turn. Star Hotel. I think I can figure it out now.', 'オイルプラント。避けます。産業センター、テニスコート、右折。スターホテル。もうわかると思います。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You got it. The situation is simple. Straight. Left at the industry center. Right at the court. You will see the star on the sign. Big and clear.', 'その通り。状況はシンプル。まっすぐ。産業センターで左。コートで右。看板の星が見える。大きくてはっきり。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. You saved me. I was in a bad situation. No phone. No map. Lost in a new city. This is a big help.', 'ありがとう。助けてくれた。大変な状況だった。携帯なし。地図なし。新しい街で迷った。大きな助けです。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'No problem. Enjoy your stay. The Star Hotel has good activity. Restaurant. Bar. Nice area. You will like it.', '問題ない。楽しんで。スターホテルはアクティビティが充実。レストラン。バー。いいエリア。気に入るよ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I hope so. One more thing. Is there a convenience store? I need to buy water. Maybe some oil for my skin. Sun was strong today.', 'そう願います。もう一つ。コンビニは？水を買う必要がある。肌用オイルもかも。今日は日差しが強かった。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Yes. Near the court. Half way to the hotel. You will see it. Low cost. Good for travelers.', 'はい。コートの近く。ホテルまで半分。見える。低コスト。旅行者に便利。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Perfect. Thank you again. You made this easy. I was stressed. Now I can relax. Have a good day.', '完璧。もう一度ありがとう。簡単にしてくれた。ストレスだった。もうリラックスできる。いい一日を。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You too. Good luck. Bye.', 'あなたも。頑張って。バイバイ。' FROM conv4;
