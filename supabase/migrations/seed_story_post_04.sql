-- 3分ストーリー: 郵便局・宅急便（4本目）
-- 使用単語: structure, politics, perform, production
-- theme_slug: post | situation_type: student | theme: 郵便局・宅急便

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '郵便局で切手を買う',
    '海外に手紙を送るために切手を購入し、料金を確認する会話。',
    3,
    74
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '窓口で', '切手の種類', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '料金の確認', '宛先による違い', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '購入', '枚数の指定', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '貼り方', 'お礼', 'student', '郵便局・宅急便'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I need some stamps. I want to send a letter to Japan. The structure of the post office here is different from my country. Where do I go?', 'こんにちは。切手が必要です。日本に手紙を送りたい。ここの郵便局の構造は母国と違います。どこへ行けば？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'This counter. We handle international mail. The structure is simple. Domestic on the left. International here. The politics of postal rates are the same everywhere. We perform the same service.', 'この窓口。国際郵便を扱っています。構造はシンプル。左が国内。ここが国際。郵便料金の仕組みはどこも同じ。同じサービスを提供。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Good. So for Japan. What is the rate? I am a student. On a budget. Is there a cheap option? I need to perform this task. Send letters home. Monthly production of mail.', 'いいですね。日本用は？料金は？学生で。予算が厳しい。安いオプションは？この作業を遂行する必要が。家に手紙を。月々の郵便。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'One dollar twenty per stamp. For a standard letter. The politics of international rates. Set by treaty. We perform worldwide. Production is consistent. Japan is the same rate.', '1ドル20セント1枚。標準的な手紙用。国際料金の仕組み。条約で設定。世界各国で同じ。一貫した運用。日本も同じ料金。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'One twenty. Clear. The structure makes sense. I will take five stamps. For letters to my parents and friends. Production of about five letters per month.', '1ドル20セント。明確。構造は理解できる。5枚いただきます。両親と友達への手紙用。月に5通くらい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Five stamps. That is six dollars total. The structure of payment. Card or cash. We perform both. Receipt for your records. Here you go.', '5枚。合計6ドル。支払いの方法。カードか現金。どちらもOK。記録用の領収書。どうぞ。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Thank you. One more question. Where do I put the stamp? On the envelope? The structure. Top right corner? I want to perform it correctly. Standard practice?', 'ありがとう。もう一つ。切手はどこに貼る？封筒に？構造。右上？正しくやりたい。標準のやり方？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Top right. Yes. The structure is standard. Politics of mail. Universal. Same the world over. We perform the same way everywhere. Easy habit to learn.', '右上。はい。構造は標準。郵便の仕組み。世界的。どこでも同じ。どこでも同じやり方。覚えやすい習慣。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Thank you. This is helpful. The structure is clear. My first letter from abroad. I am nervous. But ready to perform. Production of my first international mail.', 'ありがとう。役立つ。構造は明確。海外からの初めての手紙。緊張してる。でも遂行する準備。初の国際郵便。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'You are welcome. The structure of mail is simple. Global. We perform well. Love connects people. Letters to Japan. Good luck.', 'どういたしまして。郵便の構造はシンプル。グローバル。良いサービスを。愛が人をつなぐ。日本への手紙。頑張って。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Thank you. Your help with the structure was great. Patient. You perform excellent service. Production of a good experience. Have a good day.', 'ありがとう。構造の説明が素晴らしかった。忍耐強く。卓越したサービスを提供。良い体験。よい一日を。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Thank you. Mail connects the world. Politics aside. We perform to connect people. Production of joy. When letters arrive. Good luck.', 'ありがとう。郵便は世界をつなぐ。政治はさておき。人をつなぐサービス。喜びを生む。手紙が届く時。頑張って。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I understand the structure now. The politics of post. Clear. I will perform the task. Production of letters. Complete. Thank you.', '構造がわかった。郵便の仕組み。明確。任務を遂行する。手紙の作成。完了。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. I hope your letters arrive. Structure of delivery. Worldwide. We perform our best. Production of happiness. For the recipients. Goodbye.', 'いいですね。手紙が届くといい。配達の構造。世界中。ベストを尽くす。幸せを生む。受取人のために。さようなら。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Goodbye. Your help with the structure. I am grateful. I will perform better next time. Production of more letters. Thank you.', 'さようなら。構造の助け。感謝してる。次はもっと上手に遂行する。もっと手紙を。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Take care. The structure of mail. Simple. We perform our task. Production done. Have a good day.', 'さようなら。お気をつけて。郵便の構造。シンプル。任務を遂行。完了。よい一日を。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Good day. The structure was clear. Helpful. You perform well. Quality production. Goodbye.', 'よい一日を。構造は明確だった。有益。上手にやってくれた。質の高い対応。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Our service. We always perform our best. Production. Customer first. Thank you.', 'さようなら。私たちのサービス。いつもベストを尽くす。運営。お客様第一。ありがとう。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. Task complete. I am satisfied. I performed my goal. Got my stamps. Good.', 'さようなら。タスク完了。満足。目標を達成。切手を手に入れた。いい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good luck with your letters.', 'さようなら。手紙頑張って。' FROM conv4;
