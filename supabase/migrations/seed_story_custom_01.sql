-- 3分ストーリー: カスタム（1本目）
-- 使用単語: cultural, employee, weapon, peace, contain
-- theme_slug: custom | situation_type: common | theme: カスタム

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    '学習目標の相談',
    '専属コンサルタントと学習目標や弱点について英語で話し合う会話。',
    3,
    81
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, '目標の共有', '何を達成したいか', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, '弱点の分析', '苦手な領域', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '学習プラン', '週次スケジュール', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '次のステップ', 'お礼', 'common', 'カスタム'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'Hello. I am here for consulting. Cultural barrier with my English. As an employee I need to improve. I want a weapon for my career. Peace of mind. My goals contain many things.', 'こんにちは。相談に来た。英語に文化的壁。従業員として改善必要。キャリアの武器。安心。目標に多く含む。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Welcome. As employee your goals matter. Cultural context important. Your weapon: confidence. Peace in meetings. Program will contain your needs. Tell me more.', 'ようこそ。従業員として目標重要。文化的文脈重要。武器は自信。会議の平和。プログラムはニーズを含む。もっと。' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Cultural difference Japan and USA. As employee in meetings I lack the weapon of words. No peace when I present. Contains fear of mistakes.', '日本と米国の文化的違い。従業員として会議で言葉の武器欠如。プレゼン時に平和なし。ミスへの恐れを含む。' FROM conv1
UNION ALL SELECT id, 'B', 4, 'We build cultural bridge. We grow employee skills. Your weapon is practice. Peace through repetition. Program will contain custom plan for you.', '文化的な橋を築く。従業員スキルを育てる。武器は練習。反復で平和。プログラムはカスタムプランを含む。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'What does the custom program contain? Cultural focus? Employee business English? Is the weapon vocabulary? Peace through speaking?', 'カスタムプログラムに何が含む？文化的焦点？従業員ビジネス？武器は語彙？スピーキングで平和？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'It will contain all. Cultural nuances. Employee scenarios. Weapon is key phrases. Build peace step by step. Program contains assessment first.', 'すべてを含む。文化的ニュアンス。従業員シナリオ。武器は主要フレーズ。ステップごとに平和。まずアセスメントを含む。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'What does the assessment contain? A cultural test? My employee level? Where are my weapon weak points? I need peace to know where to start.', 'アセスメントに何が含む？文化的テスト？従業員レベル？武器の弱点は？どこから始めるか平和を知る必要。' FROM conv2
UNION ALL SELECT id, 'B', 3, 'It will contain speaking and listening. Cultural context. We do employee role play. The weapon helps us identify. Peace with the results. The plan will contain your personal focus.', 'スピーキングとリスニングを含む。文化的文脈。従業員ロールプレイ。武器で特定。結果で平和。プランは個人に含む。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'Employee role play. Cultural scenarios. The weapon is practice. Peace through simulation. It will contain real situations. Good.', '従業員ロールプレイ。文化的シナリオ。武器は練習。シミュレーションで平和。実際の状況を含む。いい。' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Exactly. We contain weekly sessions. Cultural topics. We rotate employee focus. The weapon expands. Peace comes gradually. We contain progress tracking.', 'その通り。週次セッションを含む。文化的トピック。従業員の焦点をローテート。武器は拡大。平和は徐々に。進捗追跡を含む。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Weekly. How many does it contain? Does it culturally fit my employee schedule? What about weapon time? I need peace and balance with work and life.', '週次。何回含む？従業員スケジュールに文化的に合う？武器の時間は？仕事と生活の平和とバランスが必要。' FROM conv3
UNION ALL SELECT id, 'B', 2, 'Two sessions. Each will contain one hour. We are culturally flexible. Employee evening or weekend? The weapon is your choice. Peace of schedule.', '2回のセッション。1時間を含む。文化的に柔軟。従業員は夕方か週末？武器はあなたの選択。スケジュールの平和。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Evening is good. As an employee after the work day. Culturally I am tired but I can focus. The weapon of English. Peace and progress. It contains big hope.', '夕方ていい。従業員として仕事の日後。文化的に疲れるが集中できる。英語の武器。平和と進捗。大きな希望を含む。' FROM conv3
UNION ALL SELECT id, 'B', 4, 'We contain materials. Culturally relevant. For your employee industry. The weapon is vocabulary. We build peace and confidence. We contain light homework.', '教材を含む。文化的に関連。従業員の業界向け。武器は語彙。平和と自信を築く。軽い宿題を含む。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'It contains everything. Culturally it is clear. As an employee I am motivated. My weapon is ready. Peace to start. Thank you.', 'すべてを含む。文化的に明確。従業員としてやる気。武器は準備。始める平和。ありがとう。' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Next week we contain the assessment. It is the cultural first step. Your employee journey. The weapon to success. Peace together. Goodbye.', '来週アセスメントを含む。文化的な第一歩。従業員の旅。成功への武器。一緒の平和。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Goodbye. I contain my thanks. Culturally you were helpful. As an employee I am excited. The weapon for progress. Peace of mind. Good.', 'バイバイ。感謝を含む。文化的に有益だった。従業員としてワクワク。進捗の武器。心の平和。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'Goodbye. We contain a welcome. Cultural partnership. Employee growth. The weapon of language. Peace in communication. Take care.', 'バイバイ。歓迎を含む。文化的パートナーシップ。従業員の成長。言語の武器。コミュニケーションの平和。お気をつけて。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. I contain gratitude. We build a cultural bridge. My employee goals. The weapon to achieve. Peace and confidence. Thank you.', 'バイバイ。感謝を含む。文化的な橋を築く。従業員の目標。達成の武器。平和と自信。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Good luck with your journey.', 'バイバイ。旅頑張って。' FROM conv4;
