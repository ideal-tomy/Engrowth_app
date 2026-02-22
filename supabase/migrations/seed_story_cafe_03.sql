-- 3分ストーリー: カフェ&レストラン（3本目）
-- 使用単語: serious, occur, media, ready, sign, list, individual, simple, quality, pressure, accept
-- theme_slug: cafe | situation_type: common | theme: カフェ&レストラン

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'カフェでのモーニング',
    'カフェで朝食を注文し、コーヒーと軽食を頼む会話。',
    3,
    38
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '席に着く', 'メニューを聞く', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '朝食の注文', 'オプションを選ぶ', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'コーヒーの指定', '好みを伝える', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '注文の確認', '追加の有無', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Good morning. Table for one. Is the kitchen ready? I need breakfast. Quick. Before my meeting. Pressure at work. Big day.', 'おはよう。1名。キッチンは準備OK？朝食が必要。早く。会議の前。仕事のプレッシャー。大事な日。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Good morning. Yes. Kitchen is ready. We serve until eleven. Here is the menu. Simple options. Quality ingredients. Individual portions. Take a seat. I will accept your order when ready.', 'おはようございます。はい。キッチンは準備OK。11時まで。メニューです。シンプルなオプション。品質の食材。一人前。お掛けください。準備できたら注文お受け。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I thought about the eggs. And toast. Something simple. No serious meal. Just fuel. For the day. Media pitch at ten.', 'ありがとう。卵を考えてた。トーストも。シンプルなもの。本格的な食事じゃなく。燃料だけ。一日用。10時にメディアピッチ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Eggs and toast. Good choice. We have a list. Scrambled. Fried. Poached. Your preference? Quality eggs. Fresh. From local farms.', '卵とトースト。いい選択。リストあり。スクランブル。フライ。ポーチド。好みは？品質の卵。新鮮。地元の農場から。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Scrambled. Quick. And coffee. Black. Strong. Need to wake up. The sign outside said best coffee. I hope that is true. No pressure.', 'スクランブル。早く。コーヒーも。ブラック。ストロング。目覚めが必要。外の看板に最高のコーヒー。本当だといい。プレッシャーなしで。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Our coffee is quality. Many say it is the best. So scrambled eggs. Toast. Black coffee. Strong. I accept. Anything else? Juice? Something to occur to you?', 'コーヒーは品質。多くの人が最高と言う。スクランブルエッグ。トースト。ブラックコーヒー。ストロング。承知。他に？ジュース？何か思いつく？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Orange juice. Fresh. Simple. Good with eggs. Individual size. Not too big. I have a list of meetings. Need to stay sharp. No food coma.', 'オレンジジュース。フレッシュ。シンプル。卵と合う。一人前サイズ。大きくなく。会議のリストがある。鋭く。食後の眠気なし。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Orange juice. Got it. Your order. Scrambled eggs. Toast. Black coffee. Orange juice. All simple. All quality. Ready in ten minutes.', 'オレンジジュース。承知。ご注文。スクランブルエッグ。トースト。ブラックコーヒー。オレンジジュース。全てシンプル。全て品質。10分で準備。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Ten minutes. Perfect. I can check my emails. The thought of good coffee. Already helps. Stress reducing. Before the media pitch.', '10分。完璧。メール確認できる。良いコーヒーの考え。もう助かる。ストレス軽減。メディアピッチの前に。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We aim to reduce stress. Good food. Good coffee. Simple life. Your table is ready. I will bring the coffee first. Sign that we care.', 'ストレス軽減を目指す。良い食事。良いコーヒー。シンプルな生活。テーブルは準備OK。コーヒーを先にお持ちする。気遣いのサイン。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Coffee first. Smart. I accept that order. Get the brain ready. Then the food. Perfect plan. No pressure on the kitchen.', 'コーヒーまず。賢い。その順番受け入れる。脳を準備。それから食事。完璧な計画。キッチンにプレッシャーなし。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Exactly. We know busy people. Media. Business. They need quick. Quality. We deliver. Individual attention. Despite the rush.', 'その通り。忙しい人を知ってる。メディア。ビジネス。速さが必要。品質。届ける。個人への配慮。混雑にもかかわらず。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I appreciate that. Serious about service. I can tell. The list of regulars. Must be long. Good sign. People come back.', '感謝。サービスに真剣。わかる。常連のリスト。長いに違いない。良い兆し。人は戻ってくる。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We have many regulars. Quality brings them back. Simple formula. Good food. Good service. No pressure. Just care.', '常連が多い。品質が戻してくれる。シンプルな公式。良い食事。良いサービス。プレッシャーなし。気遣いだけ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I might join the list. If the coffee is as good as the sign says. And the eggs. First impression. Important. Occurs only once.', 'リストに加わるかも。コーヒーが看板通りなら。卵も。第一印象。重要。一度だけ起こる。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'We will not disappoint. Coffee is coming. Fresh. Strong. Black. Your eggs will follow. Enjoy. Goodbye for now.', 'がっかりさせない。コーヒーが来る。フレッシュ。ストロング。ブラック。卵は続く。楽しんで。一旦さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Goodbye.', 'ありがとう。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
