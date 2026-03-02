import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pattern_sprint_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/pattern_sprint_service.dart';
import '../widgets/favorite_toggle_icon.dart';
import '../widgets/tutorial/simulated_finger_overlay.dart';

/// パターンスプリント: パターン選択・秒数選択・セッション開始
class PatternSprintListScreen extends ConsumerStatefulWidget {
  const PatternSprintListScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<PatternSprintListScreen> createState() =>
      _PatternSprintListScreenState();
}

class _PatternSprintListScreenState extends ConsumerState<PatternSprintListScreen> {
  int _selectedDurationSec = 45;
  String? _selectedPrefix;
  final GlobalKey _overlayTargetKey = GlobalKey();

  void _onOverlayComplete() {
    if (_selectedPrefix == null) return;
    ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
          stepType: 'pattern_sprint',
        );
    ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
          learningMode: 'pattern_sprint',
          targetId: _selectedPrefix,
        );
    context.push(
      '/pattern-sprint/session?prefix=${Uri.encodeComponent(_selectedPrefix!)}&duration=$_selectedDurationSec',
    );
  }

  @override
  void initState() {
    super.initState();
    final patterns = PatternSprintService.predefinedPatterns;
    if (patterns.isNotEmpty) {
      _selectedPrefix = patterns.first.prefix;
    }
  }

  static const _durations = <int>[30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final patterns = ref.watch(patternListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('パターンスプリント'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: _buildBody(patterns, colorScheme, textTheme),
    );
  }

  Widget _buildBody(List<PatternDefinition> patterns, ColorScheme colorScheme, TextTheme textTheme) {
    final scrollChild = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/training.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildHeroFallback(),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '鬼教官と一緒に\nパターンスプリント',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '聞く→まねして言う を\n短時間でぐるぐる回していきます。',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '口慣らしトレーニング。聞く→リピートを短時間で繰り返します。',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'セッションの長さ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _durations.map((sec) {
              final isSelected = _selectedDurationSec == sec;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text('$sec秒'),
                    selected: isSelected,
                    onSelected: (v) {
                      if (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDurationSec = sec);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'パターン（よく使う言い回し）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...patterns.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final isSelected = _selectedPrefix == p.prefix;
              final useOverlayKey = widget.fromOnboarding && index == 0;
              return Padding(
                key: useOverlayKey ? _overlayTargetKey : null,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                    size: 24,
                  ),
                  title: Text(
                    p.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    p.japaneseHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPrefix = p.prefix);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteToggleIcon(
                        targetType: 'pattern',
                        targetId: p.prefix,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.play_arrow_rounded),
                        tooltip: 'このパターンですぐ始める',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(analyticsServiceProvider).logHapticFired(
                                trigger: 'pattern_sprint_start_from_list_item',
                              );
                          context.push(
                            '/pattern-sprint/session?prefix=${Uri.encodeComponent(p.prefix)}&duration=$_selectedDurationSec',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 32),
          if (widget.fromOnboarding && _selectedPrefix != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '最初のパターンでスタート',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _onOverlayComplete(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('今すぐスタート'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _selectedPrefix == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    ref.read(analyticsServiceProvider).logHapticFired(
                          trigger: 'pattern_sprint_start',
                        );
                    context.push(
                      '/pattern-sprint/session?prefix=${Uri.encodeComponent(_selectedPrefix!)}&duration=$_selectedDurationSec',
                    );
                  },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('スタート'),
            ),
          ),
        ],
      ),
    );

    if (widget.fromOnboarding && _selectedPrefix != null) {
      return Stack(
        children: [
          scrollChild,
          Positioned.fill(
            child: SimulatedFingerOverlay(
              targetKey: _overlayTargetKey,
              onComplete: _onOverlayComplete,
            ),
          ),
        ],
      );
    }
    return scrollChild;
  }

  /// 画像読み込み失敗時や画像未配置時のヒーロー表示
  Widget _buildHeroFallback() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.fitness_center,
            size: 64,
            color: colorScheme.onPrimaryContainer.withOpacity(0.9),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鬼教官と一緒に\nパターンスプリント',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '聞く→まねして言う を\n短時間でぐるぐる回していきます。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

}
