-- 3分ストーリー: カスタム（2本目）
-- 使用単語: pain, apply, measure, wide, shake
-- theme_slug: custom | situation_type: common | theme: カスタム

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '興味トピックの設定',
    'コンサルタントと興味のあるトピックや学習スタイルを話し合う会話。',
    3,
    82
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '趣味と興味', '話したい分野', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '学習スタイル', '視覚・聴覚など', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '教材の選択', 'トピックに合わせて', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '最初の課題', 'お礼', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. Custom plan. My pain point is vocabulary. Hard to apply. I cannot measure progress. Wide gap. Shakes my confidence. I need help.', 'こんにちは。カスタムプラン。痛みのポイントは語彙。適用が難しい。進捗を計れない。幅広いギャップ。自信を揺さぶる。助けが必要。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Tell me your interests. We apply to learning. Measure what works. Wide range. Shake off pain. Find topics you love.', '興味を教えて。学習に適用。何が効くか計る。幅広い範囲。痛みを振り払う。好きなトピックを。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Travel and technology. I apply to both. I measure relevance. They have wide appeal. I want to shake off boring. The pain of dry topics like business only.', '旅行と技術。両方に適用。関連性を計る。幅広い魅力。退屈を揺さぶりたい。ビジネスだけのような堅いトピックの痛み。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. We apply travel and tech. We measure content. We have a wide library. We shake up the mix. Pain reduces when you enjoy. We apply to real life.', 'いい。旅行と技術に適用。コンテンツを計る。幅広いライブラリ。ミックスを揺さぶる。楽しむと痛みは減る。実生活に適用。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Apply to real life. How do we measure that? Wide examples? I want to shake the context. The pain is I memorize without use. It is hard.', '実生活に適用。どう計る？幅広い例？文脈を揺さぶりたい。使わずに暗記する痛み。難しい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We apply scenarios. We measure through practice. Wide situations. We shake with role play. Pain turns into fun. We apply travel dialogue and tech vocabulary.', 'シナリオに適用。練習で計る。幅広い状況。ロールプレイで揺さぶる。痛みが楽しみに。旅行対話と技術語彙に適用。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Role play. I apply and like it. Do we measure if it is effective? Wide support? I shake when nervous. The pain of speaking. Do we apply a safe space?', 'ロールプレイ。適用して好き。効果的か計る？幅広いサポート？緊張で揺さぶる。スピーキングの痛み。安全スペースに適用？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. We apply gently. We measure at your pace. Wide comfort. We shake gradually. Pain eases. We apply step by step. Wide support always.', 'はい。優しく適用。あなたのペースで計る。幅広い快適さ。徐々に揺さぶる。痛みは和らぐ。ステップごとに適用。いつも幅広いサポート。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'How do we measure progress? Wide tracking? Does it shake me to stay motivated? The pain is I want to see results. How do we apply?', '進捗をどう計る？幅広い追跡？やる気を揺さぶる？結果を見たい痛み。どう適用？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We apply weekly check. We measure goals. Wide dashboard. We shake with visual. Pain becomes clear. We apply and celebrate small wins. Wide recognition.', '週次チェックに適用。目標を計る。幅広いダッシュボード。視覚で揺さぶる。痛みは明確に。適用して小さな勝利を祝う。幅広い認識。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'What is the first task? Do we apply today? How do we measure the start? I feel wide and excited. I shake and I am ready. I hope the pain goes away. We apply soon.', '最初のタスクは？今日適用？開始をどう計る？幅広くワクワク。揺さぶって準備。痛みが消える希望。soon 適用。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We apply a reading task. We measure your level. Wide article on travel or tech. We shake your vocabulary. The pain. Learn five words. Apply and use in a sentence.', 'リーディングタスクに適用。レベルを計る。旅行か技術の幅広い記事。語彙を揺さぶる。痛み。5語学ぶ。適用して文で使う。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Five words. I apply. That is manageable. We measure daily. Wide build. We shake into a habit. I avoid the pain of overwhelm. Good.', '5語。適用する。管理可能。毎日計る。幅広く築く。習慣に揺さぶる。圧倒の痛みを避ける。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We apply app access. You measure anytime. Wide material. Shake with practice. Pain is flexible. We apply to your schedule. Goodbye.', 'アプリアクセスに適用。いつでも計る。幅広い教材。練習で揺さぶる。痛みは柔軟。スケジュールに適用。バイバイ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. The apply is clear. We measure the plan. Wide scope. I shake with confidence. Pain relief. Thank you.', 'バイバイ。適用は明確。プランを計る。幅広いスコープ。自信で揺さぶる。痛みの安堵。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Apply to yourself. We measure progress. Wide smile. Shake off the doubt. Pain becomes growth. Take care.', 'バイバイ。自分に適用。進捗を計る。幅広い笑顔。疑いを振り払う。痛みが成長に。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I apply with gratitude. I measure your help. Wide thanks. Shake hands. Pain turns to joy. Good.', 'バイバイ。感謝で適用。助けを計る。幅広いありがとう。握手。痛みが喜びに。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Good luck with your learning.', 'バイバイ。学習頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Same apply next week. We measure. Wide hope. I shake for success. Thank you.', 'バイバイ。来週同じ適用。計る。幅広い希望。成功で揺さぶる。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
