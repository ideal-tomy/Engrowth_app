-- 3分ストーリー: 学生・新職場自己紹介（4本目）
-- 使用単語: full, model, season, society, tax, director, early, position, player, record, paper, special
-- theme_slug: selfintro_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ITスタートアップ入社初日',
    'テックスタートアップにジョインし、エンジニアチームに自己紹介する会話。',
    3,
    19
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と経歴', 'オフィスで自己紹介', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'スキルと経験', '技術スタックと実績', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '役割と開発', '新しいポジションの仕事', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'チームとの連携', '開発フローと文化', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi everyone. I am Riku. I joined as a backend developer. This is my first day. I came early to set up. Nice to meet you all.', '皆さんこんにちは。陸です。バックエンド開発者としてジョインしました。初日です。セットアップのため早く来ました。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Riku. I am the tech director. Your record looked good. The paper from your last company was strong. We need a player like you.', 'ようこそ陸君。テックディレクターです。記録は良さそうだった。前の会社からの書類が良かった。君のようなプレイヤーが必要なんだ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. My position is full stack focus. But backend is my main. I want to contribute to the team. This season is busy right?', 'ありがとう。ポジションはフルスタック寄りです。でもバックエンドがメイン。チームに貢献したい。今期は忙しいですよね？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. We have a special launch in two months. The model we use is agile. Two-week sprints. You will learn fast.', 'はい。2ヶ月後に特別なローンチがある。使うモデルはアジャイル。2週間スプリント。早く学べる。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I like that. My last job was similar. But the society was big. Corporate. Here it feels different. More flexible.', 'いいですね。前の仕事も似ていました。でも会社は大きかった。大企業。ここは違う感じ。もっと柔軟。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'We are a small team. Every player matters. No special hierarchy. The director codes too. We all do.', '小さいチームだ。全員が重要。特別な階層はない。ディレクターもコードを書く。みんなやる。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'That is why I joined. I want to see the full picture. From idea to launch. Not just my piece. The whole product.', 'だから参加した。全体像を見たい。アイデアからローンチまで。自分の部分だけでなく。製品全体。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good. Your position will touch the API layer. We have good docs. Paper and digital. The record of our system is there.', 'いいね。君のポジションはAPIレイヤーに触れる。良いドキュメントがある。紙とデジタル。システムの記録はそこにある。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I will read it. I learn fast. My record at the last job was good. I shipped three features in one season. Early every time.', '読みます。学ぶのは早い。前の仕事の記録は良かった。1期で3つの機能をリリース。毎回早期に。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We need that speed. The tax year ends soon. We want the product live before that. For our clients. Paper work is less. Code is more.', 'そのスピードが必要。税年度がもうすぐ終わる。それまでに製品をライブにしたい。クライアントのため。書類は少ない。コードが多い。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I understand. So my first task is the API? I can start full time on that. When is the stand-up?', 'わかりました。最初のタスクはAPI？それにフルタイムで取り組めます。スタンドアップはいつ？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Nine every morning. The director runs it. Short. Fifteen minutes. We share blockers. No long paper reports. Action focused.', '毎朝9時。ディレクターが運営。短い。15分。ブロッカーを共有。長い書類レポートはない。アクション重視。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Perfect. I had too much paper at my old job. Meetings. Reports. Here it seems different. Special. I like it.', '完璧。前の仕事では書類が多すぎた。会議。報告書。ここは違うようだ。特別。好きだ。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We keep it light. The model is build fast, learn fast. Your position is key. The backend holds everything. We trust you.', '軽く保ってる。モデルは速く作る、速く学ぶ。君のポジションは重要。バックエンドが全部を支える。信頼してる。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will not let you down. I am ready to be a full player. From day one. This is a special chance.', '期待を裏切りません。フルプレイヤーになる準備ができています。初日から。これは特別なチャンスです。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Good. One more thing. We have a record of all our sprints. In the wiki. Study the last season. You will see our rhythm.', 'いいね。もう一つ。全スプリントの記録がある。ウィキに。前の期を勉強して。リズムがわかる。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I will. I already read the intro papers. The tech stack. The architecture. I want to contribute early. Not wait.', 'します。すでにイントロの書類を読んだ。テックスタック。アーキテクチャ。早く貢献したい。待たない。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'That is the spirit. The director likes proactive people. Your position has room to grow. We are small. You can shape things.', 'それだ。ディレクターは率先する人が好き。君のポジションには成長の余地がある。小さい。形作れる。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. I am excited. New season. New team. New product. Full speed ahead.', 'ありがとう。ワクワクしてます。新しい期。新しいチーム。新しい製品。フルスピードで。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Welcome to the team. See you at stand-up. Goodbye.', 'チームへようこそ。スタンドアップで。さようなら。' FROM conv4;
