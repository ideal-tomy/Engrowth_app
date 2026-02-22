-- 3分ストーリー: カフェ&レストラン（4本目）
-- 使用単語: serious, occur, media, ready, sign, thought, list, individual, simple, quality, pressure, accept
-- theme_slug: cafe | situation_type: common | theme: カフェ&レストラン

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '追加注文と会計',
    '食事の途中で追加注文し、会計を済ませる会話。',
    3,
    39
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '追加の相談', 'デザートを頼む', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'メニューの確認', 'デザートリスト', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '会計の依頼', '勘定を頼む', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '支払いとお礼', '領収書の請求', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. We would like to see the dessert list. The main was good. Quality. Simple but perfect. We have room. For something sweet.', 'すみません。デザートリストを見たい。メインは良かった。品質。シンプルだが完璧。余裕がある。甘いもの用。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Of course. Here is our dessert list. Individual servings. Or we can do shared. The chocolate cake. Media favorite. Sign of quality. Many orders.', 'もちろん。デザートリストです。一人前。またはシェア。チョコレートケーキ。メディアのお気に入り。品質の兆し。多くの注文。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Chocolate cake. One to share. We thought about the ice cream. But cake sounds better. No pressure. We accept the cake. Two spoons please.', 'チョコレートケーキ。シェアで1つ。アイスクリームを考えてた。でもケーキの方がいい。プレッシャーなし。ケーキを受け入れる。スプーン2つ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'One chocolate cake. Shared. Two spoons. I will bring it. Kitchen is ready. Simple presentation. Quality chocolate. You will like it.', 'チョコレートケーキ1つ。シェア。スプーン2つ。お持ちする。キッチンは準備OK。シンプルな盛り付け。品質のチョコ。気に入る。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. And when you come back. Can we have the bill? We need to leave soon. Meeting at three. Serious. Time pressure.', 'ありがとう。戻ってきたら。お勘定を？もう出る必要がある。3時に会議。重要。時間のプレッシャー。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'No problem. I will bring the cake. And the bill. Together. So you can sign when ready. Individual check or one bill?', '問題ない。ケーキとお勘定を。一緒に。準備できたらサイン。別々か一括？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'One bill. We will share. Company card. Media expense. I need a receipt. For the records. Does that occur often? Business meals?', '一括。シェアする。会社のカード。メディア経費。領収書が必要。記録用。よく起こる？ビジネス食事？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Very often. We have many business guests. Quality service. Quick bills. Receipts ready. No delay. We understand. Pressure of work.', 'とてもよく。ビジネス客が多い。品質のサービス。速いお勘定。領収書準備。遅れなし。わかる。仕事のプレッシャー。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. The thought of a slow bill. Stressful. We had that once. Different place. Poor service. Never went back. Quality matters.', 'いい。遅いお勘定の考え。ストレス。一度あった。別の場所。 poor サービス。戻らなかった。品質が重要。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We aim for speed. And quality. Your cake is coming. Bill with it. Accept our thanks. For dining with us.', 'スピードと品質を目指す。ケーキが来る。お勘定も。感謝を受け入れて。ご来店ありがとう。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. The meal was excellent. From start to finish. Simple. But serious quality. We will be back. Add us to your regular list.', 'ありがとう。食事は最高だった。最初から最後まで。シンプル。でも本格的な品質。戻ってくる。常連リストに追加して。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We would love that. Here is your bill. Sign at the bottom. Receipt attached. Individual copy if you need. Just say.', '嬉しい。お勘定です。下にサイン。領収書添付。必要なら個別コピー。おっしゃってください。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'This is fine. One copy. For the company. Media department. Expense report. Occurs every month. Same process.', 'これでいい。1部。会社用。メディア部門。経費報告。毎月起こる。同じプロセス。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Understood. All set. Card accepted. No pressure. Take your time. Enjoy the rest of your day. Good meeting.', '承知。完了。カード受理。プレッシャーなし。ゆっくり。残りの一日を。良い会議を。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. Goodbye. We will return. Quality experience. Worth the sign. On the door. Best in town.', 'ありがとう。さようなら。戻る。品質の体験。看板の価値。ドアに。町で最高。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Thank you. Safe travels. See you next time.', 'さようなら。ありがとう。良い旅を。また次回。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye. Thanks again.', 'バイバイ。もう一度ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
