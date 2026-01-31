class Sentence {
  final String id;
  final String englishText;
  final String japaneseText;
  final String? imageUrl;
  final int difficulty;
  final DateTime createdAt;
  // 追加フィールド
  final String? group;
  final String? targetWords;
  final String? sceneSetting;
  final String? categoryTag;
  final String? imagePrompt;

  Sentence({
    required this.id,
    required this.englishText,
    required this.japaneseText,
    this.imageUrl,
    this.difficulty = 1,
    required this.createdAt,
    this.group,
    this.targetWords,
    this.sceneSetting,
    this.categoryTag,
    this.imagePrompt,
  });

  factory Sentence.fromJson(Map<String, dynamic> json) {
    // created_atがnullの場合は現在時刻を使用
    DateTime createdAt;
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at'] as String);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Sentence(
      id: json['id'] as String? ?? '',
      // 複数のカラム名パターンに対応
      englishText: (json['dialogue_en'] ?? json['english_text'] ?? json['Dialogue (EN)'] ?? '') as String,
      japaneseText: (json['dialogue_jp'] ?? json['japanese_text'] ?? json['Dialogue (JP)'] ?? '') as String,
      imageUrl: (json['image_url'] ?? json['ImageURL'] ?? json['imageurl']) as String?,
      difficulty: json['difficulty'] as int? ?? 1,
      createdAt: createdAt,
      group: json['group'] ?? json['Group'] as String?,
      targetWords: json['target_words'] ?? json['Target Words'] as String?,
      sceneSetting: json['scene_setting'] ?? json['Scene Setting'] as String?,
      categoryTag: json['category_tag'] ?? json['Category Tag'] as String?,
      imagePrompt: json['image_prompt'] ?? json['Image Prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dialogue_en': englishText,
      'dialogue_jp': japaneseText,
      'image_url': imageUrl,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
      'group': group,
      'target_words': targetWords,
      'scene_setting': sceneSetting,
      'category_tag': categoryTag,
      'image_prompt': imagePrompt,
    };
  }
}
