-- 3分ストーリー: ビジネスメール（4本目）
-- 使用単語: executive, set, study, prove, hang, entire, rock, forget, claim, note, remove
-- theme_slug: business_email | situation_type: business | theme: ビジネスメール

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '謝罪とフォローアップのメール',
    '納期遅延の謝罪と新しい日程を提案するメールを会話形式で作成する練習。',
    3,
    54
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '謝罪の表現', '丁寧な言い回し', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '理由の説明', '簡潔に', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '新日程の提案', '代替案', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の約束', '締めの言葉', 'business', 'ビジネスメール'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'We have to write an apology. We missed the deadline. The executive will see it. Must be good. How do we start?', '謝罪を書く必要がある。期限を逃した。重役が読む。良くないと。どう始める？' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Subject. Sincerest Apologies. Delivery Delay. Set the tone. Serious. Professional. They will open it. Must read.', '件名。心よりお詫び。配送遅延。トーンをセット。真剣。プロ。開く。読まなくては。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Dear Mr. Jones. We sincerely apologize. The entire team. We take responsibility. Do not forget. Our commitment. We let you down.', 'Dear Mr. Jones。心よりお詫び。チーム全体。責任を負う。忘れないで。私たちのコミットメント。がっかりさせた。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Good. Apology first. Then explain. Study the situation. What happened? Prove we understand. Not making excuses. Factual. Clear.', 'いい。まず謝罪。次に説明。状況を研究。何が起きた？理解を示す。言い訳ではない。事実。明確。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'We claim full responsibility. No blame. Our fault. Entire process. We will fix it. Rock solid promise. They need to trust us again.', '全面的に責任を負う。非難なし。私たちの過ち。全体のプロセス。直す。揺るがない約束。信頼を取り戻す必要。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Body. Brief explanation. Supply chain. Unexpected. We studied it. Entire picture. Not our usual. Exception. Will not forget. Lesson learned.', '本文。簡潔な説明。サプライチェーン。予期せず。研究した。全体像。通常ではない。例外。忘れない。教訓。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Note. We have set new dates. October 15. Guaranteed. Prove our commitment. Executive approved. We will deliver. Rock solid.', '注記。新しい日程をセット。10月15日。保証。コミットメントを証明。重役承認。届ける。揺るがない。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Remove any doubt. In their mind. We are serious. Entire team. Focused. Hang in there. We will fix. Promise. Professional.', '疑いを除く。彼らの心から。真剣。チーム全体。集中。頑張る。直す。約束。プロ。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Add. Compensation? Maybe. Free shipping. Next order. Good will. Prove we care. Entire relationship. Long term. Not just this.', '追加。補償？かも。送料無料。次回注文。善意。気にかけてる証明。関係全体。長期。これだけじゃない。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. Note it. Ten percent discount. Next purchase. Set in stone. Executive decision. We value them. Entire partnership. Rock solid.', 'はい。注記。10パーセント割引。次回購入。確定。重役の決定。大切にしてる。提携全体。揺るがない。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Closing. We apologize again. Entire team. Sincerely. Do not forget. We will improve. Study our process. Remove the issue. Never again.', '結び。再度お詫び。チーム全体。心より。忘れないで。改善する。プロセスを研究。問題を除去。二度としない。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Best regards. Professional. Warm. Sincere. Prove our character. Not just words. Actions. Executive level. We deliver.', 'Best regards。プロ。温かく。誠実。私たちの人格を証明。言葉だけじゃない。行動。重役レベル。届ける。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Send. Check everything. Spell. Dates. Numbers. Entire email. No errors. Hang on. Review. One more time. Executive will see.', '送信。すべて確認。スペル。日付。数字。メール全体。ミスなし。待って。見直し。もう一度。重役が見る。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Good. Apology. Explanation. New dates. Compensation. Promise. Entire package. Rock solid. They will respond. Forgive. Hopefully.', 'いい。謝罪。説明。新日程。補償。約束。全体パッケージ。揺るがない。返信する。許す。願わくば。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'We set the bar. High. Prove ourselves. Entire team. Study. Improve. Remove problems. Never forget. This lesson.', '基準をセット。高く。自分たちを証明。チーム全体。研究。改善。問題を除去。忘れない。この教訓。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Bye. Email sent. Hope for best. Executive review. Client response. We did our part. Professional. Sincere.', 'バイバイ。メール送信。最善を願う。重役レビュー。クライアント返信。私たちの役割は果たした。プロ。誠実。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Note to team. Internal. Study this. What went wrong? Entire process. Remove weak points. Improve. Do not forget.', 'チームへの注記。社内。これを研究。何が悪かった？プロセス全体。弱点を除去。改善。忘れるな。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Rock solid from now. Set standards. High. Prove every day. Entire company. Hang together. We deliver.', 'これから揺るがない。基準をセット。高く。毎日証明。会社全体。一致団結。届ける。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye. Good work. Tough email. But needed. Professional. Entire approach. Correct.', 'バイバイ。良い仕事。辛いメール。でも必要。プロ。アプローチ全体。正しい。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Next. Move forward.', 'バイバイ。次。前進。' FROM conv4;
