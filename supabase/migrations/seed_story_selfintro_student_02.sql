-- 3分ストーリー: 学生・新職場自己紹介（2本目）
-- 使用単語: full, model, season, society, tax, director, early, position, player, record, paper, special
-- theme_slug: selfintro_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'デザイン会社での初日',
    'デザイン会社に新入社員として入り、チームに自己紹介する会話。',
    3,
    17
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と経歴', 'オープンスペースで自己紹介', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'スキルと経験', 'これまでの仕事と強み', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '役割と意気込み', '新しいポジションへの抱負', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'チームとの連携', '今後の働き方', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning. I am Yuto. I joined the design team this season. This is my first full week. Nice to meet you.', 'おはようございます。優人です。今期デザインチームに加わりました。最初の1週間です。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Yuto. I am the director here. We need a new player for the team. Your record looked good on paper.', 'ようこそ優人君。ここではディレクターをしている。チームに新しいプレイヤーが必要だった。履歴書の記録は良さそうだった。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I started early today. I wanted to learn the position. What does the team do in a typical season?', 'ありがとう。今日は早く出てきました。ポジションを学びたかった。典型的な期にチームは何をしますか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We work on special projects. For big clients. The model we use is design first. Then we present. Your paper said you have experience with that.', '特別なプロジェクトをやっている。大きなクライアント向け。使うモデルはデザイン優先。それからプレゼン。履歴書にその経験があると。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Yes. I worked at a small studio. Full time for two years. We did similar work. But this is a bigger society. Bigger clients.', 'はい。小さなスタジオで働いていました。2年間フルタイムで。似た仕事をしました。でもここはより大きな会社。より大きなクライアント。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'Good. We have a special project starting next week. Can you handle the design model? We need it early. Before the tax deadline.', 'いいですね。来週特別なプロジェクトが始まる。デザインモデルを担当できる？早く必要。税の締め切り前に。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I can try. At my old position I was the main player for design. I have a good record. I will give it my full attention.', 'やってみます。以前のポジションではデザインのメイン担当でした。良い記録があります。全力で取り組みます。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'The director will review your work. We work as a team. Everyone is a player. No special treatment. But we support each other.', 'ディレクターが作品をレビューする。チームとして働く。皆がプレイヤー。特別扱いはない。でも互いにサポートする。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I like that. I want to be a full member. Not just on paper. In practice. I will learn from everyone.', 'いいですね。フルメンバーになりたい。紙の上だけでなく。実践で。皆から学びます。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Good attitude. This season we have four projects. Your position will be on two of them. We will see your record in action.', 'いい姿勢。今期は4つのプロジェクトがある。あなたのポジションは2つで。記録を行動で見せてくれる。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Thank you. One question. The tax deadline you mentioned. Does that affect our schedule? I want to plan ahead.', 'ありがとう。一つ質問。おっしゃった税の締め切り。スケジュールに影響しますか？前もって計画したい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. The client needs the design before they file. So we have to finish early. The model we use is two-week cycles. You will learn.', 'はい。クライアントは申告前にデザインが必要。だから早く仕上げなければ。使うモデルは2週間サイクル。学べる。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I understand. I had a similar model at my old job. The society there was smaller. But the process was full. Lots of steps.', 'わかりました。以前の仕事でも似たモデルがありました。そこの会社は小さかった。でもプロセスはフル。多くのステップ。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Here we are more agile. The director does not like long paperwork. We keep the paper work light. Focus on the design.', 'ここはもっとアジャイル。ディレクターは長い書類仕事が嫌い。書類は軽く。デザインに集中。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'That suits me. I want to spend my time on the special part. The creative work. Not the admin.', '私に合ってます。特別な部分に時間を使いたい。クリエイティブな仕事。事務じゃなく。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Good. Your position is clear. You are a design player. Full creative focus. We have a great team. You will fit in.', 'いいですね。あなたのポジションは明確。デザインプレイヤー。創造に集中。素晴らしいチームがある。フィットするよ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I hope so. I came early to get a full picture. The office. The people. The season ahead. I am ready.', 'そう願っています。全体像を得るために早く来ました。オフィス。人々。これからの期。準備できています。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'One more thing. We have a record of all past projects. Paper and digital. Study them. You will learn our model fast.', 'もう一つ。過去の全プロジェクトの記録がある。紙とデジタル。勉強して。モデルを早く学べる。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will. Thank you for the welcome. I will do my best. This is a special chance for me.', 'します。歓迎ありがとう。最善を尽くします。これは私にとって特別なチャンスです。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'We are glad to have you. See you at the stand-up. Nine tomorrow. Goodbye.', '来てくれて嬉しい。スタンドアップで。明日9時。さようなら。' FROM conv4;
