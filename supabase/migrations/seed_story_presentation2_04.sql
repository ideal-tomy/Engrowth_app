-- 3分ストーリー: プレゼンテーション②（4本目）
-- 使用単語: measure, wide, shake, fly, interview
-- theme_slug: presentation2 | situation_type: business | theme: プレゼンテーション②

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '成果指標の説明',
    'KPIや成果の測り方を聴衆に説明し、合意を得るプレゼンの練習。',
    3,
    64
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'KPIの紹介', '測定基準', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '測定方法', 'データ収集', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '目標値', 'ベンチマーク', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '進捗報告', 'レビュー頻度', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Now let me explain how we measure success. We have a wide range of metrics. I will present the key measures. Our interview with stakeholders informed our choice.', 'では成功の測定方法を。幅広い指標がある。主要な測定を発表。関係者とのインタビューが選択を伝えた。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Wide range of what? Do we measure revenue, quality, customer? Who did you interview?', '幅広い何？売上、品質、顧客を測定？誰にインタビュー？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'On slide twenty five we measure five areas. Revenue, cost, quality, satisfaction, growth. Wide coverage. We did an interview with fifty customers and thirty internal staff. I flew to the offices last month.', 'スライド25で5エリアを測定。売上、コスト、品質、満足度、成長。広いカバレッジ。50人の顧客と30人の社内スタッフにインタビュー。先月オフィスに飛んだ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'You flew to the offices. That is wide reach. To measure direct feedback. Interview is a good method. Shake hands and build trust.', 'オフィスに飛んだ。幅広いリーチ。直接フィードバックを測定。インタビューは良い方法。握手して信頼構築。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Exactly. We measure qualitative data too. Not just numbers. The interview helps reveal context. We shake off assumptions. We get a wide picture.', 'その通り。定性的にも測定。数字だけじゃない。インタビューが文脈を明らかに。仮定を振り払う。幅広い絵を得る。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'What are the target values? What do we measure against? Does it shake the status quo? Is it ambitious?', '目標値は？何に対して測定？現状を揺さぶる？野心的？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Slide twenty six. Revenue up twenty percent. Cost down ten. We measure year over year. Wide gap from where we are now. It will shake our market position.', 'スライド26。売上20パーセント増。コスト10パーセント減。前年比で測定。今からの広いギャップ。市場ポジションを揺さぶる。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Ambitious targets. Is the measure realistic? What did the interview say? Feasible? We fly high but is it achievable?', '野心的な目標。測定は現実的？インタビューは何と言った？実現可能？高く飛ぶが達成可能？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Yes. The interview gave us high confidence. Wide support. We measure progress monthly. We shake off doubt with data. We fly forward.', 'はい。インタビューで高い自信を得た。幅広いサポート。進捗は毎月測定。データで疑いを揺さぶる。前へ飛ぶ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Monthly measure is frequent. That is good. We shake early issues. Wide visibility. Interview stakeholders regularly. Nothing flies under the radar.', '毎月測定は頻繁。いい。早期に問題を揺さぶる。幅広い可視性。関係者に定期的にインタビュー。レーダー下を飛ぶものはない。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Summary. We measure five areas. Wide scope. The interview informed our approach. We shake old ways. We fly to a new direction. Thank you.', 'サマリー。5エリアを測定。幅広いスコープ。インタビューが知らせた。古い方法を揺さぶる。新しい方向へ飛ぶ。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Any questions? About the measure methodology? The interview questions? Is it wide and published?', '質問は？測定方法論について？インタビュー質問？幅広く公開？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'The appendix contains the full interview guide and measure definitions. It is wide and available. Shake hands after. Fly me an email if you need a request.', '付録に完全なインタビューガイドと測定定義を含む。幅広く利用可能。後で握手。リクエストあればメールを。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Thank you. The measure is clear. The interview approach is useful. Wide scope. It shakes our confidence. We fly high. Good.', 'ありがとう。測定は明確。インタビューは有用。幅広いスコープ。自信を揺さぶる。高く飛ぶ。いい。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. We measure success together. Interview feedback is welcome. We are wide open. Shake ideas. Fly together. Thank you.', 'バイバイ。成功を一緒に測定。インタビューフィードバック歓迎。幅広くオープン。アイデアを揺さぶる。一緒に飛ぶ。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. Measure is understood. The interview method. Wide adoption. We shake the old and fly to the new. Good day.', 'ありがとう。測定は理解。インタビュー方法。幅広い採用。古いを揺さぶり新しいへ飛ぶ。よい一日を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Materials go out tomorrow. The measure framework and interview template. Wide distribution. Let us shake and start. Fly into action.', '資料は明日。測定フレームワークとインタビューテンプレート。幅広い配布。揺さぶって開始。アクションへ飛ぶ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. Measure is ready. Interview is scheduled. Wide participation. We shake with excitement. We fly high. Goodbye.', 'いい。測定は準備。インタビューは予定。幅広い参加。興奮で揺さぶる。高く飛ぶ。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. We measure progress. Interview continues. Wide network. Shake hands. Fly to success. Thank you.', 'バイバイ。進捗を測定。インタビューは続く。幅広いネットワーク。握手。成功へ飛ぶ。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good presentation.', 'バイバイ。いいプレゼンだった。' FROM conv4;
