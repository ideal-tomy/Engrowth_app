-- 3分ストーリー: ビジネスメール（2本目）
-- 使用単語: knowledge, station, strategy, clearly, discuss, indeed, force, truth, example, check, environment
-- theme_slug: business_email | situation_type: business | theme: ビジネスメール

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '問い合わせへの返信メール',
    '取引先からの問い合わせに丁寧に返信するメールを会話形式で作成する練習。',
    3,
    52
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '返信の件名', 'Re:の確認', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'お礼と確認', '問い合わせへの言及', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '回答の記載', '情報の提供', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '結び', 'さらなる質問へ', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'We got an email. From the client. Questions about our product. Need to respond. What is the strategy? Reply fast?', 'メールが来た。クライアントから。製品についての質問。返信が必要。戦略は？早く返す？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Yes. Fast reply. Good practice. Check the questions. All of them. Do not miss one. Knowledge of our product. Use it. Answer clearly.', 'はい。速い返信。良い習慣。質問を確認。すべて。逃すな。製品の知識。使って。明確に答える。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Re: their subject. Keep it. They will know. Same thread. Easy. The truth is we have the answers. We know. Just need to write clearly.', 'Re: 彼らの件名。そのまま。わかる。同じスレッド。簡単。真実は答えがある。知ってる。書くだけ。明確に。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Indeed. Our knowledge. Product specs. Pricing. Delivery. We have it. Check our database. Station the facts. Organize. Then reply.', 'その通り。私たちの知識。製品仕様。価格。配送。持ってる。データベース確認。事実を配置。整理。返信。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you for your email. Standard opening. Then address each point. One by one. Strategy. Clear. Professional. Force of good communication.', 'Thank you for your email。標準の冒頭。各ポイントに。一つずつ。戦略。明確。プロ。良いコミュニケーションの力。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Point one. Their question. About price. We give example. Product A. Price X. Check our list. Correct. The truth. No guess. Facts.', 'ポイント1。彼らの質問。価格について。例を示す。製品A。価格X。リスト確認。正しい。真実。推測なし。事実。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Point two. Delivery time. Our knowledge. Two weeks. Standard. Express. Five days. Extra cost. State clearly. No confusion.', 'ポイント2。配送時間。私たちの知識。2週間。標準。速達。5日。追加料金。明確に述べる。混乱なし。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Point three. Environment. Eco packaging. They asked. We have it. Green option. Extra ten percent. Check the catalog. Indeed we do. Good to mention.', 'ポイント3。環境。エコ包装。彼らが聞いた。ある。グリーンオプション。10パーセント追加。カタログ確認。確かに。言及する価値。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. Three points. All answered. Strategy. Structured. Easy to read. They will appreciate. Knowledge shared. Force of clarity.', 'いい。3ポイント。すべて回答。戦略。構成。読みやすい。感謝する。知識を共有。明確さの力。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Add. Please let us know. If more questions. We are here. Check with us. Anytime. Professional. Friendly. Truth. We want to help.', '追加。ご質問あれば。こちらに。確認を。いつでも。プロ。フレンドリー。真実。助けたい。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Closing. Best regards. Again. Standard. Check the tone. Formal. But warm. Indeed helpful. Good impression. Last part.', '結び。Best regards。また。標準。トーン確認。フォーマル。でも温かく。確かに親切。良い印象。最後の部分。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Attachment? Brochure? Example products? Maybe. If they asked. Check. Catalog. PDF. Small file. Easy. Knowledge in document.', '添付？パンフ？製品例？かも。彼らが聞いたなら。確認。カタログ。PDF。小さいファイル。簡単。文書の知識。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I will attach. Product list. With prices. Clear. Strategy. Give them everything. No force to ask again. One email. Complete.', '添付する。製品リスト。価格付き。明確。戦略。すべて提供。再度聞く力を要しない。1通で。完全。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. Send. Check before. Spell. Numbers. Names. Truth. Accuracy. Professional. Our station. Our reputation. Important.', 'いい。送信。前に確認。スペル。数字。名前。真実。正確さ。プロ。私たちの立場。評判。重要。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Sending now. Example of good service. Fast. Clear. Complete. Knowledge shared. They will respond. Happy. Indeed.', '今送る。良いサービスの例。速い。明確。完全。知識共有。返信する。嬉しい。確かに。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Bye. Check inbox. Reply. Maybe more questions. Be ready. Strategy. Continue the dialogue. Build relationship.', 'バイバイ。受信箱確認。返信。もっと質問かも。準備。戦略。対話継続。関係構築。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Will do. Our knowledge. Our strength. Clearly shown. In the email. Force of good communication. Truth in service. Professional.', 'そうする。私たちの知識。強み。明確に示した。メールで。良いコミュニケーションの力。サービスでの真実。プロ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Environment mentioned. Good. Many care. Eco. Green. Check that box. Indeed. Modern business. Responsive. Done.', '環境に言及。いい。多くの人が気にする。エコ。グリーン。そのチェック。確かに。現代のビジネス。対応力。完了。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Email sent. Strategy complete. Reply. Clear. Knowledge shared. Check. Done. Good work.', 'メール送信。戦略完了。返信。明確。知識共有。確認。完了。良い仕事。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Next email. Next client. Same approach. Always.', 'バイバイ。次のメール。次のクライアント。同じアプローチ。いつも。' FROM conv4;
