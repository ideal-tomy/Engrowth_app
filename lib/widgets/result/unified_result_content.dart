import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_stats.dart';
import '../../providers/user_stats_provider.dart';
import '../common/engrowth_card.dart';
import '../common/engrowth_cta.dart';
import '../common/stagger_reveal.dart';

/// B06: 統一リザルト表示の共通コンテンツ
/// カウントアップ・成功ハプティクス・CTA を統一的に提供
class UnifiedResultContent extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final int? count;
  final String? countSuffix;
  final VoidCallback? onPrimaryCta;
  final String primaryCtaLabel;
  final IconData? primaryCtaIcon;
  final VoidCallback? onSecondaryCta;
  final String secondaryCtaLabel;
  final bool useCard;
  final VoidCallback? onShown;

  const UnifiedResultContent({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.countSuffix,
    this.onPrimaryCta,
    this.primaryCtaLabel = '続ける',
    this.primaryCtaIcon,
    this.onSecondaryCta,
    this.secondaryCtaLabel = 'ホームへ',
    this.useCard = true,
    this.onShown,
  });

  @override
  ConsumerState<UnifiedResultContent> createState() => _UnifiedResultContentState();
}

class _UnifiedResultContentState extends ConsumerState<UnifiedResultContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animProgress;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onShown?.call();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(userStatsProvider);

    final staggerChildren = <Widget>[
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      if (widget.subtitle != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            widget.subtitle!,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      if (widget.count != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AnimatedBuilder(
            animation: _animProgress,
            builder: (context, child) {
              final p = _animProgress.value;
              final displayValue = (widget.count! * p).round();
              return Text(
                '${displayValue}${widget.countSuffix ?? '問'}クリア',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
        ),
      if (statsAsync.valueOrNull != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _StreakBadge(stats: statsAsync.value!),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onPrimaryCta != null)
              EngrowthPrimaryButton(
                label: widget.primaryCtaLabel,
                icon: widget.primaryCtaIcon ?? Icons.play_arrow,
                onPressed: widget.onPrimaryCta,
              ),
            if (widget.onSecondaryCta != null) ...[
              if (widget.onPrimaryCta != null) const SizedBox(height: 10),
              EngrowthSecondaryButton(
                label: widget.secondaryCtaLabel,
                onPressed: widget.onSecondaryCta,
              ),
            ],
          ],
        ),
      ),
    ];

    Widget content = StaggerReveal(
      children: staggerChildren,
    );

    if (widget.useCard) {
      content = EngrowthCard(padding: const EdgeInsets.all(24), child: content);
    }

    return content;
  }
}

class _StreakBadge extends StatelessWidget {
  final UserStats stats;

  const _StreakBadge({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final streakCount = stats.streakCount;
    if (streakCount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\u{1F525}', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '${streakCount}日連続',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
