import 'package:flutter/material.dart';
import '../../models/voice_submission.dart';

/// 提出詳細パネル（ボトムシート／ドロワー用）
/// 端末情報・セッション時間・試行回数・7日傾向等
/// user_sessions 導入後は実データ表示
class SubmissionDetailDrawer extends StatelessWidget {
  final VoiceSubmission submission;
  final Map<String, dynamic>? detail;
  final ScrollController? scrollController;

  const SubmissionDetailDrawer({
    super.key,
    required this.submission,
    this.detail,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  '詳細ログ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '提出: ${_formatDate(submission.createdAt)}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'ユーザー: ${submission.userId.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (detail != null && detail!['reason'] != null) ...[
              _buildReasonBox(context, detail!['reason_label'] as String? ?? 'データを取得できません'),
            ] else if (detail != null) ...[
              _buildSection(
                context,
                '端末情報',
                [
                  _row('OS', detail!['device_os'] as String? ?? '―'),
                  _row('機種', detail!['device_model'] as String? ?? '―'),
                  _row('種別', detail!['device_type'] as String? ?? '―'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'セッション',
                [
                  _row('学習時間', '${detail!['duration_sec'] as int? ?? 0}秒'),
                  _row('試行回数', '${detail!['attempt_count'] as int? ?? 0}'),
                  _row('リトライ', '${detail!['retry_count'] as int? ?? 0}'),
                  if (detail!['track'] != null && (detail!['track'] as String).isNotEmpty)
                    _row('トラック', detail!['track'] as String),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                '直近7日傾向',
                [_buildTrend7d(detail!['trend_7d'], colorScheme)],
              ),
            ] else ...[
              _buildReasonBox(context, 'データを取得しています…'),
            ],
          ],
        );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReasonBox(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrend7d(dynamic trend7d, ColorScheme colorScheme) {
    if (trend7d == null || trend7d is! Map<String, dynamic>) {
      return Text('―', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant));
    }
    final t = trend7d as Map<String, dynamic>;
    final count = t['session_count'] as int? ?? 0;
    final avgDur = t['avg_duration_sec'] as int? ?? 0;
    final avgRetry = t['avg_retry_count']?.toString() ?? '0';
    return Text(
      'セッション数: $count 件 / 平均学習時間: ${avgDur}秒 / 平均リトライ: $avgRetry 回',
      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
