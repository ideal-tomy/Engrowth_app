// センテンス一覧用のカテゴリ定義（日本人が求めそうなカテゴリ分け・日本語表示）
// DB の category_tag を日本語ラベルにマッピングし、表示順を定義する。
// 英文・日本語訳のキーワードから自動振り分けするロジックも含む。

/// 表示用の日本語カテゴリ名（DB の category_tag → 日本語）
const Map<String, String> kSentenceCategoryDisplayNames = {
  // 買い物
  'shopping': '買い物',
  'Shopping': '買い物',
  'SHOPPING': '買い物',
  // 挨拶
  'greetings': '挨拶',
  'Greetings': '挨拶',
  // 道を尋ねる
  'directions': '道を尋ねる',
  'Directions': '道を尋ねる',
  'direction': '道を尋ねる',
  'Direction': '道を尋ねる',
  // 接客
  'service': '接客',
  'Service': '接客',
  // レストラン・カフェ
  'restaurant': 'レストラン・カフェ',
  'Restaurant': 'レストラン・カフェ',
  'cafe': 'レストラン・カフェ',
  'Cafe': 'レストラン・カフェ',
  'food': '飲食',
  'Food': '飲食',
  'FOOD': '飲食',
  // 旅行
  'travel': '旅行',
  'Travel': '旅行',
  'TRAVEL': '旅行',
  'adventure': '旅行・冒険',
  'Adventure': '旅行・冒険',
  'ADVENTURE': '旅行・冒険',
  // ビジネス
  'business': 'ビジネス',
  'Business': 'ビジネス',
  'BUSINESS': 'ビジネス',
  // 日常・生活
  'daily': '日常会話',
  'Daily': '日常会話',
  'daily_conversation': '日常会話',
  'life': '生活',
  'Life': '生活',
  'LIFE': '生活',
  // 家族・人間関係
  'family': '家族',
  'Family': '家族',
  'FAMILY': '家族',
  'relationship': '人間関係',
  'Relationship': '人間関係',
  'RELATIONSHIP': '人間関係',
  'friends': '友達・交流',
  'Friends': '友達・交流',
  'FRIENDS': '友達・交流',
  // 教育
  'education': '教育',
  'Education': '教育',
  'EDUCATION': '教育',
  // イベント・社会
  'event': 'イベント',
  'Event': 'イベント',
  'EVENT': 'イベント',
  'society': '社会',
  'Society': '社会',
  'SOCIETY': '社会',
  // その他
  'hotel': 'ホテル',
  'Hotel': 'ホテル',
  'transport': '交通・乗り物',
  'Transport': '交通・乗り物',
  'emergency': '緊急・トラブル',
  'Emergency': '緊急・トラブル',
  'health': '健康・病院',
  'Health': '健康・病院',
  'HEALTH': '健康・病院',
  'art': '芸術',
  'Art': '芸術',
  'ART': '芸術',
  'outdoor': 'アウトドア',
  'Outdoor': 'アウトドア',
  'OUTDOOR': 'アウトドア',
  'technology': 'テクノロジー',
  'Technology': 'テクノロジー',
  'TECHNOLOGY': 'テクノロジー',
  'history': '歴史',
  'History': '歴史',
  'HISTORY': '歴史',
  'other': 'その他',
  'Other': 'その他',
  'その他': 'その他',
};

/// 日本人が求めそうな順のカテゴリ表示順（この順でアコーディオン・タブを並べる）
const List<String> kSentenceCategoryDisplayOrder = [
  '買い物',
  '挨拶',
  '道を尋ねる',
  '接客',
  'レストラン・カフェ',
  '飲食',
  '旅行',
  '旅行・冒険',
  'ビジネス',
  '日常会話',
  '生活',
  '家族',
  '人間関係',
  '友達・交流',
  '教育',
  'イベント',
  '社会',
  'ホテル',
  '交通・乗り物',
  '健康・病院',
  '緊急・トラブル',
  'アウトドア',
  'テクノロジー',
  '歴史',
  '芸術',
  'その他',
];

