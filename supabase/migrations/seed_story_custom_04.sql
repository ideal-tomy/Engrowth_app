-- 3分ストーリー: カスタム（4本目）
-- 使用単語: structure, politics, perform, production
-- theme_slug: custom | situation_type: common | theme: カスタム

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '週次レビューの設定',
    '週次の進捗レビューとフィードバックの受け方について相談する会話。',
    3,
    84
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'レビューの目的', '何を確認するか', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'フィードバック', '受け方', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '次の目標', '週ごとに', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'まとめ', 'お礼', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Weekly review. What is the structure? The politics of feedback? How do we perform? What is the production of progress? Is it a custom process?', '週次レビュー。構造は何？フィードバックの政治？どう遂行？進捗の生産は？カスタムプロセス？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'The structure is simple. Politics of openness. We perform with honesty. Production of goals. Custom to you. Structure is fifteen minutes. Politics of check. We perform wins and production challenges.', '構造はシンプル。オープンな政治。正直に遂行。目標の生産。あなたにカスタム。構造は15分。チェックの政治。勝利と生産の課題を遂行。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'We perform wins. Production even when small? Does the structure celebrate? Politics positive? Do we perform to build production morale?', '勝利を遂行。小さいときも生産？構造は祝う？ポジティブな政治？士気の生産を築くよう遂行？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. The structure covers both. Politics of wins and challenges. We perform a balanced production of growth. Custom focus. Structure to your needs. Politics adapt.', 'はい。構造は両方。勝利と課題の政治。バランスの取れた成長の生産を遂行。カスタム焦点。ニーズに構造。政治は適応。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'How do we perform feedback? Production direct? Structure gentle? Politics critical? How do we perform? What production is best?', 'フィードバックをどう遂行？生産は直接的？構造は優しく？政治は批評？どう遂行？ベストな生産は？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We use a structure. Sandwich. Politics of praise first. We perform. Then improvement. Production ends positive. Structure is encouraging. Politics always. We perform growth. Production mindset.', '構造を使う。サンドイッチ。まず褒める政治。遂行する。次に改善。生産はポジティブに終わる。構造は励ます。政治はいつも。成長を遂行。生産マインドセット。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'The structure is clear. Politics helpful. We perform. Not harsh. Production of confidence. Custom approach. Good.', '構造は明確。政治は有益。遂行する。厳しくない。自信の生産。カスタムアプローチ。いい。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Structure is weekly. Politics of same day? We perform consistent. Production of routine. Custom to your schedule.', '構造は週次。同じ日の政治？一貫して遂行。ルーティンの生産。スケジュールにカスタム。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Friday. Structure at end of week. Politics of reflect. We perform a summary. Production of progress. Custom. Is that a good time?', '金曜。週末の構造。振り返りの政治。サマリーを遂行。進捗の生産。カスタム。良い時間？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Friday. Structure is perfect. Politics wrap the week. We perform and plan next. Production of momentum. Custom. Monday ready. Good.', '金曜。構造は完璧。政治で週を締める。遂行して次を計画。勢いの生産。カスタム。月曜準備。いい。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Structure for next week. Politics of goals? Do we perform and set? Production of target? Custom. Is it achievable?', '来週の構造。目標の政治？遂行してセット？ターゲットの生産？カスタム。達成可能？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Structure is two to three. Politics max. We perform with focus. Production of quality. Custom SMART. Structure specific. Politics measurable. We perform attainable. Production relevant. Custom timely.', '構造は2から3。政治最大。焦点で遂行。品質の生産。カスタムSMART。構造は具体的。政治は測定可能。達成可能に遂行。生産は関連。カスタムは時間的。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Structure SMART. I learned the politics before. We perform. Production good. I apply custom here. Thank you.', '構造SMART。前に政治を学んだ。遂行する。生産いい。ここでカスタム適用。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Structure complete. Politics. Custom plan. We perform. Ready. Production starts Monday. Custom for you. Goodbye.', '構造完了。政治。カスタムプラン。遂行する。準備。生産は月曜開始。あなたにカスタム。バイバイ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. Structure was clear. Politics helpful. I perform with confidence. Production of the plan. Custom fit. Thank you.', 'バイバイ。構造は明確だった。政治は有益。自信で遂行。プランの生産。カスタム合う。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Structure for success. Politics weekly. We perform progress. Production steady. Custom journey. Take care.', 'バイバイ。成功の構造。週次の政治。進捗を遂行。生産は着実。カスタムの旅。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Structure thanks. Politics. Custom. I perform my best. Production hope. Good.', 'バイバイ。構造ありがとう。政治。カスタム。ベストを遂行。生産の希望。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Good luck with your goals.', 'バイバイ。目標頑張って。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Structure ready. Politics Monday. I perform goals. Production excited. Thank you.', 'バイバイ。構造準備。政治月曜。目標を遂行。生産ワクワク。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
