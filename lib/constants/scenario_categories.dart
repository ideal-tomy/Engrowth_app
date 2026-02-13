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
  // 将来追加例: 道案内, ショッピング, 病院 など
];
