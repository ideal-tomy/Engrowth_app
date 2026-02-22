/// 3分ストーリーページ用のテーマ（カテゴリ）定義
class StoryThemeCategory {
  final String theme;    // DB の conversations.theme に一致
  final String displayName;
  final String iconName;

  const StoryThemeCategory({
    required this.theme,
    required this.displayName,
    required this.iconName,
  });
}

/// 3分ストーリーのテーマ表示順序
const List<StoryThemeCategory> kStoryThemeCategories = [
  StoryThemeCategory(theme: '挨拶', displayName: '挨拶', iconName: 'waving_hand'),
  StoryThemeCategory(theme: '自己紹介', displayName: '自己紹介', iconName: 'badge'),
  StoryThemeCategory(theme: '道案内', displayName: '道案内', iconName: 'directions'),
  StoryThemeCategory(theme: '飛行機', displayName: '飛行機', iconName: 'flight'),
  StoryThemeCategory(theme: 'ホテル', displayName: 'ホテル', iconName: 'hotel'),
  StoryThemeCategory(theme: 'カフェ', displayName: 'カフェ&レストラン', iconName: 'local_cafe'),
  StoryThemeCategory(theme: 'カフェ&レストラン', displayName: 'カフェ&レストラン', iconName: 'local_cafe'),
  StoryThemeCategory(theme: 'ショッピング', displayName: 'ショッピング', iconName: 'shopping_bag'),
  StoryThemeCategory(theme: '交通機関', displayName: '交通機関', iconName: 'directions_bus'),
  StoryThemeCategory(theme: 'ビジネスメール', displayName: 'ビジネスメール', iconName: 'email'),
  StoryThemeCategory(theme: 'プレゼンテーション①', displayName: 'プレゼンテーション①', iconName: 'slide_presentation'),
  StoryThemeCategory(theme: 'プレゼンテーション②', displayName: 'プレゼンテーション②', iconName: 'slide_presentation'),
  StoryThemeCategory(theme: '銀行口座開設', displayName: '銀行口座開設', iconName: 'account_balance'),
  StoryThemeCategory(theme: '郵便局・宅急便', displayName: '郵便局・宅急便', iconName: 'local_post_office'),
  StoryThemeCategory(theme: '郵便局', displayName: '郵便局・宅急便', iconName: 'local_post_office'),
  StoryThemeCategory(theme: '病院', displayName: '病院', iconName: 'local_hospital'),
  StoryThemeCategory(theme: 'カスタム', displayName: '学習プラン', iconName: 'school'),
  StoryThemeCategory(theme: 'その他', displayName: 'その他', iconName: 'category'),
];

String displayNameForTheme(String theme) {
  for (final c in kStoryThemeCategories) {
    if (c.theme == theme) return c.displayName;
  }
  return theme;
}

int orderForTheme(String theme) {
  final idx = kStoryThemeCategories.indexWhere((c) => c.theme == theme);
  return idx >= 0 ? idx : 999;
}
