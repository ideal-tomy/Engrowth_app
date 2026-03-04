import 'package:flutter/material.dart';

/// パターンスプリントのカテゴリ（集中トレーニング単位）
/// ハイブリッド設計: 初期は固定マスタ、将来DBから上書き可能
class PatternSprintCategory {
  final String id;
  final String displayName;
  final IconData icon;

  /// どんな時に使うかの1行説明
  final String usageHint;

  /// このカテゴリの代表パターンprefix一覧（開始CTA用）
  final List<String> representativePrefixes;

  const PatternSprintCategory({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.usageHint,
    required this.representativePrefixes,
  });
}
