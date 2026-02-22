-- 3分ストーリー: 学生・新職場自己紹介（5本目）
-- 使用単語: full, model, season, society, tax, director, early, position, player, record, paper, special
-- theme_slug: selfintro_student

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'メディア会社での初対面',
    'メディア会社の編集部に配属され、先輩に自己紹介する会話。',
    3,
    20
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と希望', '編集部で自己紹介', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '経験とスキル', 'これまでの実績', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '役割と方針', '編集のポリシー', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の連携', 'チームでの働き方', 'student', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning. I am Hana. I joined the editorial team this season. My position is assistant editor. Nice to meet you.', 'おはようございます。花です。今期編集チームに加わりました。ポジションはアシスタント編集者です。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Hana. I am the senior editor. The director told me about you. Your record on paper was impressive. We need new players.', 'ようこそ花さん。シニアエディターです。ディレクターから聞いていました。履歴書の記録は印象的だった。新しいプレイヤーが必要なんだ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I came early to learn. I want to understand the full process. How does the editorial model work here?', 'ありがとう。学ぶために早く来ました。フルプロセスを理解したい。ここでの編集モデルはどうなっていますか？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We work in seasons. Four issues per year. Each one is special. The society we cover is broad. Culture. Politics. Economy. Tax too sometimes.', '期で働いています。年4号。それぞれ特別。取材する社会は広い。文化。政治。経済。税も時々。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I like that range. My last job was narrow. Here I can learn the full picture. Different paper every time.', 'その幅が好きです。前の仕事は狭かった。ここでは全体像を学べる。毎回違う紙面。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'What was your record at the last place? The paper said you had three years. What did you edit?', '前の職場の記録は？履歴書に3年とあった。何を編集してた？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Culture section. Full time. I was the main player for arts coverage. We had a special model. One long piece per issue. Deep dive.', '文化セクション。フルタイム。芸術取材のメイン担当でした。特別なモデルがあった。1号に1本の長い記事。深掘り。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good. We do similar work. The director likes deep pieces. We also need quick news. Your position will do both. Special features.', 'いいね。似た仕事をしてる。ディレクターは深い記事が好き。速報も必要。君のポジションは両方。特別企画。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I can handle that. I had to switch fast at my old job. Paper one day. Digital the next. The model was always changing.', '対応できます。前の仕事では切り替えが速かった。紙の日。翌日デジタル。モデルはいつも変わってた。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Same here. Media society changes fast. We adapt. Your record suggests you can keep up. Welcome to the team.', 'ここも同じ。メディアの社会は速く変わる。適応する。君の記録はついてこれそうだ。チームへようこそ。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'When does the next season start? I want to be full speed by then. What is the first paper I will work on?', '次の期はいつ始まりますか？その時までにフルスピードになりたい。最初に手がける紙面は？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Next month. We have a special issue on tax reform. The director wants a fresh angle. Your position is to research and draft. Then we edit.', '来月。税制改革の特別号がある。ディレクターは新しい角度が欲しい。君のポジションはリサーチと下書き。それから私たちが編集。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I like research. My record in long-form is good. I can find the human story. Tax sounds dry. But people feel it. I will bring that.', 'リサーチが好きです。ロングフォームの記録は良い。人の物語を見つけられる。税は地味に聞こえる。でも人は感じる。それを出したい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'That is the right mindset. We are not a dry paper. We are a society magazine. People first. Your special skill is exactly what we need.', '正しい心構えだ。地味な紙じゃない。社会誌だ。人が第一。君の特別なスキルがまさに必要。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. I will give it my full effort. Early drafts. Good research. I want to be a real player. Not just support.', 'ありがとう。フルで努めます。早い下書き。良いリサーチ。本当のプレイヤーになりたい。サポートだけじゃなく。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Good. The director will assign your first piece soon. We keep a record of all past issues. Paper copies. Study them. You will learn our voice.', 'いいね。ディレクターがすぐ最初の記事を割り当てる。過去号の全記録を保持。紙のコピー。勉強して。声がわかる。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'I will. I already read the last two seasons. The model is clear. Long reads. Good design. Serious but not dull. I like it.', 'します。すでに過去2期を読んだ。モデルは明確。長編。良いデザイン。真面目だが退屈じゃない。好きです。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You did your homework. That is special. Many new players do not. We are glad to have you. Full team now. Ready for the season.', '宿題してくれた。それは特別だ。多くの新人はしない。来てくれて嬉しい。フルチームになった。期の準備ができた。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. I am ready. New position. New paper. New season. I will do my best.', 'ありがとう。準備できています。新しいポジション。新しい紙面。新しい期。最善を尽くします。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'See you at the editorial meeting. Tomorrow ten. Goodbye.', '編集会議で。明日10時。さようなら。' FROM conv4;
