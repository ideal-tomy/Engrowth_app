-- 3分ストーリー: ホテル（3本目）
-- 使用単語: blood, upon, agency, push, nature, color, no, recently, store, reduce, sound, note
-- theme_slug: hotel | situation_type: common | theme: ホテル

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'チェックアウトと領収書',
    'ホテルでチェックアウトし、領収書を請求する会話。',
    3,
    33
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'チェックアウト開始', 'フロントで精算', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '明細の確認', 'ミニバーと追加料金', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '領収書の依頼', '会社名の記載', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, 'お別れ', 'タクシーの手配', 'common', 'ホテル'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I would like to check out. Room 712. Name is Kimura. I need to leave soon. My agency car is at ten.', 'こんにちは。チェックアウトをお願いします。712号室。木村です。もう出る必要があります。旅行会社の車が10時。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Good morning. Let me pull your bill. Room 712. Two nights. I note you used the mini bar. Blood orange juice. Water. Nothing else. Sound right?', 'おはようございます。請求書を表示します。712号室。2泊。ミニバーをご利用。ブラッドオレンジジュース。水。他なし。合ってますか？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. That is correct. The juice was good. I had it upon arrival. Long flight. Needed something fresh. The color was beautiful. Deep red.', 'はい。その通り。ジュースは美味しかった。到着時に飲んだ。長いフライト。フレッシュなものが要った。色が綺麗だった。深い赤。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We recently switched suppliers. Better quality. The total is three hundred twenty. Can we reduce it? We have a loyalty discount. Ten percent. Push this button to join.', '最近供給元を変更。質が向上。合計320です。割引できます。ロイヤリティ割引。10%。このボタンを押して加入。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'No need. I am on business. Company pays. But thank you. The nature of the offer is kind. I will note it for my next trip. Personal stay.', '大丈夫。出張。会社が払う。でもありがとう。オファーの性質は親切。次の旅行用にメモする。個人で泊まる時。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'Understood. So three twenty. Charge to the card on file? The agency booking. Same card we have.', '承知。320。登録のカードに？旅行会社の予約。同じカード。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Yes. Please. And I need a receipt. For the company. Can you note the company name? ABC Corp. Tax ID on the receipt. For our records.', 'はい。お願いします。領収書が要る。会社用。会社名をメモできる？ABC Corp。領収書に税ID。記録用。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'No problem. I will add the company details. Upon completion I will push a copy to your email. We recently added that. Paperless option. Or paper. Your choice.', '問題ない。会社情報を追加。完了したらメールにコピーを送信。最近追加。ペーパーレスオプション。または紙。お選びください。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Paper please. Old school. I like to store receipts. File them. The agency prefers paper. Reduces issues. No lost emails.', '紙で。昔ながら。領収書を保管。ファイリング。旅行会社は紙を好む。問題を減らす。メール紛失なし。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Paper it is. One moment. I will print it. The receipt will show room charge. Mini bar. No other fees. Clean bill. Sound good?', '紙で。少々。印刷します。領収書には部屋代、ミニバー。他費用なし。クリーンな請求。いいですか？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Perfect. Thank you. One more thing. Can you call a taxi? To the airport. The agency said you have a taxi stand. Or should I push the bell outside?', '完璧。ありがとう。もう一つ。タクシーを呼べますか？空港へ。旅行会社がタクシー乗り場があると言ってた。外でベルを押すべき？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'No need to push anything. I will call now. Taxi in five minutes. The store by the lobby has drinks. While you wait. Blood orange. Water. For the road.', '押す必要なし。今呼ぶ。5分でタクシー。ロビー横のストアに飲み物。待ち時間に。ブラッドオレンジ。水。道中用。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Good idea. I will grab something. So receipt. Taxi in five. I am all set. The stay was lovely. The room color. Blue. Very calm. Nature feel.', 'いい考え。何か買う。領収書。5分でタクシー。準備完了。滞在は素敵だった。部屋の色。ブルー。とても落ち着く。自然な感じ。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Thank you. We aim for that. Calm. Restful. Upon your next visit we will have new rooms. Different colors. Green. Nature theme. Recently planned.', 'ありがとう。目指している。落ち着き。休息。次回は新ルーム。違う色。グリーン。自然テーマ。最近計画。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I will note that. Looking forward to it. Thank you for everything. Goodbye.', 'メモする。楽しみ。全てありがとう。さようなら。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Goodbye. Safe travels. The taxi will be at the door. Your receipt is ready. Here you go.', 'さようなら。良い旅を。タクシーは扉に。領収書の用意ができた。どうぞ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Bye.', 'ありがとう。バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thanks again.', 'もう一度ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'You are welcome.', 'どういたしまして。' FROM conv4;
