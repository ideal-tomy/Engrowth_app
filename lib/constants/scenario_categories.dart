/// シナリオ学習ページ用のカテゴリ定義
/// 会話の theme をカテゴリにマッピングしてグルーピング
class ScenarioCategory {
  final String id;
  final String displayName;
  final String iconName;  // Material Icons 名 or 絵文字
  final List<String> themePatterns;  // このカテゴリに属する theme の値

  const ScenarioCategory({
    required this.id,
    required this.displayName,
    required this.iconName,
    required this.themePatterns,
  });

  /// 会話の theme がこのカテゴリに属するか判定
  bool matchesTheme(String? theme) {
    if (theme == null || theme.isEmpty) return false;
    return themePatterns.any((p) =>
        theme == p || theme.contains(p) || p.contains(theme));
  }
}

/// シナリオカテゴリの一覧（表示順）
const List<ScenarioCategory> kScenarioCategories = [
  ScenarioCategory(
    id: 'basics',
    displayName: '挨拶・自己紹介',
    iconName: 'waving_hand',
    themePatterns: ['挨拶', '自己紹介'],
  ),
  ScenarioCategory(
    id: 'cafe',
    displayName: 'カフェ',
    iconName: 'local_cafe',
    themePatterns: ['カフェ・レストラン', 'レストラン', 'カフェ'],
  ),
  ScenarioCategory(
    id: 'hotel',
    displayName: 'ホテル',
    iconName: 'hotel',
    themePatterns: ['ホテル', 'ホテル・宿泊'],
  ),
  ScenarioCategory(
    id: 'airport',
    displayName: '空港',
    iconName: 'flight',
    themePatterns: ['空港'],
  ),
  ScenarioCategory(
    id: 'shopping',
    displayName: 'ショッピング',
    iconName: 'shopping_bag',
    themePatterns: ['アパレル', 'お土産・雑貨', 'マーケット', 'ショッピング'],
  ),
  ScenarioCategory(
    id: 'restaurant',
    displayName: '飲食',
    iconName: 'restaurant',
    themePatterns: ['スーパー', 'ベーカリー・デリ'],
  ),
  ScenarioCategory(
    id: 'pharmacy',
    displayName: 'ドラッグストア',
    iconName: 'local_pharmacy',
    themePatterns: ['ドラッグストア'],
  ),
  ScenarioCategory(
    id: 'medical',
    displayName: '病院',
    iconName: 'local_hospital',
    themePatterns: ['病院', '病院・トラブル編'],
  ),
  ScenarioCategory(
    id: 'services',
    displayName: '生活・窓口',
    iconName: 'account_balance',
    themePatterns: ['銀行口座開設', '郵便局', '郵便局、宅急便'],
  ),
  ScenarioCategory(
    id: 'directions',
    displayName: '道案内',
    iconName: 'directions',
    themePatterns: ['道の聞き方'],
  ),
  ScenarioCategory(
    id: 'travel',
    displayName: '旅行手続き',
    iconName: 'card_travel',
    themePatterns: ['交通', '共通手続き', '免税'],
  ),
];
