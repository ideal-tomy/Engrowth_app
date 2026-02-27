import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// パターンスプリント用の発話アイテム
class PatternSprintItem {
  final String englishText;
  final String japaneseText;
  final String speakerRole;

  PatternSprintItem({
    required this.englishText,
    required this.japaneseText,
    required this.speakerRole,
  });
}

/// パターン定義（prefix + 表示名）
class PatternDefinition {
  final String prefix;
  final String displayName;

  const PatternDefinition({required this.prefix, required this.displayName});
}

/// conversation_utterances から prefix 抽出・候補整形を行うサービス
class PatternSprintService {
  final _supabase = Supabase.instance.client;

  /// MVP 用の事前定義パターン
  static const predefinedPatterns = [
    PatternDefinition(prefix: 'Can I have', displayName: 'Can I have...'),
    PatternDefinition(prefix: "I'd like", displayName: "I'd like..."),
    PatternDefinition(prefix: 'Could you', displayName: 'Could you...'),
    PatternDefinition(prefix: "I'm looking for", displayName: "I'm looking for..."),
    PatternDefinition(prefix: 'How much', displayName: 'How much...'),
    PatternDefinition(prefix: 'Where can I', displayName: 'Where can I...'),
    PatternDefinition(prefix: 'I would like', displayName: 'I would like...'),
    PatternDefinition(prefix: 'Can I get', displayName: 'Can I get...'),
    PatternDefinition(prefix: 'Is it possible', displayName: 'Is it possible...'),
    PatternDefinition(prefix: 'Thank you', displayName: 'Thank you...'),
  ];

  /// 全パターン一覧を返す（件数は後で付与）
  List<PatternDefinition> getPatterns() => predefinedPatterns;

  /// prefix に一致する発話を取得し、重複除外・抽選して返す
  /// [prefix] 例: "Can I have"
  /// [limit] 最大件数（セッション秒数に応じて調整）
  /// [shuffle] ランダムシャッフルするか
  Future<List<PatternSprintItem>> fetchItemsForPattern({
    required String prefix,
    int limit = 20,
    bool shuffle = true,
  }) async {
    final trimmedPrefix = prefix.trim();
    if (trimmedPrefix.isEmpty) return [];

    try {
      final response = await _supabase
          .from('conversation_utterances')
          .select('english_text, japanese_text, speaker_role')
          .ilike('english_text', '${trimmedPrefix}%');

      if (response is! List || response.isEmpty) return [];

      final seen = <String>{};
      final items = <PatternSprintItem>[];
      for (final row in response) {
        if (row is! Map) continue;
        final en = (row['english_text'] as String?)?.trim() ?? '';
        final jp = (row['japanese_text'] as String?)?.trim() ?? '';
        final role = (row['speaker_role'] as String?) ?? '';

        if (en.isEmpty || en.length > 4096) continue;
        if (seen.contains(en)) continue;
        seen.add(en);

        items.add(PatternSprintItem(
          englishText: en,
          japaneseText: jp,
          speakerRole: role,
        ));
      }

      if (items.isEmpty) return [];

      if (shuffle) {
        final rng = Random();
        items.shuffle(rng);
      }

      return items.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// セッション秒数から目安フレーズ数を算出（1フレーズあたり約3〜4秒想定）
  static int estimatePhraseCountForDuration(int durationSec) {
    const secPerPhrase = 3.5;
    return (durationSec / secPerPhrase).round().clamp(5, 50);
  }
}
