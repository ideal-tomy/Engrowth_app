import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/scenario_background.dart';

/// 会話トレーニング選択ページ
/// 30秒シナリオ会話 / 3分英会話のどちらに進むか選ぶ
class ConversationTrainingChoiceScreen extends ConsumerWidget {
  const ConversationTrainingChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('会話トレーニング'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'トレーニングを選んでください',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                  _TrainingChoiceCard(
                    title: '30秒会話',
                    subtitle: '短いシナリオの反復練習',
                    icon: Icons.timer,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logHapticFired(trigger: 'choice_quick30');
                      context.push('/scenario-learning');
                    },
                  ),
                  const SizedBox(height: 16),
                  _TrainingChoiceCard(
                    title: '3分英会話',
                    subtitle: 'テーマ別ロールプレイ（3分連続）',
                    icon: Icons.auto_stories,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logHapticFired(trigger: 'choice_focus3');
                      context.push('/story-training');
                    },
                  ),
                  const SizedBox(height: 16),
                  _TrainingChoiceCard(
                    title: 'パターンスプリント',
                    subtitle: '30〜60秒の口慣らし（聞く→リピート）',
                    icon: Icons.speed,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logHapticFired(trigger: 'choice_pattern_sprint');
                      context.push('/pattern-sprint');
                    },
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingChoiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TrainingChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_TrainingChoiceCard> createState() => _TrainingChoiceCardState();
}

class _TrainingChoiceCardState extends State<_TrainingChoiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(16),
        splashColor: colorScheme.primary.withOpacity(0.2),
        highlightColor: colorScheme.primary.withOpacity(0.08),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutBack,
          scale: _pressed ? 0.98 : 1,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: Theme.of(context).brightness == Brightness.dark ? null : EngrowthShadows.softCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    kScenarioBgAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: colorScheme.surface),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 36,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
