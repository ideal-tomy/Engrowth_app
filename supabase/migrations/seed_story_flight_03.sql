-- 3分ストーリー: 飛行機（3本目）
-- 使用単語: place, single, rule, daughter, administration, south, floor, either, husband, Congress, campaign
-- theme_slug: flight | situation_type: common | theme: 飛行機

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '遅延便の案内',
    '空港で遅延した便についてカウンターで質問し、代替案を聞く会話。',
    3,
    28
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '遅延の確認', 'カウンターで質問', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '代替便の案内', '次の便の情報', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '補償の説明', 'ルールとオプション', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '搭乗案内', 'ゲートと待合場所', 'common', '飛行機'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. My flight to the south is delayed. I saw it on the board. What is the rule? Can I get a new place on another flight?', 'すみません。南行きの便が遅延しています。案内板で見ました。ルールは？別の便の席を取れますか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'I am sorry. The administration announced a two-hour delay. Weather south. We have a rule. You can either wait or rebook. Single passengers get priority.', '申し訳ありません。運営から2時間遅延の発表。南の天候。ルールでは待つか再予約のどちらか。一人旅は優先。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'I am traveling with my husband and daughter. We need three seats. Is there a place on the next flight? The Congress starts tomorrow.', '夫と娘と一緒です。3席必要。次の便に空きは？コングレスは明日始まります。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Let me check. We have a campaign. Free rebooking for delayed flights. I can place you on flight 310. Leaves in three hours. Same route south.', '確認します。キャンペーンがあります。遅延便は無料再予約。310便に確保できます。3時間後に出発。同じ南ルート。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Three hours. That might work. The Congress registration is at five. We need to reach the south by four. What floor is the gate?', '3時間。間に合うかも。コングレス登録は5時。4時までに南に着く必要。ゲートは何階？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Gate C5. Floor two. South terminal. Same as your original. The rule for rebooking is simple. No fee. You keep your seats. Either this flight or 310. Your choice.', 'C5ゲート。2階。南ターミナル。元の便と同じ。再予約のルールは簡単。手数料なし。席は確保。この便か310のどちらか。お選びください。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'We will take 310. Safer. The delay might get longer. My husband has a meeting at the Congress. We cannot miss it.', '310便にします。安全。遅延が延びるかも。夫はコングレスで会議。遅れられません。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Understood. I will transfer your booking. Three seats. Window, middle, aisle. Or do you prefer a single row? We have place in row eight.', '承知しました。予約を転送します。3席。窓、真ん中、通路。それとも1列？8列に空きが。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Row eight is perfect. Together. My daughter likes the window. I will take the aisle. Husband in the middle. Can we get meal vouchers? The floor cafe?', '8列が完璧。一緒に。娘は窓が好き。私は通路。夫は真ん中。食事券は？フロアのカフェ？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Part of our delay campaign. Ten dollars each. Use at any cafe on floor two. South side. Near gate C. The administration offers this for delays over ninety minutes.', 'はい。遅延キャンペーンの一部。お一人10ドル。2階のどのカフェでも。南側。Cゲート近く。90分以上の遅延で運営が提供。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. That helps. So flight 310. Gate C5. Floor two. South. Meal vouchers. We are set.', 'ありがとう。助かります。310便。C5ゲート。2階。南。食事券。準備できました。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Here are your new passes. The rule for boarding is thirty minutes before. So be at the gate by two forty-five. Either original or 310. Same gate area.', 'はい。新しい搭乗券です。搭乗のルールは30分前。2時45分までにゲートへ。元の便も310も。同じゲートエリア。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Got it. Thank you for the help. The administration handled this well. Better than I expected. We will use your airline again.', 'わかりました。助けてくれてありがとう。運営の対応は良かった。予想より。また利用します。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'You are welcome. Sorry for the delay. Enjoy the Congress. Safe travels south.', 'どういたしまして。遅延申し訳ありません。コングレスを楽しんで。南への良い旅を。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. Goodbye.', 'ありがとう。さようなら。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye.', 'さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks again.', 'もう一度ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Anytime.', 'いつでも。' FROM conv4;
