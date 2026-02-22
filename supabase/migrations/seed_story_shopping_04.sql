-- 3分ストーリー: ショッピング（4本目）
-- 使用単語: analysis, benefit, sex, forward, lawyer, present, section, environmental, skill, sister, PM, professor
-- theme_slug: shopping | situation_type: common | theme: ショッピング

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '靴店でのサイズ合わせ',
    '靴店で正しいサイズを探し、店員に履き心地を相談して購入する会話。',
    3,
    44
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '靴を探す', '目的を伝える', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '試着', 'サイズの確認', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '決める', '環境素材かどうか', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '会計', '支払い完了', 'common', 'ショッピング'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hi. I need shoes. Walking shoes. For a trip. My sister recommended this store. She is a professor. Good taste.', 'こんにちは。靴が必要。ウォーキングシューズ。旅行用。妹がこの店を勧めた。教授です。センスがいい。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. The walking section is forward. Left. We have many styles. What benefit do you need? Comfort? Support? Style?', 'ようこそ。ウォーキングセクションは前方。左。スタイル多数。どんなメリットが？快適さ？サポート？スタイル？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Comfort first. I have meetings. With a lawyer. Long day. 9 AM to 6 PM. Need to stand. Good skill in design. Important.', '快適さ優先。会議がある。弁護士と。長い一日。9時AMから6時PM。立ちっぱなし。デザインの腕。重要。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We have ergonomic designs. Our analysis says best for professionals. Lawyers. Professors. People who stand. Environmental materials too.', '人間工学的デザイン。分析でプロに最適。弁護士。教授。立ちっぱなしの人。環境素材も。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Environmental. Good. My sister cares. Present for myself. Treat. What size? I am 42. European. Not sure US.', '環境。いい。妹は気にする。自分へのプレゼント。ご褒美。サイズは？42。ヨーロッパ。USはわからない。' FROM conv1
UNION ALL SELECT id, 'B', 1, 'US 9. Men or women? We have both. Unisex section too. Any sex can wear. Very popular. Let me get you a few pairs.', 'US9。メンズ？レディース？両方ある。ユニセックスもある。性別問わず。人気。数足持ってくる。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Men. Size 9. These black ones. Can I try? The skill of the sole. I need grip. Rain. City walking.', 'メンズ。9。この黒いの。試していい？ソールの腕。グリップが必要。雨。街歩き。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Of course. Sit here. Forward a bit. How does it feel? The benefit of our brand. Cushion. Arch support. Long day ready.', 'もちろん。ここに座って。少し前へ。感じは？当店の利点。クッション。アーチサポート。長い一日対応。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Good. Nice fit. The analysis of my foot. Spot on. My sister was right. This store. Good skill. I will take them.', 'いい。よく合う。足の分析。ぴったり。妹の言う通り。この店。腕がいい。いただきます。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Great choice. One pair? Or two? We have a sale. Two for the price of one fifty. Present for your sister? Same size?', '良い選択。1足？2足？セール中。2足で150。お妹様用プレゼント？同じサイズ？' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Just one. For me. My sister has her own. She bought here last month. Professor discount? She said something.', '1足。自分用。妹は持ってる。先月ここで買った。教授割引？何か言ってた。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Yes. Academic discount. Ten percent. Students. Professors. Teachers. Show ID. Are you academic?', 'はい。学術割引。10パーセント。学生。教授。教師。ID提示。学術関係？' FROM conv3
UNION ALL SELECT id, 'A', 3, 'No. I am a lawyer. Different field. But my sister is professor. Environmental studies. She loves this place.', 'いいえ。弁護士。別分野。でも妹は教授。環境学。この店が大好き。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We have many environmental customers. Our section for eco products. Forward. Growing. Analysis shows demand. Good for the planet. Benefit for all.', '環境志向のお客様多数。エコ商品セクション。前方。成長中。分析で需要。地球に優しい。みんなのメリット。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I agree. One pair. Black. Size 9. For my 2 PM meeting. Lawyer client. Need to look sharp. And walk well.', '同感。1足。黒。9。2時PMの会議用。弁護士クライアント。きっちり見える必要。歩きやすく。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Eighty dollars. Card or cash? We will pack them. Box. Ready to wear. Forward to success. Your meeting.', '80ドル。カードか現金？梱包する。箱。すぐ履ける。会議の成功へ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Card. Thanks. The skill here is real. My sister knows. Professor level service. I will tell her. She will be happy.', 'カード。ありがとう。ここの腕は本物。妹は知ってる。教授レベルサービス。伝える。喜ぶ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Thank you. Enjoy your shoes. Good luck at 2 PM. Lawyer meeting. You will do great. Present yourself well.', 'ありがとう。靴楽しんで。2時PM頑張って。弁護士会議。うまくいく。しっかり見せて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'I will try. Bye. Environmental section. I will check next time. For my sister. A present.', 'やってみる。バイバイ。環境セクション。今度チェックする。妹に。プレゼント。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye. Come again. We are here until 9 PM.', 'バイバイ。またお越しを。9時PMまで。' FROM conv4;
