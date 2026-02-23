import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/engrowth_theme.dart';

/// LPのURL（環境に合わせて変更可能。空ならアカウント画面へ）
const kAnonymousLpBannerUrl = '';

/// 匿名ユーザー向け：8枚カード下のアカウント作成促進バナー
/// LPやアプリの価値を伝えるページへ誘導（URL未設定時はアカウント画面へ）
class AnonymousLpBanner extends ConsumerWidget {
  const AnonymousLpBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/account');
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: EngrowthColors.primary.withOpacity(0.15),
        highlightColor: EngrowthColors.primary.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: EngrowthColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EngrowthColors.silverBorder),
            boxShadow: EngrowthShadows.softCard,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EngrowthColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 28,
                  color: EngrowthColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アカウント作成で成長を保存',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: EngrowthColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '録音比較と学習履歴をいつでも再開できます',
                      style: TextStyle(
                        fontSize: 12,
                        color: EngrowthColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: EngrowthColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
