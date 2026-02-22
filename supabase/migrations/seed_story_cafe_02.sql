-- 3分ストーリー: カフェ&レストラン（2本目）
-- 使用単語: serious, occur, media, ready, sign, thought, list, individual, simple, quality, pressure, accept
-- theme_slug: cafe | situation_type: common | theme: カフェ&レストラン

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '電話でのレストラン予約',
    'レストランに電話で予約を入れる会話。',
    3,
    37
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '予約の依頼', '日時と人数', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '希望の確認', '席の種類', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '特別リクエスト', '記念日など', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '予約の確定', '名前と連絡先', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I would like to make a reservation. For Friday. Table for four. Around seven. Is that possible?', 'こんにちは。予約したい。金曜日。4名。7時頃。可能ですか？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Let me check. Friday. Seven. We have space. I can accept your booking. Quality tables. Good view. Would you prefer window or central?', '確認します。金曜。7時。空きあり。予約お受けできる。品質のテーブル。眺め良い。窓際か中央？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Window please. We thought a view would be nice. It is a media company dinner. Colleagues. Individual preferences. But view is common. We all agree.', '窓際で。眺めがいいと思った。メディア会社の夕食。同僚。個人の好み。でも眺めは共通。皆同意。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Window it is. Table for four. Friday seven. I will add you to the list. Name please? We need to sign the booking. Confirm it.', '窓際で。4名。金曜7時。リストに追加。お名前は？予約にサイン。確認する。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Smith. John Smith. No pressure. But it is a serious dinner. Client meeting. Quality matters. The food. The service. We want to impress.', 'スミス。ジョン・スミス。プレッシャーなしで。でも重要な夕食。クライアントミーティング。品質が重要。料理。サービス。印象づけたい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We understand. Serious occasions. We are ready for that. Our chef takes it seriously. Quality ingredients. Simple but elegant. Media has praised us. Good sign.', 'わかります。重要な場面。準備できてる。シェフは真剣。品質の食材。シンプルだがエレガント。メディアが称賛。良い兆し。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I read the reviews. That is why we chose you. Can I request something? A birthday occurs that day. One of our group. Can you do a cake?', 'レビューを読んだ。だから選んだ。リクエストできる？その日誕生日が。グループの1人。ケーキできる？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Of course. We accept special orders. Cake. No problem. Individual portion or shared? We have a dessert list. Chocolate. Fruit. Your choice.', 'もちろん。特別オーダーお受け。ケーキ。問題ない。一人前かシェア？デザートリストあり。チョコレート。フルーツ。お選びください。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Shared. One cake for four. With a candle. Simple. The thought counts. We will surprise her. No pressure to sing. Just the cake.', 'シェア。4人で1つ。キャンドル付き。シンプル。気持ちが大切。サプライズする。歌うプレッシャーなし。ケーキだけ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'I will note that. Birthday. Shared cake. Candle. No singing. The kitchen will be ready. We make it special. Quality presentation.', 'メモする。誕生日。シェアケーキ。キャンドル。歌なし。キッチンは準備OK。特別に。品質のプレゼンテーション。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Perfect. So Friday. Seven. Four people. Window. Smith. Birthday cake. Anything else I should know? Cancellation?', '完璧。金曜。7時。4名。窓際。スミス。誕生日ケーキ。他に？キャンセルは？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Cancel by noon Friday. No charge. After that we may charge. Simple rule. Common in the industry. Pressure on us too. Tables are limited.', '金曜正午までにキャンセル。無料。その後はチャージかも。シンプルなルール。業界共通。私たちにもプレッシャー。テーブルは限られてる。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Understood. I will not cancel. Serious plans. Media client. Important. Can I give you my phone? In case something occurs. Change of time.', '承知。キャンセルしない。重要な予定。メディアクライアント。大事。電話番号を？万が一起こる。時間変更。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes please. I will add it to the list. Individual contact. We call if needed. Good sign. You are organized. We like that.', 'お願いします。リストに追加。個人の連絡先。必要なら電話。良い兆し。整理されてる。好き。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. So we are set. Friday seven. Window. Four. Smith. Birthday. I accept. All good.', 'ありがとう。準備できた。金曜7時。窓際。4名。スミス。誕生日。受け入れる。全て良い。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Confirmed. Your table is ready. We will hold it. See you Friday. Quality experience. We promise. Goodbye.', '確定。テーブルは準備。確保する。金曜に。品質の体験。約束する。さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Thank you.', 'さようなら。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
