-- 3分ストーリー: 病院（3本目）
-- 使用単語: perform, production, bit, weight, suddenly
-- theme_slug: hospital | situation_type: student | theme: 病院

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '医師に症状を伝える',
    '診察室で医師に症状を詳しく伝える会話。',
    3,
    78
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '症状の説明', 'いつから', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '診察', '診断の説明', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '処方', '薬の説明', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '注意事項', 'お礼', 'student', '病院'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Doctor, my throat hurts. It started suddenly two days ago. Production of pain is bad at night. There is a weight on my chest. A bit hard to breathe.', '医師、のどが痛い。2日前に突然始まった。痛みの生産は夜悪い。胸に重さ。息が少し難しい。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'I see. Let me perform an exam of your throat. Production of mucus? Any weight loss? A bit of fever? Did it start suddenly or gradual?', 'なるほど。のどの検査を遂行する。痰の生産？体重減少？少し熱？突然か徐々に？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Suddenly on Monday. Production of mucus is heavy. My weight is normal. I feel a bit tired. It is hard to perform in class. Weight of fatigue.', '月曜に突然。痰の生産は多い。体重は普通。少し疲れた。授業で遂行するのが大変。疲労の重さ。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'I will perform a check now. Production. Throat culture. I check the weight of your glands. A bit of pressure. Open and say ah.', '今チェックを遂行する。生産。のど培養。リンパの重さをチェック。少し圧力。開けてアーと言って。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Ah. That was easy to perform. Production of pain when I swallow. Weight is uncomfortable. I am a bit scared. Is it serious?', 'アー。遂行するのは簡単だった。飲み込む時の痛みの生産。重さは不快。少し怖い。深刻？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'I performed the exam. Done. Production. Your throat is red. Weight suggests infection. Likely a bit viral, not bacterial. Perform rest and fluids. Production of recovery is natural.', '検査を遂行した。完了。生産。のどは赤い。重さは感染を示す。少しウィルス性の可能性、細菌ではない。休息と水分を遂行。回復の生産は自然。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Viral. Production. So no antibiotics? What about the weight? What do I take? I am a bit confused. What do I perform?', 'ウィルス性。生産。抗生物質なし？重さは？何を飲む？少し混乱。何を遂行？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'No antibiotics. For viral, production of them is useless. Weight is for bacteria. A bit different. Perform pain relief. Production of medicine. Throat lozenges. Weight of rest.', '抗生物質なし。ウィルス性には生産は無駄。重さは細菌用。少し違う。痛み軽減を遂行。薬の生産。のどトローチ。休息の重さ。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'When will I suddenly get better? Production? Weight of days? I am a bit impatient. I perform and miss class already.', 'いつ突然良くなる？生産？日数の重さ？少し焦る。授業を遂行して欠席してる。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'A bit more patience. Production of three to five days. Weight of rest is important. Perform recovery. It goes faster. You will suddenly feel better if you rest.', '少しもっと忍耐。3から5日の生産。休息の重さは重要。回復を遂行。速くなる。休息すれば突然良くなる。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Where is the medicine production? Weight. Pharmacy? Is it a bit far? Can I perform and buy tonight?', '薬の生産はどこ？重さ。薬局？少し遠い？今夜買いに行ける？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Pharmacy downstairs. Production is in the building. Weight is convenient. A bit of a wait. I perform and give you the prescription now.', '薬局は階下。生産は建物内。重さは便利。少し待ち。今処方箋を渡す。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thank you. Production is clear. Weight of relief. I am a bit reassured. I will perform rest. Production of health soon. Good.', 'ありがとう。生産は明確。安心の重さ。少し安心。休息を遂行する。健康の生産は soon。いい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'If you suddenly get worse? Production of fever? Weight goes high? A bit of concern? Perform a return. Production of a visit. Immediately.', '突然悪化したら？熱の生産？重さが高く？少し心配？戻ることを遂行。受診の生産。即座に。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Got it. Production. I will watch the weight of symptoms. A bit careful. I perform rest. Thank you, Doctor.', '了解。生産。症状の重さを監視する。少し注意。休息を遂行。ありがとう医師。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Production of good health. Weight of rest. A bit of fluids. Perform recovery. You will suddenly feel better soon. Take care.', 'バイバイ。健康の生産。休息の重さ。少し水分。回復を遂行。 soon 突然良くなる。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Production thanks. Weight of your advice. I am a bit grateful. I will perform and follow. Thank you.', 'バイバイ。生産のありがとう。アドバイスの重さ。少し感謝。従って遂行する。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Get well. Production soon. Weight off your shoulders. A bit of rest. Good.', 'バイバイ。お大事に。生産は soon。肩から重さ。少し休息。いい。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Production was professional. Weight of care. I am a bit relieved. I will perform better. Thank you.', 'バイバイ。生産はプロだった。ケアの重さ。少し安心。 better 遂行する。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
