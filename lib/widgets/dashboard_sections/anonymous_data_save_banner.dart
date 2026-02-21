import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/last_study_resume_provider.dart';
import '../../theme/engrowth_theme.dart';

/// 匿名ユーザー向け：学習データ保存価値を控えめに提示（学習済みユーザーのみ表示）
class AnonymousDataSaveBanner extends ConsumerWidget {
  const AnonymousDataSaveBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(lastStudyResumeProvider);
    final hasProgressToSave = resumeState.sentenceId != null;

    if (!hasProgressToSave) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/account');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: EngrowthColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: EngrowthColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 16, color: EngrowthColors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'ログインで記録を保存・続きから学習',
                  style: TextStyle(
                    fontSize: 11,
                    color: EngrowthColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: EngrowthColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