/// カテゴリ（日本語表示名）ごとのキーワード（英文・日本語訳から自動振り分け用）
/// 先にマッチしたカテゴリを優先するため、表示順で定義
const Map<String, List<String>> kCategoryKeywords = {
  '買い物': ['buy', 'shop', 'shopping', 'price', 'pay', 'card', 'cash', '購入', '買い', 'お会計', '値段', 'いくら'],
  '挨拶': ['hello', 'hi', 'good morning', 'goodbye', 'thanks', 'thank you', 'sorry', 'excuse me', 'こんにちは', 'ありがとう', 'すみません', '挨拶', 'さようなら'],
  '道を尋ねる': ['where', 'way', 'direction', 'street', 'station', 'map', '道', 'どこ', '駅', '地図', '行き方', '近く'],
  '接客': ['order', 'menu', 'customer', 'serve', 'can i help', '注文', 'メニュー', 'お客様', 'いらっしゃい', 'ご注文'],
  'レストラン・カフェ': ['restaurant', 'cafe', 'coffee', 'table', 'reservation', 'レストラン', 'カフェ', 'コーヒー', '予約', '席'],
  '飲食': ['food', 'eat', 'drink', 'meal', 'delicious', 'taste', '食べ', '飲み', '食事', '美味', '味'],
  '旅行': ['travel', 'trip', 'flight', 'hotel', 'sightseeing', '旅行', '飛行機', '観光', '宿泊'],
  '旅行・冒険': ['adventure', 'adventurous', 'explore', '冒険', '探検'],
  'ビジネス': ['business', 'meeting', 'project', 'deadline', 'presentation', 'ビジネス', '会議', 'プロジェクト', 'プレゼン', '打ち合わせ'],
  '日常会話': ['daily', 'everyday', 'usual', '日常', '普段', 'いつも'],
  '生活': ['life', 'live', 'living', 'life', '生活', '暮らし', '住む'],
  '家族': ['family', 'parent', 'child', 'mother', 'father', 'family', '家族', '親', '子供', '母', '父'],
  '人間関係': ['relationship', 'friend', 'love', 'relationship', '人間関係', '恋愛', '付き合い'],
  '友達・交流': ['friend', 'friends', 'hang out', 'together', '友達', '友人', '一緒', '遊び'],
  '教育': ['education', 'study', 'learn', 'school', 'class', '教育', '勉強', '学習', '学校', '授業'],
  'イベント': ['event', 'party', 'celebration', 'イベント', 'パーティ', '祝い', 'お祝い'],
  '社会': ['society', 'social', 'community', '社会', '社会人', 'コミュニティ'],
  'ホテル': ['hotel', 'check in', 'check out', 'room', 'ホテル', 'チェックイン', '部屋'],
  '交通・乗り物': ['bus', 'train', 'taxi', 'transport', 'subway', 'バス', '電車', 'タクシー', '乗り物', '地下鉄'],
  '健康・病院': ['health', 'doctor', 'hospital', 'medicine', 'sick', '健康', '病院', '医者', '薬', '具合'],
  '緊急・トラブル': ['emergency', 'help', 'police', 'accident', '緊急', '助けて', '事故', 'トラブル'],
  'アウトドア': ['outdoor', 'park', 'nature', 'hiking', 'アウトドア', '公園', '自然', 'ハイキング'],
  'テクノロジー': ['technology', 'computer', 'phone', 'internet', 'app', 'テクノロジー', 'パソコン', 'スマホ', 'インターネット', 'アプリ'],
  '歴史': ['history', 'historical', '歴史', '昔'],
  '芸術': ['art', 'artist', 'museum', 'painting', '芸術', '美術', 'アート', '絵画'],
};

/// [rawTag] を日本語表示名に変換。未定義なら [rawTag] をそのまま返す。
String sentenceCategoryToDisplayName(String rawTag) {
  var trimmed = rawTag.trim();
  if (trimmed.isEmpty) return 'その他';
  // # や ## プレフィックスを除去してからマッピング
  trimmed = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
  if (trimmed.isEmpty) return 'その他';
  return kSentenceCategoryDisplayNames[trimmed] ??
      kSentenceCategoryDisplayNames[trimmed.toLowerCase()] ??
      rawTag;
}

/// 表示名でソートするためのインデックス（小さいほど先に表示）
int sentenceCategorySortIndex(String displayName) {
  final index = kSentenceCategoryDisplayOrder.indexOf(displayName);
  return index >= 0 ? index : kSentenceCategoryDisplayOrder.length;
}

