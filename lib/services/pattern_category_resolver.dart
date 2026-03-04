import 'package:flutter/material.dart';
import '../models/pattern_sprint_category.dart';
import 'pattern_sprint_service.dart';

/// パターンカテゴリの解決（ハイブリッド: 固定マスタ + 将来DB拡張）
class PatternCategoryResolver {
  static final PatternCategoryResolver _instance = PatternCategoryResolver._();
  factory PatternCategoryResolver() => _instance;
  PatternCategoryResolver._();

  /// 固定マスタ（将来DBから取得したもので上書き可能）
  static final List<PatternSprintCategory> _masterCategories = [
    PatternSprintCategory(
      id: 'order',
      displayName: '注文したいとき',
      icon: Icons.restaurant_menu,
      usageHint: 'カフェ・レストランで注文するとき',
      representativePrefixes: ['Can I have', "I'd like", 'Can I get'],
    ),
    PatternSprintCategory(
      id: 'shopping',
      displayName: '買い物をしたいとき',
      icon: Icons.shopping_bag_outlined,
      usageHint: 'お店で探す・値段を聞くとき',
      representativePrefixes: ["I'm looking for", 'How much'],
    ),
    PatternSprintCategory(
      id: 'directions',
      displayName: '道を尋ねるとき',
      icon: Icons.directions,
      usageHint: '場所を聞く・道案内を頼むとき',
      representativePrefixes: ['Where can I'],
    ),
    PatternSprintCategory(
      id: 'request',
      displayName: 'お願い・依頼するとき',
      icon: Icons.handshake_outlined,
      usageHint: '丁寧に頼みごとをするとき',
      representativePrefixes: ['Could you', 'Is it possible'],
    ),
    PatternSprintCategory(
      id: 'thanks',
      displayName: '感謝を伝えるとき',
      icon: Icons.thumb_up_outlined,
      usageHint: 'お礼を言うとき',
      representativePrefixes: ['Thank you'],
    ),
  ];

  /// 全カテゴリを返す（将来: DBから取得してマージ可能）
  List<PatternSprintCategory> getCategories() {
    return List.unmodifiable(_masterCategories);
  }

  /// カテゴリIDから取得
  PatternSprintCategory? getCategoryById(String id) {
    try {
      return _masterCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// パターン定義をカテゴリ別にグループ化
  Map<String, List<PatternDefinition>> groupPatternsByCategory() {
    final patterns = PatternSprintService.predefinedPatterns;
    final byCategory = <String, List<PatternDefinition>>{};
    for (final p in patterns) {
      byCategory.putIfAbsent(p.categoryId, () => []).add(p);
    }
    return byCategory;
  }
}
