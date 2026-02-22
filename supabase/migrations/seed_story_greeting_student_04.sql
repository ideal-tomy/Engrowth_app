-- 3分ストーリー: 国際交流イベントでの挨拶（4本目）
-- 使用単語: line, end, member, law, car, city, community, name, president, team, minute, idea
-- theme_slug: greeting_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際交流イベントでの名刺交換',
    '国際交流イベントで名前やチームの話、都市のコミュニティについて話し合う会話。',
    3,
    9
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '名前と所属', 'お互いの名前とチームを紹介', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '都市と交通', '出身都市や車の話', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'コミュニティと法律', '地域コミュニティや法律の勉強', 'student', '挨拶'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '別れと連絡', '連絡先交換して別れる', 'student', '挨拶'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi! My name is Yuki. I am a new member of the exchange program. What is your name?', 'こんにちは。ユキです。交換プログラムの新メンバーです。お名前は？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Nice to meet you, Yuki. My name is Mike. I am on the student team. We organize events like this.', '会えて嬉しいです、ユキ。マイクです。学生チームにいます。こんなイベントを企画しています。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Oh, so you are the president of the team? That is a big job. How many members are there?', 'じゃあチームの代表なんですか？大変なお仕事ですね。メンバーは何人いますか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'No, I am not the president. She is over there. We have about twenty members. We stand in a line at the start of each event.', 'いいえ、代表ではありません。あそこにいます。メンバーは約20人。各イベントの開始時に列になって並びます。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I see. That is a good idea. It helps people find the team. I waited in line for a minute when I came in.', 'なるほど。いいアイデアですね。チームを探すのに役立ちます。入るときに1分くらい並びました。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Which city are you from? I am from a small city in the Midwest. We have a strong community there.', 'どの都市からですか？私は中西部の小さな都市からです。強いコミュニティがあります。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I am from Tokyo. A big city. Lots of cars and trains. The subway line is very long. It goes from end to end of the city.', '東京からです。大きな都市です。車や電車がたくさん。地下鉄の路線がとても長く、街の端から端まで行きます。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'I have been to Tokyo. I like the idea of taking the train. No need for a car. Good for the environment.', '東京に行ったことがあります。電車に乗るのが好きです。車は要りません。環境にいい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Yes. In my city the law is strict about cars in some areas. The community wants less traffic.', 'はい。私の街では一部の地域で車に関する法律が厳しいです。コミュニティは交通量を減らしたいんです。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'That makes sense. I study law. I want to work on city planning. Maybe help communities.', 'なるほど。法律を勉強しています。都市計画の仕事がしたいです。コミュニティを助けられれば。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'That is a noble idea. We need more people like you. How did you end up in this program?', '崇高なアイデアですね。あなたのような人がもっと必要です。どうしてこのプログラムに参加したんですか？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'The president of our university suggested it. She said it would be good for our community. And for me. I agree.', '大学の学長が勧めてくれました。コミュニティにも自分にもいいと言って。同感です。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I joined because of a team member. My friend. She said the line to sign up was long but worth it. She was right.', 'チームのメンバーの友達に誘われて。申込の列は長いけど価値があると言って。その通りでした。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. We are at the end of the event soon. Just a few more minutes. Do you want to stay for the next part?', '良かった。もうすぐイベントの終わりです。あと数分。次のパートに残りますか？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Yes. I have no car to catch. I can stay. I like the idea of meeting more members. Maybe the president too.', 'はい。乗る車はないので残れます。もっとメンバーに会うのがいいですね。学長にも。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Great. Let me introduce you. But first, can I get your name again? And your contact? I will add you to the group.', 'いいですね。紹介します。でもまず、お名前をもう一度いただけますか？連絡先も。グループに追加します。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Sure. My name is Yuki Tanaka. Here is my email. I am happy to be part of this community. Thank you.', 'もちろん。ユキ・タナカです。メールアドレスです。このコミュニティの一員になれて嬉しいです。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thank you. I am Mike. I will send you the team schedule. See you at the next event. Just a minute, I need to go say hi to the president.', 'ありがとう。マイクです。チームのスケジュールを送ります。次のイベントで。少々、学長に挨拶に行かなくては。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'No problem. It was nice to meet you. Bye!', '大丈夫です。会えて嬉しかったです。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye! See you at the end of the week.', 'バイバイ。週末にまた。' FROM conv4;
