import 'package:flutter_riverpod/flutter_riverpod.dart';

/// セクション別「残り1ノード」ナッジの最終非表示時刻（クールダウン開始）
/// ナッジ表示が終了（oneLeft→false）したときに記録し、60秒間は再表示しない
final sectionNudgeCooldownProvider =
    StateProvider<Map<String, DateTime>>((ref) => {});

/// セクション別の前回oneLeft状態（true→falseの遷移検出用）
final sectionNudgeWasOneLeftProvider =
    StateProvider<Map<String, bool>>((ref) => {});

const nudgeCooldown = Duration(seconds: 60);
