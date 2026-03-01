import 'package:flutter/material.dart';

/// 次アクション提案の種別
enum NextActionType {
  dailyReport, // 今日の日課報告（最優先）
  review,      // 本日の復習
  favorites,   // お気に入りで学習
  recordings,  // 録音を提出
  dailyGoal,   // 今日の目標を達成
}

/// 次アクション提案
class NextActionSuggestion {
  final NextActionType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final int count; // 関連件数（復習数、お気に入り数など）

  const NextActionSuggestion({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    this.count = 0,
  });
}
