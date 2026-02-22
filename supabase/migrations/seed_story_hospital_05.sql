-- 3分ストーリー: 病院（5本目）
-- 使用単語: above, seat, discover, candidate
-- theme_slug: hospital | situation_type: student | theme: 病院

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '検診結果の説明を受ける',
    '健康診断の結果を受け取り、医師から説明を聞く会話。',
    3,
    80
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '結果の受け取り', 'オーバールック', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '数値の説明', '基準値と比較', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'アドバイス', '生活習慣', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '次の検診', 'お礼', 'student', '病院'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Doctor, my check up results? Did you discover something? Am I a candidate for concern? Is anything above normal? Please take a seat and tell me.', '医師、検診結果は？何か発見？懸念の候補者？正常以上？席について教えて。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Take a seat please. I discover the results are good overall. You are a candidate for healthy. Above average fitness. In your seat relax. Good news.', 'お座りください。結果を発見、全体的にいい。健康の候補者。平均以上のフィットネス。席でリラックス。良い知らせ。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Above average? You discover really? I was a candidate who worried. In my seat I was nervous. Above my expectation? Good.', '平均以上？本当に発見？心配していた候補者だった。席で緊張してた。期待以上？いい。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'I discover blood pressure good. You are a candidate for normal. Above concern no. Heart rate fine. Cholesterol slightly above ideal. Candidate for diet change. No worry.', '血圧を発見、いい。正常の候補者。懸念以上なし。心拍大丈夫。コレステロールわずかに理想以上。食事変更の候補者。心配なし。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Cholesterol above. What did you discover? How much? Am I a candidate for something serious? In my seat I have concern. Above danger level?', 'コレステロール以上。何を発見？どのくらい？深刻な候補者？席で懸念。危険以上？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Slightly above. I discover it is 210. You are a candidate. Ideal is 200. In your seat. Below the limit of 240. Above that we worry. I discover it is an easy fix. You are a candidate for diet and exercise.', 'わずかに以上。210を発見。候補者。理想は200。席で。制限240以下。それ以上は心配。簡単な修正を発見。食事と運動の候補者。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Diet and exercise. What do you discover? Am I a candidate for something specific? A plan? Above all what do I do?', '食事と運動。何を発見？具体的な候補者？プラン？何より何をする？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'I discover less fat. You are a candidate for more vegetables. In your seat. Walk thirty minutes. Above that daily. I discover it is simple. You are a candidate. Consistency is the key. Above all.', '脂肪を少なく発見。野菜をもっとの候補者。席で。30分歩く。毎日以上。シンプルと発見。候補者。一貫性が鍵。何より。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I discover it sounds easy. I am a candidate. I can manage. In my seat. I am a student. Above that I am busy. How do I discover and fit it in?', '簡単に聞こえると発見。候補者。管理できる。席で。学生。以上に忙しい。どう発見して合わせる？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I discover. Walk to class instead of bus. Twenty minutes above enough. Lunch salad sometimes. Small change. Above has big impact.', '発見。バス代わりに授業へ歩く。20分は十分以上。ランチは時々サラダ。小さな変化。以上が大きな影響。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I discover that was helpful. I am a candidate. Practical. Thank you. Above expectation. I discover I am relieved. Candidate for healthy. Good.', '有益だと発見。候補者。実践的。ありがとう。期待以上。安心だと発見。健康の候補者。いい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Next check in six months. Candidate for follow up. We monitor. If things change above, return earlier. Problems above normal.', '次チェックは6ヶ月。フォローアップの候補者。モニター。変化以上なら早めに戻る。問題が正常以上なら。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Six months. I discover that is OK. I am a candidate. I will schedule. In my seat. I note it above on my calendar. I discover I need a reminder. Thank you, Doctor.', '6ヶ月。OKだと発見。候補者。スケジュールする。席で。カレンダーに以上でメモ。リマインダーが必要と発見。ありがとう医師。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Goodbye. I discover you are a great candidate. For health. In your seat. Continue above with good habits. Take care.', 'バイバイ。すごい候補者だと発見。健康の。席で。良い習慣以上を続けて。お気をつけて。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. I discover thanks. I am a candidate who feels reassured. In my seat I am confident. Above all. Good care. Thank you.', 'バイバイ。感謝を発見。安心した候補者。席で自信。何より。良いケア。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Good luck. Stay healthy.', 'バイバイ。頑張って。健康で。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I discover the plan is clear. I am a candidate. In my seat I am ready. Above worry. Good day.', 'バイバイ。プランが明確だと発見。候補者。席で準備。心配以上。よい一日を。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. I discover you were helpful. I am a candidate who is grateful. In my seat. Thanks above all. Good.', 'バイバイ。有益だったと発見。感謝する候補者。席で。何よりありがとう。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good day to you.', 'バイバイ。よい一日を。' FROM conv4;
