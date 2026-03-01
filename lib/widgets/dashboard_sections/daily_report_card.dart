import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_report_status_provider.dart';
import '../../theme/engrowth_theme.dart';

/// 今日の日課提出状態カード
class DailyReportCard extends ConsumerWidget {
  const DailyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStage = ref.watch(authStageProvider);
    final statusAsync = ref.watch(dailyReportStatusProvider);

    if (authStage != AuthStage.signedIn && authStage != AuthStage.coaching) {
      return const SizedBox.shrink();
    }

    return statusAsync.when(
      data: (state) {
        ref.read(analyticsServiceProvider).logDailyReportCardShown(
              status: state.status.name,
            );
        return _DailyReportCardContent(state: state);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DailyReportCardContent extends StatelessWidget {
  final DailyReportState state;

  const _DailyReportCardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (label, sublabel, icon, color) = _statusInfo(state.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/recordings');
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日の報告',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (sublabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          sublabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (String, String?, IconData, Color) _statusInfo(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.notStarted:
        return (
          'まだ報告していません',
          '今日の出来事を英語で録音して送りましょう',
          Icons.mic_none,
          EngrowthColors.primary,
        );
      case DailyReportStatus.recorded:
        return (
          '録音済み',
          '${state.practiceCount}件を先生に送れます',
          Icons.mic,
          Colors.orange,
        );
      case DailyReportStatus.submitted:
        return (
          '提出済み',
          'フィードバックをお待ちください',
          Icons.send,
          Colors.teal,
        );
      case DailyReportStatus.reviewed:
        return (
          'フィードバック済み',
          '今日の報告完了！',
          Icons.check_circle,
          EngrowthColors.success,
        );
    }
  }
}
