-- 便利なフレーズ用サンプルセンテンス（道を尋ねる・接客など）
-- Supabase Dashboard → SQL Editor で実行
-- または Table Editor から useful_phrases_sentences.csv をインポート

-- 既存データと重複しないよう、group='便利フレーズ' で一括削除してから挿入する場合:
-- DELETE FROM sentences WHERE group = '便利フレーズ';

INSERT INTO sentences (id, dialogue_en, dialogue_jp, category_tag, scene_setting, target_words, "group", difficulty, created_at)
VALUES
  (uuid_generate_v4(), 'Excuse me, where is the nearest station?', 'すみません、最寄りの駅はどこですか？', '道を尋ねる', '街中', 'train station / where is', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Excuse me, how do I get to the airport?', 'すみません、空港へはどう行けばいいですか？', '道を尋ねる', '街中', 'how do I get / airport', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'I want to go to the city center. Which way?', '市中心部に行きたいのですが、どちらの方向ですか？', '道を尋ねる', '街中', 'want to go / which way', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Is this the right way to the museum?', '博物館へはこの道で合っていますか？', '道を尋ねる', '街中', 'right way / museum', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Could you tell me where the restroom is?', 'トイレはどこか教えていただけますか？', '道を尋ねる', '店内・施設', 'could you tell me / restroom', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Would you like to try a sample?', '試食はいかがですか？', '接客', '店舗', 'would you like / sample', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Would you like anything else?', '他に何かございますか？', '接客', '店舗', 'would you like / anything else', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Can I help you find something?', '何かお探しですか？', '接客', '店舗', 'can I help you / find', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Yes please. I''d like the same as him.', 'はい、彼と同じものをいただきます。', '接客（Can I have～への返答）', 'レストラン', 'I''d like / same as', '便利フレーズ', 1, NOW()),
  (uuid_generate_v4(), 'Of course. Here you are.', 'かしこまりました。こちらです。', '接客（注文への応答）', '店舗', 'of course / here you are', '便利フレーズ', 1, NOW());
