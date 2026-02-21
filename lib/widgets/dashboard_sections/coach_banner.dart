import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/coach_provider.dart';
import '../../theme/engrowth_theme.dart';

/// 伴走契約ユーザー向け：担当講師の顔写真と今日の一言メッセージ
/// daily_summaries から日次総評があれば表示、なければデフォルト
class CoachBanner extends ConsumerWidget {
  final String defaultCoachName;
  final String defaultMessage;
  final String? avatarUrl;

  const CoachBanner({
    super.key,
    this.defaultCoachName = '担当コーチ',
    this.defaultMessage = '今日も一緒に頑張りましょう！',
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaysDailySummaryProvider);
    final message = summaryAsync.valueOrNull?.content ?? defaultMessage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EngrowthColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: EngrowthColors.primary.withOpacity(0.2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, size: 28, color: EngrowthColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  defaultCoachName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: EngrowthColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: EngrowthColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
