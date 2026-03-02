-- 初回挨拶チュートリアルのシード
-- prompt_audio_url / response_audio_url が NULL の場合はアプリ側で TTS 再生

WITH tut AS (
  INSERT INTO tutorials (title, description_ja, display_order)
  VALUES (
    '初回挨拶体験',
    '簡単な挨拶と自己紹介を体験します。聞いて→話して→返答を感じてください。',
    1
  )
  RETURNING id
),
step1 AS (
  INSERT INTO tutorial_steps (tutorial_id, step_order, prompt_text_en, prompt_text_ja, prompt_audio_url)
  SELECT id, 1,
    'Hi! I''m Alex. What''s your name?',
    'こんにちは！アレックスです。お名前は何ですか？',
    NULL
  FROM tut
  RETURNING id
),
step2 AS (
  INSERT INTO tutorial_steps (tutorial_id, step_order, prompt_text_en, prompt_text_ja, prompt_audio_url)
  SELECT tut.id, 2,
    'Nice to meet you! You did great. Ready to learn more?',
    'はじめまして！よくできましたね。もっと学ぶ準備はできていますか？',
    NULL
  FROM tut
  RETURNING id
)
-- Step 1 の返答（NULL= TTSで再生）
INSERT INTO tutorial_step_responses (tutorial_step_id, intent_bucket, response_text_en, response_text_ja, response_audio_url, next_step_id)
SELECT s1.id, 'greeting',
  'Hello! Nice to meet you. Can you tell me your name?',
  'こんにちは！会えて嬉しいです。お名前を教えてくれますか？',
  NULL,
  s1.id
FROM step1 s1
UNION ALL
SELECT s1.id, 'self_intro',
  'Great! Nice to meet you. You did a good job.',
  '素晴らしい！はじめまして。よくできましたね。',
  NULL,
  (SELECT id FROM step2)
FROM step1 s1
UNION ALL
SELECT s1.id, 'unknown',
  'No worries! Try saying "Hello" or "My name is ..."',
  '大丈夫です。Hello や My name is ... と言ってみてください。',
  NULL,
  s1.id
FROM step1 s1;
