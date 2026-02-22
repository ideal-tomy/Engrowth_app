-- 3分ストーリー: ビジネス自己紹介（1本目）
-- 使用単語: art, war, history, party, result, change, morning, reason, research, girl, guy, food
-- theme_slug: selfintro_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'ネットワーキングでの自己紹介',
    '社内異動後のネットワーキングパーティーで、自分の役割と貢献を簡潔に伝える会話。',
    3,
    11
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と名前', 'パーティーで自己紹介を始める', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '役割と経歴', '所属とこれまでの仕事', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '異動の理由と変化', '異動の理由と新しい役割', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '成果と今後の連絡', 'これまでの成果と今後の協力', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Hi. I just joined the team. This is my first party with the new group. Nice to meet you.', 'こんにちは。チームに加わったばかりです。新しいグループでの初パーティーです。よろしくお願いします。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. I heard about the change. So you are the new guy in research? We have been waiting for you.', 'ようこそ。異動の話は聞いていました。研究部門の新人の方ですね。お待ちしていました。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. I moved from the marketing side. The reason for the change is that we need more people in research. Our team was at war with the workload.', 'はい。マーケティングから異動しました。異動の理由は研究部門にもっと人が必要だからです。チームは仕事量と戦っている状態でした。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'I understand. We have a good history in research. A long history. You will like the team. There is food over there. Help yourself.', 'わかります。研究部門には良い歴史があります。長い歴史。チームは気に入ると思います。あそこに食べ物があります。どうぞ。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'Thank you. I had a long morning. A meeting at seven. I could use some food. So what do you do here?', 'ありがとう。今朝は長かったです。7時にミーティング。食べ物がちょうどいいです。あなたはここで何をされていますか？' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'I work on the art side. Design and creative. We work with research a lot. You will see. There is a guy from your old team. And a girl from sales. They are both here.', 'アート側を担当しています。デザインとクリエイティブ。研究とよく一緒に働きます。わかります。あなたの旧チームの男の子がいます。営業の女の子も。二人ともここにいます。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Good. I want to meet everyone. My role in research is data analysis. I did the same in marketing but the focus has changed.', 'いいですね。皆に会いたいです。研究での役割はデータ分析です。マーケでも同じことをしていましたが、フォーカスが変わりました。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'What was the result of your work in marketing? I heard good things. Something about morning reports?', 'マーケでの仕事の成果はどうでしたか？良い話を聞いています。朝のレポートについて何か。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Yes. I created a new system for morning reports. The result was better data for the team. It was a big change. Took a lot of research.', 'はい。朝のレポートの新システムを作りました。結果としてチームのデータが良くなりました。大きな変化でした。たくさんの調査がかかりました。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'That sounds useful. We need that kind of thing in design too. Maybe we can talk more at the next party. Or over food at lunch.', '役立ちそうですね。デザインでもそんなものが要ります。次のパーティーでもう話せますね。または昼食を食べながら。' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'I would like that. The reason I joined this team is the history. Your department has a strong record. I want to be part of that.', 'ぜひ。このチームに参加した理由は歴史です。御部門は実績が強い。その一員になりたいんです。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We are glad to have you. The change will be good. We need fresh ideas. The art of research, you know. It is not just numbers.', '来てくれて嬉しい。変化はいいことです。新しいアイデアが必要なんです。研究のアートというか。数字だけじゃない。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I agree. I love the mix. Data and design. Like food and art. They go together. So when is the next meeting? I want to meet the guy from sales.', '同感です。その組み合わせが好きです。データとデザイン。食べ物とアートのように。相性がいい。次のミーティングはいつですか？営業の男の子に会いたいです。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Tomorrow morning. Nine o''clock. Same room. That girl is usually there. She has good research on our clients. You will learn a lot.', '明日の朝。9時。同じ部屋。あの女の子はいつもいます。クライアントについて良いリサーチを持っています。たくさん学べます。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Perfect. Thank you for the information. This party has been very useful. I feel welcome.', '完璧です。情報をありがとう。このパーティーはとても役立ちました。歓迎されている気がします。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'You are welcome. We are a good team. No war, no stress. Just good work and good food at our parties. See you tomorrow.', 'どういたしまして。いいチームです。戦争なし、ストレスなし。いい仕事といい食べ物のパーティーだけ。明日また。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'See you tomorrow. I will bring my research notes. Maybe we can discuss the result of the last project. Goodbye.', '明日また。リサーチメモを持っていきます。前プロジェクトの成果について話せたら。さようなら。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. Welcome again. Enjoy the rest of the party.', 'さようなら。また歓迎します。残りのパーティーを楽しんで。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Thank you. I will.', 'ありがとう。楽しみます。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Bye.', 'バイバイ。' FROM conv4;
