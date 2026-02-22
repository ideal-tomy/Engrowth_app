-- 3分ストーリー: 銀行口座開設（5本目）
-- 使用単語: onto, reveal, direction, establish
-- theme_slug: bank | situation_type: student | theme: 銀行口座開設

WITH new_seq AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES (
    'オンライン銀行の設定',
    'モバイルアプリとオンラインバンキングの設定を銀行員に手伝ってもらう会話。',
    3,
    70
  )
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 1, 'アプリのダウンロード', '設定開始', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv2 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 2, 'ログイン方法', 'パスワード設定', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv3 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 3, '機能の説明', '残高確認など', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
),
conv4 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description, situation_type, theme)
  SELECT id, 4, '完了', 'お礼', 'student', '銀行口座開設'
  FROM new_seq
  RETURNING id
)
INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
SELECT id, 'A', 1, 'I want to establish online access. Direction from here? Can you reveal the steps? I need to get onto the app fast.', 'オンラインアクセスを開設したい。方向は？ステップを明らかに？アプリに速く乗る必要。' FROM conv1
UNION ALL SELECT id, 'B', 2, 'Easy. We establish access tonight. Direction simple. Step by step. I reveal each screen. Onto your phone. Ready?', '簡単。今夜アクセス開設。方向シンプル。ステップごと。各画面を明らかに。電話に。準備？' FROM conv1
UNION ALL SELECT id, 'A', 3, 'Yes. The direction is clear. To establish my account online. Please reveal the process. Do I go onto the App Store first?', 'はい。方向は明確。口座をオンラインで開設。プロセスを明らかに。まずApp Storeに？' FROM conv1
UNION ALL SELECT id, 'B', 4, 'Right. We establish by download. Search for the app. Use our bank name. The direction is obvious. Reveal the blue icon onto your screen. Tap to install.', '正しい。ダウンロードで開設。アプリを検索。銀行名で。方向は明白。青いアイコンを画面に明らかに。タップでインストール。' FROM conv1
UNION ALL SELECT id, 'A', 5, 'After we establish account how does link work? Direction for login? Reveal credentials onto app?', '口座開設後リンクは？ログインの方向は？認証情報をアプリに明らかに？' FROM conv1
UNION ALL SELECT id, 'B', 1, 'We establish your user name from the form you filled yesterday. The direction is to create a password. I reveal the requirements onto the screen. Eight chars. Number and letter.', '昨日の用紙からユーザー名を開設。方向はパスワード作成。要件を画面に明らかに。8文字。数字と文字。' FROM conv2
UNION ALL SELECT id, 'A', 2, 'I establish the password. Done. What is the direction next? Do you reveal a security question? Is that onto the next step?', 'パスワードを開設。完了。次の方向は？セキュリティ質問を明らかに？それに？' FROM conv2
UNION ALL SELECT id, 'B', 3, 'Yes. We establish security. The direction is to choose a question. I reveal the options onto the list. Mother maiden name. Pet. First school.', 'はい。セキュリティを開設。方向は質問選択。オプションをリストに明らかに。母親の旧姓。ペット。最初の学校。' FROM conv2
UNION ALL SELECT id, 'A', 4, 'I establish all of that. Done. What is the direction to the main screen? Do you reveal the balance onto the app now?', 'すべて開設。完了。メイン画面への方向は？残高をアプリに今明らかにする？' FROM conv2
UNION ALL SELECT id, 'B', 5, 'Yes. We establish complete. The direction is home. I reveal the balance onto the top of the screen. Transactions below. The direction is clear.', 'はい。開設完了。方向はホーム。残高を画面上部に明らかに。取引は下に。方向は明確。' FROM conv2
UNION ALL SELECT id, 'A', 1, 'Can I establish transfer? Direction? How does it work? Where reveal the button? Send money to a friend?', '振込は開設？方向は？どう機能？ボタンはどこ？友達に送れる？' FROM conv3
UNION ALL SELECT id, 'B', 2, 'We establish transfer. The direction is tap Transfer. I reveal the form onto the screen. Enter amount and account number or email. The direction is simple.', '振込を開設。方向は振込タップ。フォームを画面に明らかに。金額と口座番号かメールを入力。方向はシンプル。' FROM conv3
UNION ALL SELECT id, 'A', 3, 'Can I establish alerts? Direction for notifications? Where do you reveal settings? Is it onto the menu? Balance low alert?', 'アラートは開設できる？通知の方向？設定はどこに明らかに？メニューに？残高低下アラート？' FROM conv3
UNION ALL SELECT id, 'B', 4, 'Yes. We establish alerts. The direction is Settings and the gear icon. I reveal the options onto the list. Balance threshold. Deposit alert. Direction is to customize.', 'はい。アラートを開設。方向は設定の歯車アイコン。オプションをリストに明らかに。残高閾値。入金アラート。方向はカスタマイズ。' FROM conv3
UNION ALL SELECT id, 'A', 5, 'I establish everything. The direction is clear now. Does the app reveal all features onto a tutorial? Is the direction self guide?', 'すべて開設。方向は明確。アプリはチュートリアルに全機能を明らかに？方向は自分で案内？' FROM conv3
UNION ALL SELECT id, 'B', 1, 'Yes. We establish your knowledge. The direction is the Help section. We reveal videos onto the app. Step by step. We establish your confidence.', 'はい。知識を開設。方向はヘルプセクション。動画をアプリに明らかに。ステップごと。自信を開設。' FROM conv4
UNION ALL SELECT id, 'A', 2, 'Thank you. I establish my online access. The direction is complete. You reveal it was easy. I am onto track to manage my money. Good.', 'ありがとう。オンラインを開設。方向は完了。簡単だと明らかに。お金管理の軌道に乗った。いい。' FROM conv4
UNION ALL SELECT id, 'B', 3, 'You are welcome. Establish good habits. The direction is check weekly. The app reveals spending onto the screen. Direction for budget success. Goodbye.', 'どういたしまして。良い習慣を開設。方向は週次チェック。アプリが支出を明らかに。予算成功の方向。バイバイ。' FROM conv4
UNION ALL SELECT id, 'A', 4, 'Goodbye. I establish the account. The direction was right. You reveal a good bank. I am onto recommending to friends. Thank you.', 'バイバイ。口座を開設。方向は正しかった。良い銀行と明らかに。友達に勧める軌道に。ありがとう。' FROM conv4
UNION ALL SELECT id, 'B', 5, 'Goodbye. Take care. Good luck with your new account.', 'バイバイ。お気をつけて。新しい口座で頑張って。' FROM conv4;