/// 英文・日本語訳のキーワードから、タイトル（日本語カテゴリ）に自動振り分けする。
/// [categoryTag] が DB にあり且つマッピングされていればそれを優先し、
/// なければ [englishText] と [japaneseText] のキーワードでマッチした最初のカテゴリを返す。
String resolveSentenceCategory({
  String? categoryTag,
  required String englishText,
  required String japaneseText,
}) {
  // 1) DB の category_tag が登録済みなら日本語に変換して返す（# / ## プレフィックス対応）
  if (categoryTag != null && categoryTag.trim().isNotEmpty) {
    final normalized = categoryTag.trim().replaceFirst(RegExp(r'^#+\s*'), '');
    if (normalized.isNotEmpty) {
      final lower = normalized.toLowerCase();
      if (kSentenceCategoryDisplayNames[normalized] != null ||
          kSentenceCategoryDisplayNames[lower] != null) {
        return sentenceCategoryToDisplayName(categoryTag.trim());
      }
    }
  }

  // 2) 英文・日本語を結合してキーワードマッチ（表示順で最初にマッチしたカテゴリ）
  final combined = '${englishText.toLowerCase()} $japaneseText';
  for (final categoryName in kSentenceCategoryDisplayOrder) {
    final keywords = kCategoryKeywords[categoryName];
    if (keywords == null) continue;
    for (final keyword in keywords) {
      if (keyword.length < 2) continue;
      if (RegExp(r'[a-z]').hasMatch(keyword)) {
        if (combined.contains(keyword.toLowerCase())) return categoryName;
      } else {
        if (combined.contains(keyword)) return categoryName;
      }
    }
  }

  // 3) どれにも当てはまらなければ「その他」
  return 'その他';
}

/// DB の phrase_title が未設定時のフォールバック: 英文からネイティブ言い回しタイトルを推定
String derivePhraseTitleFromEnglish(String englishText) {
  final lower = englishText.trim().toLowerCase();
  if (lower.isEmpty) return 'その他';
  if (lower.startsWith('can i have')) return 'Can I have ...?';
  if (lower.startsWith('would you like')) return 'Would you like ...?';
  if (lower.startsWith('could you tell me')) return 'Could you tell me ...?';
  if (lower.startsWith('excuse me, where') || lower.startsWith('excuse me. where')) return 'Excuse me, where is ...?';
  if (lower.startsWith("where's ") || lower.startsWith('where is')) return 'Where is ...?';
  if (lower.startsWith('how do i get') || lower.startsWith('how can i get')) return 'How do I get to ...?';
  if (lower.startsWith("i'd like") || lower.startsWith('i would like')) return "I'd like ...";
  if (lower.startsWith('i want')) return 'I want ...';
  if (lower.startsWith('can i help you') || lower.startsWith('may i help you')) return 'Can I help you ...?';
  if (lower.startsWith('of course') || lower.startsWith('sure')) return 'Of course. / Sure.';
  if (lower.startsWith('yes please') || lower.startsWith('yes, please')) return 'Yes, please.';
  if (lower.startsWith('is this the right way')) return 'Is this the right way to ...?';
  if (lower.startsWith('which way')) return 'Which way ...?';
  if (lower.startsWith('hello') || lower == 'hi' || lower.startsWith('hi ')) return 'Hello. / Hi.';
  if (lower.startsWith('thank you') || lower.startsWith('thanks')) return 'Thank you. / Thanks.';
  if (lower.startsWith('goodbye') || lower.startsWith('bye')) return 'Goodbye. / Bye.';
  if (lower.startsWith('sorry') || lower.startsWith('excuse me')) return 'Sorry. / Excuse me.';
  // パターンに合わない場合は短く切り詰めて表示（全文をそのまま出さない）
  if (englishText.length > 30) return '${englishText.substring(0, 30).trim()}...';
  return englishText.length > 15 ? '${englishText.substring(0, 15).trim()}...' : (englishText.isEmpty ? 'その他' : englishText);
}

/// タブ表示用: 「道を尋ねる」→「道案内」など、表示名を統一。英語タグは必ず日本語に変換。
String canonicalCategoryForTabs(String? raw) {
  if (raw == null || raw.isEmpty) return 'その他';
  if (raw == '道を尋ねる') return '道案内';
  return sentenceCategoryToDisplayName(raw);
}
