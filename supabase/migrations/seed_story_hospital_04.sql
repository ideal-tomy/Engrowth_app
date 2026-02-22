-- 3分ストーリー: 病院（4本目）
-- 使用単語: theory, impact, respond, note, cell
-- theme_slug: hospital | situation_type: student | theme: 病院

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '処方箋と薬の受け取り',
    '処方箋を持って薬局に行き、薬の受け取り方と服用方法を確認する会話。',
    3,
    79
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '薬局で', '処方箋提出', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '服用方法', '回数とタイミング', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '副作用', '注意点', 'student', '病院'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お会計', 'お礼', 'student', '病院'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I have a prescription from the doctor. The theory is throat infection. Impact on my voice. How do I respond to the medicine? Should I note my cell number for contact?', 'こんにちは。医師の処方箋。理論はのど感染。声への影響。薬にはどう対応？連絡用に携帯番号を注記？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Prescription here. The theory of our process is quick. Impact is ten minutes. We respond when ready. Note your name. Cell for our record. Good.', '処方箋これ。プロセスの理論は速い。影響は10分。準備できたら対応。名前を注記。記録用携帯。いい。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'How do I take it? Theory of instructions? Impact on my throat? How fast do I respond? Note the dose? Cell timing?', 'どう飲む？説明の理論？のどへの影響？どれくらい速く対応？用量を注記？携帯のタイミング？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Two pills three times a day. Theory is after meals. Impact on stomach is less. You respond better. Note on the label. Use your cell phone. Take a photo.', '2錠1日3回。理論は食後。胃への影響は少ない。 better 対応。ラベルに注記。携帯使って。写真撮って。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Photo is a good idea. Theory to remember. Impact on memory. I respond to a reminder. Note. I will set a cell alarm. Good idea.', '写真はいいアイデア。覚える理論。記憶への影響。リマインダーに対応。注記。携帯アラームをセット。良いアイデア。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Side effects? Theory is they are rare. Impact may include drowsiness. Respond if severe. Note. Stop. Use your cell to call the doctor. Return to clinic.', '副作用？理論は稀。影響に眠気を含む。ひどければ対応。注記。止める。携帯で医師に電話。クリニックに戻る。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Drowsiness. Theory. Can I drive? Impact on my class? How do I respond carefully? Note. Morning dose. Is evening safer? Cell schedule?', '眠気。理論。運転できる？授業への影響？どう注意して対応？注記。朝のdose。夕方はsafer？携帯スケジュール？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Theory is take it in the evening. Impact is less on class. You respond better after dinner. Note. Last dose before bed. Cell reminder at 9 PM. Good.', '理論は夕方に飲む。授業への影響は少ない。夕食後に対応 better。注記。就寝前が最後のdose。携帯リマインダー9時PM。いい。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. Theory is clear. Impact was helpful. I respond well. Note everything. I saved it on my cell. Good.', 'ありがとう。理論は明確。影響は有益だった。うまく対応。すべて注記。携帯に保存。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Five days supply. Theory complete. Impact for full recovery. Respond and finish all. Note. Even if you feel better. Cell. Finish the course.', '5日分供給。理論完了。完全回復への影響。すべて終えて対応。注記。良くなっても携帯。コースを終える。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'I will finish all. Theory understood. Impact is important. I respond to the instructions. Note. I will be careful. Cell reminder is set. Thank you.', 'すべて終える。理論は理解。影響は重要。説明に対応。注記。注意する。携帯リマインダーはセット。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Total is twenty dollars. Theory of insurance? Impact on coverage? I respond and check. Note. Card or cell? Payment ready?', '合計は20ドル。保険の理論？カバレッジへの影響？対応してチェック。注記。カードか携帯？支払い準備？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Card. Theory I pay. Impact. Can I get a receipt? I respond and need it. Note for insurance claim. Can I cell photo the receipt?', 'カード。払う理論。影響。領収書？対応して必要。保険請求用に注記。携帯で領収書を写真？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. Receipt. Theory includes. Impact. All info. You respond to the claim. Note the policy number. Cell copy. Email too.', 'はい。領収書。理論は含む。影響。すべての情報。請求に対応。ポリシー番号を注記。携帯コピー。メールも。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. Theory complete. Impact of good care. I respond with gratitude. Note everything. Cell is ready. Goodbye.', 'ありがとう。理論完了。良いケアの影響。感謝で対応。すべて注記。携帯は準備。バイバイ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Theory. Get well. Impact soon. Respond to the medicine. Note rest. Cell update the doctor if needed. Take care.', 'バイバイ。理論。お大事に。影響は soon。薬に対応。休息を注記。必要なら携帯で医師にアップデート。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Theory thanks. Impact was big. You respond helpfully. Note. Pharmacy was good. I saved the cell number. If I have questions. Thank you.', 'バイバイ。理論ありがとう。影響は大きかった。有益に対応。注記。薬局はよかった。携帯番号を保存。質問あれば。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Good luck. Get well soon.', 'バイバイ。頑張って。お大事に。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Theory was clear. Impact positive. I respond with confidence. Note recovery. I will cell track my progress. Good.', 'バイバイ。理論は明確だった。影響はポジティブ。自信で対応。回復を注記。携帯で進捗追跡。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care of yourself.', 'バイバイ。お気をつけて。' FROM conv4;
