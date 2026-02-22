-- 3分ストーリー: カフェ&レストラン（5本目）
-- 使用単語: serious, occur, media, ready, sign, thought, list, individual, simple, quality, pressure, accept
-- theme_slug: cafe | situation_type: common | theme: カフェ&レストラン

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'アレルギー対応の確認',
    'レストランでアレルギーを伝え、安全な料理を確認する会話。',
    3,
    40
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'アレルギーの伝達', '食材を確認', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'メニューの適合', '安全な選択肢', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '調理法の確認', 'キッチンへの伝達', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '安心とお礼', '注文の確定', 'common', 'カフェ&レストラン'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. Before we order. I have a serious allergy. Gluten. I need to be careful. Can the kitchen accommodate? It is important. No pressure. But I must avoid gluten.', 'すみません。注文の前に。深刻なアレルギーがあります。グルテン。気をつけなければ。キッチンは対応できる？重要。プレッシャーなしで。でもグルテンは避けなければ。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Of course. We take allergies seriously. Quality and safety. Same level. I will check our list. We have gluten-free options. Individual preparation. Separate from other dishes.', 'もちろん。アレルギーを真剣に。品質と安全。同じレベル。リストを確認。グルテンフリーあり。個別調理。他料理と分離。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Thank you. I thought I should say first. Allergies can occur quickly. Better safe. The media reports. Restaurant incidents. I read about it. Scary.', 'ありがとう。最初に言うべきと思った。アレルギーは速く起こりうる。安全第一。メディアの報告。レストランの事故。読んだ。怖い。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We understand. Our chef is trained. Sign off on every allergy order. Simple rule. We accept the responsibility. No shortcuts. Quality control. Pressure to get it right.', 'わかります。シェフは訓練済み。全てのアレルギー注文にサインオフ。シンプルなルール。責任を受け入れる。手抜きなし。品質管理。正確さへのプレッシャー。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Good to hear. So what can I have? From the list. Gluten-free. I want something simple. Good quality. No risk.', '聞けてよかった。何が食べられる？リストから。グルテンフリー。シンプルなものがいい。良い品質。リスクなし。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'The grilled fish. No bread. No sauce with gluten. Rice instead of pasta. Individual portion. We prepare it separate. Kitchen is ready. They do this often.', 'グリル魚。パンなし。グルテンのソースなし。パスタの代わりに米。一人前。別に調理。キッチンは準備OK。よくやってる。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Grilled fish. Rice. Simple. I accept that. What about the salad? Dressings? Sometimes gluten occurs in dressing. Hidden. Need to ask.', 'グリル魚。米。シンプル。受け入れる。サラダは？ドレッシング？ドレッシングにグルテンが起こることが。隠れて。聞く必要。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good question. Our house dressing. Gluten-free. Olive oil. Lemon. Simple. Quality ingredients. No wheat. I will double-check. Sign from the chef. Guaranteed.', '良い質問。ハウスドレッシング。グルテンフリー。オリーブオイル。レモン。シンプル。品質の食材。小麦なし。再確認する。シェフのサイン。保証。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Perfect. So grilled fish. Salad with house dressing. Rice. All gluten-free. The thought of safe food. Relaxes me. No pressure on my stomach. Or my mind.', '完璧。グリル魚。ハウスドレッシングのサラダ。米。全てグルテンフリー。安全な食事の考え。リラックス。胃へのプレッシャーなし。心にも。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'We want you relaxed. Enjoy the meal. I will inform the kitchen. Allergy order. Gluten-free. Serious. They will note it. Individual ticket. No cross-contact.', 'リラックスしてほしい。食事を楽しんで。キッチンに伝える。アレルギー注文。グルテンフリー。深刻。メモする。個別チケット。クロスコンタクトなし。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. I appreciate the care. Not all places accept allergy requests. Or take them seriously. Quality of service. I can tell.', 'ありがとう。気遣いに感謝。全ての店がアレルギーリクエストを受け入れるわけじゃない。真剣に取るわけでも。サービスの品質。わかる。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'It is standard for us. Every order. Every guest. Individual needs. We accommodate. The sign on the door. Allergy friendly. We mean it.', '私たちの標準。全ての注文。全てのゲスト。個々のニーズ。対応する。ドアの看板。アレルギー対応。本気。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I saw the sign. That is why I came. Good to know it is true. Not just media hype. Real quality. Real care. Ready to eat. Without worry.', '看板を見た。だから来た。本当だとわかってよかった。メディアの誇張じゃなく。本物の品質。本物の気遣い。心配なく食べる準備。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Your order is in. Grilled fish. Salad. Rice. All gluten-free. Fifteen minutes. I will bring it myself. Double-check the ticket. No errors occur. We promise.', '注文入った。グリル魚。サラダ。米。全てグルテンフリー。15分。自分でお持ちする。チケット再確認。エラーは起こらない。約束。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. I feel safe. The list of concerns. Shorter now. Good food. No allergy risk. Perfect combination.', 'ありがとう。安全に感じる。心配のリスト。短くなった。良い食事。アレルギーリスクなし。完璧な組み合わせ。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Enjoy. I will be back with your meal. Goodbye for now.', '楽しんで。食事をお持ちして戻る。一旦さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. Thank you.', 'さようなら。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome.', 'どういたしまして。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
