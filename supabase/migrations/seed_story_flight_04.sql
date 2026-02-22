-- 3分ストーリー: 飛行機（4本目）
-- 使用単語: place, single, rule, daughter, administration, south, floor, either, husband, Congress, campaign
-- theme_slug: flight | situation_type: common | theme: 飛行機

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '機内持ち込み荷物の相談',
    '搭乗前の保安検査後、手荷物のサイズについてゲートで確認する会話。',
    3,
    29
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '荷物の確認', 'ゲートでサイズ検査', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'ルールの説明', 'サイズ制限', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '預け荷物の案内', 'ゲートチェック', 'common', '飛行機'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '搭乗準備', '席の案内', 'common', '飛行機'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Excuse me. They said my bag might be too big. The rule for carry-on. I am going south. Long trip. I need my things.', 'すみません。バッグが大きすぎるかもと。機内持込のルール。南へ行きます。長い旅。荷物が必要。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Let me check. The administration rule is fifty-five by forty by twenty. One bag. Plus one personal item. Either a purse or a laptop case.', '確認します。運営のルールは55×40×20。1つ。プラス私物1点。財布かパソコンケースのどちらか。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'I have a laptop and a small bag. My husband has the bigger one. Our daughter has her own. Single bag each. Is that the rule?', 'パソコンと小さなバッグ。夫が大きいのを持ってます。娘も自分のを。各自1つ。それがルール？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Yes. One carry-on per person. Your bag fits. The sizer is over there. Floor level. You can place it and check. South gate is that way. C section.', 'はい。1人1個。あなたのバッグはOK。サイザーがそこ。床の高さ。置いて確認できます。南ゲートはあちら。Cエリア。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. We are going to the Congress. Business trip. The campaign materials are in my husband''s bag. Hope that fits too.', 'ありがとう。コングレスに行きます。出張。キャンペーン資料は夫のバッグに。それも大丈夫だといい。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'If it does not fit we can gate-check. Free. The rule is we return it at arrival. South terminal. Same floor. No extra cost. Part of our service campaign.', '入らなければゲートチェックできます。無料。ルールは到着で返却。南ターミナル。同じ階。追加料金なし。サービスキャンペーンの一部。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Good to know. So we have a place for it either way. Carry-on or gate-check. No stress. The administration thinks of everything.', 'いい情報。どちらにしても場所がある。機内持込かゲートチェック。ストレスなし。運営は全て考えている。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'We try. Your boarding passes. Row fifteen. You have a single row. A, B, C. All together. Window, middle, aisle. Perfect for a family.', '努力しています。搭乗券。15列。1列を確保。A、B、C。一緒。窓、真ん中、通路。家族に完璧。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Perfect. My daughter loves the window. I will take the aisle. Husband in the middle. Long flight south. Need to be comfortable.', '完璧。娘は窓が好き。私は通路。夫は真ん中。南への長いフライト。快適に。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Boarding starts in twenty minutes. Gate C12. This floor. South end. You will hear the call. Group three. Enjoy the Congress.', '20分後に搭乗開始。C12ゲート。この階。南端。アナウンスが聞こえます。グループ3。コングレスを楽しんで。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Group three. Got it. So we wait here. On this floor. South side. The rule is we board by group. Right?', 'グループ3。わかりました。ここで待つ。この階。南側。グループで搭乗がルール？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Group one first. Then two. Then three. Your place is in group three. Relax. Plenty of time. The administration runs a smooth operation.', 'はい。グループ1が最初。次に2。3。あなたはグループ3。リラックス。時間は十分。運営はスムーズ。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Thank you. One last thing. Is there a place to charge phones? My daughter''s is dead. Either here or on the plane?', 'ありがとう。最後に。充電スポットは？娘の携帯が切れた。ここか機内で？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Right there. Against the wall. Floor level. USB ports. Free. Part of our customer campaign. South gate area has several.', 'あそこ。壁沿い。床の高さ。USBポート。無料。顧客キャンペーンの一部。南ゲートエリアにいくつか。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Perfect. Thank you. We are all set. See you on board.', '完璧。ありがとう。準備完了。機内で。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'See you. Enjoy the flight.', 'お会いしましょう。フライトを楽しんで。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. Goodbye.', 'ありがとう。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye.', 'さようなら。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Bye.', 'バイバイ。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
