-- 3分ストーリー: プレゼンテーション②（1本目）
-- 使用単語: impact, respond, statement, maintain, charge, popular
-- theme_slug: presentation2 | situation_type: business | theme: プレゼンテーション②

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '解決策の提案',
    '具体的な解決策を提示し、メリット・デメリットを説明するプレゼンの練習。',
    3,
    61
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '解決策の紹介', '3つの提案', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'メリットの説明', '各案の利点', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'デメリットの共有', 'リスクと課題', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '推奨案と質疑', '結論とQ&A', 'business', 'プレゼンテーション②'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Thank you. Three solution options. I will explain the impact of each. Please respond with questions anytime.', 'ありがとう。3つの解決策。それぞれの影響を説明。質問はいつでも。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Three options. What is the charge and cost for each? We need the numbers to understand the impact on our budget.', '3つのオプション。料金とコストはそれぞれ？予算への影響の数字が必要。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'On slide ten. Option one has a low charge of five K. It is popular as a quick win. We maintain the current system with minor changes. The impact is small but fast.', 'スライド10。オプション1は低料金5K。早い成果で人気。現システムを維持し小変更。影響は小さいが速い。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Low charge and popular. You maintain the current approach. That sounds like a conservative statement. Safe. Impact is limited. Right?', '低料金で人気。現状維持。保守的な声明に聞こえる。安全。影響は限定的。だよね？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Yes. Option two has a medium charge of twenty K. It has a bigger impact. We respond better to the market and maintain quality. It is a popular choice for balance.', 'はい。オプション2は中程度の料金20K。影響は大きい。市場に対応し品質を維持。バランスで人気の選択。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'What about option three? High charge and maximum impact?', 'オプション3は？高料金で最大影響？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Fifty K for full overhaul. Maximum impact. Popular long term. We maintain our competitive edge. Statement: our commitment to transform.', '50Kで完全オーバーホール。最大影響。長期で人気。競争力維持。変革への声明。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'What is our recommendation? Which option? What charge are we willing to pay? Is the impact worth it?', '推奨はどれ？料金は払う意志ある？影響は価値ある？' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Option two. Right balance. Charge reasonable. Impact significant. We maintain momentum. Popular with team. We respond to feedback. Statement is clear.', 'オプション2。バランス良い。料金合理的。影響重要。勢い維持。チームで人気。フィードバックに対応。声明明確。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Option two. Why not three? Three has maximum impact. The charge is higher but long term gain, right?', 'オプション2。なぜ3じゃない？3は最大影響。料金は高いが長期？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'The risk with option three is big change. It is hard to maintain support and resources. The charge is high and impact is uncertain. Timeline is long. Option two is safer. We can respond faster.', 'オプション3のリスクは大きな変化。サポートとリソース維持が難しい。料金は高く影響は不確実。タイムラインは長い。オプション2の方が安全。対応が速い。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'That makes sense. We maintain a good balance. Your statement is conservative but the impact is good enough. Popular choice.', '筋が通る。バランスを維持。声明は保守的だが影響は十分。人気の選択。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Exactly. Next steps. If you agree, please respond by Friday. We need a statement from leadership. We maintain the timeline. The charge goes to the project team on Monday.', 'その通り。次のステップ。同意なら金曜までに対応を。リーダーシップの声明が必要。タイムラインを維持。プロジェクトチームが月曜に担当。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'I have a question. What is the impact on HR? Do we maintain headcount? Who gets the charge in the department?', '質問がある。人事への影響は？人員は維持？部署の担当は？' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Good question. Let me respond with slide fifteen. Impact on HR is minimal. We maintain the current team. No new charge. Existing roles stay. Statement from HR is confirmed.', '良い質問。スライド15で対応。人事への影響は最小。現チームを維持。新規担当なし。既存の役割。人事の声明は確認済み。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Thank you. It is clear now. Impact is understood. Option two is the popular choice. We will maintain support and respond. The timeline looks good.', 'ありがとう。明確になった。影響は理解。オプション2が人気の選択。サポート維持して対応する。タイムラインはいい。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Summary. Option two at twenty K charge. Impact is significant. We maintain balance. It is our popular recommendation. Final statement. Please respond by Friday.', 'サマリー。オプション2は料金20K。影響は重要。バランスを維持。人気の推奨。最終声明。金曜までに対応を。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'No more questions. Impact is clear. Charge is understood. We will maintain and support. Our response is positive.', '質問なし。影響は明確。料金は理解。維持して支援する。対応は前向き。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. Let us maintain momentum. Please respond fast. I will send the statement by email tomorrow. The charge team is ready.', 'ありがとう。勢いを維持しよう。速く対応を。声明は明日メールで。担当チームは準備済み。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good presentation. The impact was strong. Popular choice understood.', 'バイバイ。いいプレゼンだった。影響は強かった。人気の選択は理解した。' FROM conv4;
