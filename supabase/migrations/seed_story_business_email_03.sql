-- 3分ストーリー: ビジネスメール（3本目）
-- 使用単語: song, example, democratic, check, environment, leg, dark, public, various, rather, laugh, guess
-- theme_slug: business_email | situation_type: business | theme: ビジネスメール

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '情報提供のメール',
    '新しいプロジェクトの情報を関係者に共有するメールを会話形式で作成する練習。',
    3,
    53
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '共有の目的', '誰に何を', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '本文の構成', '情報の整理', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '添付ファイル', '資料の説明', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '行動の依頼', '確認を求める', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'We need to send an update. Project status. To various teams. Public information. Internal. Who gets it?', 'アップデートを送る必要。プロジェクト状況。様々なチームへ。公開情報。社内。誰が受け取る？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Marketing. Sales. Design. Various departments. Same email. One message. Democratic. All get it. No dark secrets. Transparent. Good.', 'マーケティング。営業。デザイン。様々な部署。同じメール。1通。民主的。全員が受け取る。闇の秘密なし。透明。いい。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Subject. Project Update. Q3. Clear. They will check it. Open it. Not like a song. Boring. Important. Business. Serious.', '件名。プロジェクトアップデート。Q3。明確。チェックする。開く。歌みたいに退屈じゃない。重要。ビジネス。真剣。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Right. No guess work. Facts. Status. Timeline. Environment report. Sustainability. Leg of the project. Where we stand.', 'そう。推測なし。事実。状況。タイムライン。環境レポート。持続可能性。プロジェクトの脚。現状。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Greeting. Team. Or everyone. Various ways. Rather formal. Internal. But friendly. Check the tone. Public message. All eyes.', '挨拶。チーム。または皆へ。様々な方法。むしろフォーマル。社内。でも親しみやすい。トーン確認。公開メッセージ。全員の目。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Body. Three sections. Progress. Example. We completed phase one. Timeline met. Good. Challenges. Rather small. Dark moment? No. On track.', '本文。3セクション。進捗。例。フェーズ1完了。タイムライン達成。いい。課題。むしろ小さい。暗い瞬間？なし。順調。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Section two. Next steps. Various tasks. Design team. Marketing. Sales. Each. Leg of work. Clear. Who does what.', 'セクション2。次のステップ。様々なタスク。デザインチーム。マーケティング。営業。それぞれ。仕事の脚。明確。誰が何を。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Section three. Environment. Our commitment. Sustainability. Public promise. Democratic. Everyone involved. Green goals. Check the numbers.', 'セクション3。環境。私たちのコミットメント。持続可能性。公約。民主的。全員関与。グリーン目標。数字を確認。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. No dark corners. All clear. Rather open. Transparent. Public. They will appreciate. No guess. Facts. Example. Data.', 'いい。暗い隅なし。すべて明確。むしろオープン。透明。公開。感謝する。推測なし。事実。例。データ。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Add. Questions? Reply. We are here. Democratic process. Everyone can ask. Laugh if we mess up. Learn. Improve. Open culture.', '追加。質問？返信。こちらに。民主的プロセス。誰でも聞ける。失敗したら笑おう。学ぶ。改善。オープン文化。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Attachment. Report. PDF. Big file? Check size. Various formats. Maybe summary. Short. Main points. Leg of detail. In attachment.', '添付。レポート。PDF。大きい？サイズ確認。様々な形式。サマリーかも。短く。要点。詳細の脚。添付に。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Two attachments. Summary. One page. Quick check. Full report. For those who want. Rather complete. Public record. Democratic. All get same.', '添付2つ。サマリー。1ページ。素早く確認。完全レポート。欲しい人用。むしろ完全。公開記録。民主的。全員同じ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Example in report. Charts. Graphs. Environment data. Clear. No dark areas. Transparent. Check the figures. Accurate.', 'レポートの例。チャート。グラフ。環境データ。明確。暗い領域なし。透明。数字を確認。正確。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Closing. Please review. By Friday. Check. Confirm. Reply. Rather quick. Keep moving. Public timeline. We share. Democratic.', '結び。金曜までにご確認を。チェック。確認。返信。むしろ速く。前進。公開タイムライン。共有。民主的。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Best regards. Standard. No song and dance. Professional. Straight. Leg of communication. Clear. Done.', 'Best regards。標準。大げさなし。プロ。ストレート。コミュニケーションの脚。明確。完了。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Send. To various lists. All teams. Public distribution. Check recipients. Right people. No guess. Accurate. Democratic. Fair.', '送信。様々なリストへ。全チーム。公開配布。受信者確認。適切な人。推測なし。正確。民主的。公平。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Sending. Environment update. Important. Various stakeholders. Public message. Transparent. No dark secrets. They will appreciate.', '送信中。環境アップデート。重要。様々なステークホルダー。公開メッセージ。透明。闇の秘密なし。感謝する。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good. Example of good communication. Rather clear. Check. Confirm. Reply. Keep the leg of project strong. Moving forward.', 'いい。良いコミュニケーションの例。むしろ明確。確認。確認。返信。プロジェクトの脚を強く。前進。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Next update. Next week. Same process. Various teams. Public. Democratic. Transparent. Always.', 'バイバイ。次のアップデート。来週。同じプロセス。様々なチーム。公開。民主的。透明。いつも。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Good work. No song needed. Facts. Clear. Done.', 'バイバイ。良い仕事。歌は不要。事実。明確。完了。' FROM conv4;
