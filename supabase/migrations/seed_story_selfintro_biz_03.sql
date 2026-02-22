-- 3分ストーリー: ビジネス自己紹介（3本目）
-- 使用単語: market, sense, nation, plan, college, interest, death, experience, return, sound, light, class
-- theme_slug: selfintro_biz

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '国際会議での自己紹介',
    '海外取引先との会議で、担当マーケット・経験・計画を英語で伝える会話。',
    3,
    13
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '挨拶と担当', '会議で自己紹介を始める', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '学歴と経験', '大学とキャリアの経歴', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '計画と貢献', 'マーケット戦略の説明', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '今後の協力', '共同プロジェクトの見通し', 'business', '自己紹介'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
-- チャンク1
SELECT id, 'A', 1, 'Good morning everyone. Let me introduce myself. I am Yuki from the Tokyo office. I lead the Asia market team.', 'おはようございます。自己紹介させてください。東京オフィスの由紀です。アジアマーケットチームを率いています。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome Yuki. We have heard good things. So the Asia market is growing. What is your plan for the next year?', 'ようこそ由紀さん。良い話を聞いています。アジアマーケットは成長中ですね。来年の計画は？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'We have a strong plan. The market in our nation is mature. But other nations in the region have great interest.', 'しっかりした計画があります。わが国のマーケットは成熟しています。でも地域の他の国々に大きな関心があります。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'That makes sense. So you focus on expansion. What was your experience before this role?', 'それは筋が通ります。拡大に焦点を当てているわけですね。この役割の前の経験は？' FROM conv1
UNION ALL SELECT id, 'A', 5, 'I worked in sales for five years. Then I went to college for an MBA. I returned to the company two years ago.', '営業で5年働きました。それから大学でMBAを取りました。2年前に会社に戻りました。' FROM conv1
-- チャンク2
UNION ALL SELECT id, 'B', 1, 'MBA. That sounds useful. Which college? And what class did you enjoy most?', 'MBAか。役立ちそうですね。どこの大学？一番楽しかった授業は？' FROM conv2
UNION ALL SELECT id, 'A', 2, 'Stanford. The class on global market strategy was the best. It gave me a new sense of how nations compete.', 'スタンフォードです。グローバルマーケット戦略の授業が最高でした。国がどう競争するか新しい感覚を与えてくれました。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'That is valuable experience. We need that kind of sense here. The market changes fast. No one wants to see the death of a good idea.', '価値ある経験ですね。そんな感覚がここには必要です。マーケットは速く変わる。良いアイデアの終わりを見たくない。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Exactly. We move with the light. Quick decisions. Our plan is to test in one nation first. Then expand.', 'その通り。光に沿って動く。素早い決定。計画は一国でまずテスト。それから拡大。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'A sound approach. I have interest in your Japan market data. Can we discuss that after the break?', '健全なアプローチですね。日本のマーケットデータに興味があります。休憩後に話せますか？' FROM conv2
-- チャンク3
UNION ALL SELECT id, 'A', 1, 'Of course. I will bring the market report. It has everything on our nation. Sales, interest, growth. The full picture.', 'もちろん。マーケットレポートを持ってきます。わが国に関する全てがあります。売上、関心、成長。全体像です。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Good. The plan for this meeting was to align our teams. Your experience will help. We need a shared sense of direction.', 'いいですね。この会議の計画はチームを揃えること。あなたの経験が助けになります。共通の方向感覚が必要です。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'I agree. My return to the company was for this. I want to bring what I learned in college to the market.', '同感です。会社に戻った理由はこれです。大学で学んだことをマーケットに持ち込みたい。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'That is the right class of thinking. We need people who see the light. Not just the numbers.', 'そのレベルの考え方ですね。光を見る人が必要です。数字だけじゃなく。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'Thank you. The market teaches us. If we listen, we hear the sound of change. We adapt.', 'ありがとう。マーケットが教えてくれます。耳を傾ければ変化の音が聞こえる。適応する。' FROM conv3
-- チャンク4
UNION ALL SELECT id, 'B', 1, 'Well said. So after this meeting we will have a clear plan. Each nation, each market. Does that sound right?', 'おっしゃる通り。この会議の後、明確な計画ができる。各国、各マーケット。そう聞こえますか？' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Yes. I have interest in the European side too. Maybe we can share experience. A two-way flow.', 'はい。ヨーロッパ側にも興味があります。経験を共有できるかも。双方向の流れ。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Good idea. I will put you in touch with our Paris team. They have a similar sense. College ties actually.', 'いい考え。パリチームをご紹介します。似た感覚を持っています。実は大学のつながりです。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'That would be great. Thank you. I look forward to the return on this partnership. A strong return.', 'それは素晴らしい。ありがとう。このパートナーシップのリターンを楽しみにしています。力強いリターン。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Same here. Let us get some light refreshments. Break time.', 'こちらこそ。軽いお茶でも取りましょう。休憩です。' FROM conv4;
