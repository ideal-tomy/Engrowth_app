-- 3分ストーリー: ビジネスメール（1本目）
-- 使用単語: operation, financial, crime, stage, ok, compare, authority, miss, design, sort, station, strategy
-- theme_slug: business_email | situation_type: business | theme: ビジネスメール

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'アポイントメント依頼のメール',
    '海外の取引先にミーティングの日程調整を依頼するメールを会話形式で作成する練習。',
    3,
    51
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '件名と挨拶', 'メールの冒頭', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '本文の依頼', '日程の提案', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '詳細の説明', '会議の目的', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '締めと言葉', '結びの表現', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'So we need to write an email. Meeting request. To our partner in London. What should the subject line be? First stage of the email.', 'メールを書く必要がある。会議依頼。ロンドンのパートナーへ。件名は？メールの第一段階。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Good subject. Clear. Something like. Meeting Request. Q2 Financial Review. That sort of thing. They will not miss it. Inbox. Lots of emails.', '良い件名。明確。会議依頼。Q2財務レビュー。そんな感じ。逃さない。受信箱。メール多い。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Ok. Meeting Request. Q2 Financial Review. Now the greeting. Dear Mr. Smith? Or first name? Compare to our culture. More formal here?', 'OK。会議依頼。Q2財務レビュー。挨拶。Dear Mr. Smith？名前？私たちの文化と比較。ここはもっとフォーマル？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Mr. Smith. First meeting. Authority. Formal. British. They like it. Design of the email. Professional. Build trust. Financial partnership. Serious.', 'Mr. Smith。初会議。権威。フォーマル。英国人。好き。メールのデザイン。プロフェッショナル。信頼構築。財務提携。真剣。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Dear Mr. Smith. Good. Operation of the email. Step by step. Subject. Greeting. Now body. The main part. Our strategy.', 'Dear Mr. Smith。いい。メールの運用。段階的に。件名。挨拶。次本文。メイン部分。戦略。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Body. We want to meet. Discuss the financial report. Q2 results. Compare to Q1. Better. Growth. Good numbers. Request a meeting. Next week. Their office. Or ours.', '本文。会いたい。財務レポート議論。Q2結果。Q1と比較。良くなった。成長。良い数字。会議依頼。来週。彼らのオフィス。または私たちの。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I will propose three dates. Tuesday. Wednesday. Thursday. Morning. 10 AM. Their time. Do not want to miss their schedule. Different zone. Check carefully.', '3つの日付を提案。火曜。水曜。木曜。午前。10時AM。彼らの時間。スケジュールを逃したくない。別タイムゾーン。慎重に確認。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Good. The authority of the request. Professional. Clear. No crime against etiquette. Proper business. Design the message. Concise. To the point. Strategy. Get the meeting.', 'いい。依頼の権威。プロ。明確。エチケット違反なし。適切なビジネス。メッセージをデザイン。簡潔。要点。戦略。会議を得る。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'What about the agenda? Should we list topics? Sort of helpful. They know. What to prepare. Operation of the meeting. Efficient. Save time.', 'アジェンダは？トピックをリスト？わりと helpful。わかる。何を準備するか。会議の運用。効率的。時間節約。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Brief agenda. Financial review. Q2. Compare results. Strategy for Q3. Next stage. Partnership. Authority approval. Three points. Clear. They will respond. Ok.', 'はい。簡潔なアジェンダ。財務レビュー。Q2。結果を比較。Q3の戦略。次段階。提携。当局承認。3点。明確。返信する。OK。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Closing. Best regards? Sincerely? Compare options. Formal. Professional. British style. What do they prefer?', '結び。Best regards？Sincerely？オプションを比較。フォーマル。プロ。英国スタイル。何を好む？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Best regards. Common. Ok. Not too formal. Not too casual. Sort of middle. Authority. But friendly. Design. Good impression. Last stage. Sign off.', 'Best regards。一般的。OK。フォーマルすぎず。カジュアルすぎず。わりと中間。権威。でも親しみやすい。デザイン。良い印象。最終段階。サインオフ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'We should add. Please let us know. By Friday. So we do not miss the deadline. Operation. Their response. We need it. To plan. Next stage.', '追加すべき。金曜までにご連絡を。締め切りを逃さない。運用。彼らの返信。必要。計画するために。次段階。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. Strategy complete. Email. Request. Clear. Professional. Financial focus. Authority. They will reply. Ok. Meeting set. Stage one. Email. Stage two. Meeting. Stage three. Deal.', 'いい。戦略完了。メール。依頼。明確。プロ。財務焦点。権威。返信する。OK。会議設定。段階1。メール。段階2。会議。段階3。契約。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'One more thing. Attachment? The report? Or send later? Compare. In email. Long. Or link. Cleaner. Their preference?', 'もう一つ。添付？レポート？後で送る？比較。メールに。長い。またはリンク。すっきり。彼らの好み？' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Mention it. Report attached. Or available on request. Sort of flexible. No crime. If too big. Link is ok. Design. Easy for them. Authority. Professional.', '言及。レポート添付。またはリクエストで。わりと柔軟。問題なし。大きすぎるなら。リンクでOK。デザイン。彼らに簡単。権威。プロ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Got it. Email done. Subject. Greeting. Body. Agenda. Closing. Attachment note. Strategy. Operation. All stages. Ready to send.', '了解。メール完成。件名。挨拶。本文。アジェンダ。結び。添付の注記。戦略。運用。全段階。送信準備。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Send it. Do not miss the chance. Friday deadline. They are busy. Financial people. Quick response. Good. Our design. Professional. They will agree. Ok.', '送って。機会を逃すな。金曜締め切り。忙しい。財務関係者。速い返信。いい。私たちのデザイン。プロ。同意する。OK。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Sending now. Compare to phone. Email. Record. Proof. Better. Authority. Written. Clear. Strategy worked.', '今送る。電話と比較。メール。記録。証拠。 better。権威。書面。明確。戦略は機能した。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Good. Bye. Check inbox. Reply. Soon. Meeting. Stage two. Next.', 'いい。バイバイ。受信箱チェック。返信。すぐ。会議。段階2。次。' FROM conv4;
