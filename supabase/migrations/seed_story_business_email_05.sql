-- 3分ストーリー: ビジネスメール（5本目）
-- 使用単語: help, close, sound, enjoy, network, legal, form, final, main, apply
-- theme_slug: business_email | situation_type: business | theme: ビジネスメール

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '紹介の依頼メール',
    '共通の知人に紹介を依頼するメールを会話形式で作成する練習。',
    3,
    55
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '依頼の前置き', '関係の説明', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '具体的な依頼', '紹介してほしい相手', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, 'お礼の表明', '感謝の表現', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '締めくくり', '結びの挨拶', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'We need to ask for an introduction. Through our network. A contact. Knows someone. We want to meet. Legal department. Big company. How to ask?', '紹介を依頼する必要。ネットワーク経由。連絡先。誰か知ってる。会いたい。法務部。大会社。どう頼む？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Subject. Introduction Request. Clear. Professional. They will help. If we ask right. Sound polite. Sincere. Not pushy. Main goal. Get the meeting.', '件名。紹介依頼。明確。プロ。助けてくれる。正しく頼めば。丁寧に聞こえる。誠実。押し付けがましくない。主な目標。会議を得る。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Dear Sarah. We met at the conference. Enjoy the chat. Our network. You mentioned. Connection. Legal team. Johnson Corp. Could you help?', 'Dear Sarah。カンファレンスで会った。チャット楽しんだ。ネットワーク。言ってた。つながり。法務チーム。ジョンソン社。助けてもらえる？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. Remind her. Connection. Form of request. Gentle. Not demand. Ask. Please. If possible. Help us. Bridge. Introduction.', 'いい。思い出させる。つながり。依頼の形式。優しく。要求じゃない。頼む。お願い。可能なら。助けて。橋渡し。紹介。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We are applying. For partnership. Johnson. Legal review. Need contact. Main person. Decision maker. Your introduction. Would help. A lot.', 'パートナーシップに応募中。ジョンソン。法務レビュー。連絡先が必要。主な人。意思決定者。あなたの紹介。助かる。とても。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Body. Brief. Our background. Why we want. Legal expertise. Match. Johnson needs. We provide. Form the partnership. Mutual benefit.', '本文。簡潔。私たちの背景。なぜ欲しいか。法務の専門性。マッチ。ジョンソンが求める。私たちが提供。提携を形成。相互利益。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'We will not waste their time. Main points. Ready. One meeting. Thirty minutes. That is all. Sound professional. Prepared. Serious.', '時間を無駄にしない。主なポイント。準備済み。1回の会議。30分。それだけ。プロに聞こえる。準備済み。真剣。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Close the request. Gentle. Your help. Would mean a lot. Our network. Grows. With your support. Enjoy working. With good partners. Like Johnson.', '依頼を締める。優しく。あなたの助け。とても意味がある。私たちのネットワーク。成長。あなたのサポートで。良いパートナーと働くのを楽しむ。ジョンソンのように。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Legal side. We are compliant. All forms. Ready. Main documents. Attached. If they want. Apply. Form. Complete. Professional.', '法務面。準拠。全書式。準備済み。主な書類。添付。欲しければ。申請。書式。完了。プロ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Final part. Thank you. In advance. Your time. Your help. Network matters. We appreciate. Close with warmth. Professional. But human.', '最後の部分。ありがとう。前もって。あなたの時間。あなたの助け。ネットワークは大事。感謝。温かく締める。プロ。でも人間的。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Best regards. Standard. Sound right. Legal. Professional. Form of closure. Proper. Executive level. Appropriate.', 'Best regards。標準。正しく聞こえる。法務。プロ。結びの形式。適切。重役レベル。ふさわしい。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We hope. She helps. Introduction. Main goal. Meeting. Johnson. Legal. Partnership. Apply. Form. Success.', '望む。彼女が助けてくれる。紹介。主な目標。会議。ジョンソン。法務。提携。申請。形式。成功。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Send. Check. Network contact. Right email. Form correct. Final check. No errors. Help our cause. This email.', '送信。確認。ネットワーク連絡先。正しいメール。形式正しい。最終確認。ミスなし。大義を助ける。このメール。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. Main message. Clear. Help. Introduction. Network. Professional. Sound. Right. She will respond. Enjoy. Good relationship.', 'いい。主なメッセージ。明確。助け。紹介。ネットワーク。プロ。聞こえ。正しい。返信する。楽しむ。良い関係。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Final step. Follow up. If no reply. One week. Gentle. Reminder. Network etiquette. Not pushy. Professional. Help. Not demand.', '最終ステップ。フォローアップ。返信ないなら。1週間。優しく。リマインド。ネットワークのエチケット。押し付けがましくない。プロ。助け。要求じゃない。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Bye. Email sent. Hope. Help comes. Introduction. Main goal. Network. Grow. Partnership. Legal. Johnson. Success.', 'バイバイ。メール送信。望む。助けが来る。紹介。主な目標。ネットワーク。成長。提携。法務。ジョンソン。成功。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'We did our part. Professional. Form. Correct. Sound. Right. Close the loop. Wait. Response. Enjoy. Hope.', '私たちの役割は果たした。プロ。形式。正しい。聞こえ。正しい。ループを閉じる。待つ。返信。楽しむ。希望。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye. Next. Other contacts. Network. Apply. Same approach. Main strategy. Grow. Connections.', 'バイバイ。次。他の連絡先。ネットワーク。適用。同じアプローチ。主な戦略。成長。つながり。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Good work. Email. Professional. Legal. Form. Final. Main points. Clear. Help. Requested. Done.', '良い仕事。メール。プロ。法務。形式。最終。主なポイント。明確。助け。依頼。完了。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Take care.', 'バイバイ。お気をつけて。' FROM conv4;
