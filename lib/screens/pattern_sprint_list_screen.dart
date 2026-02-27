import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pattern_sprint_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/pattern_sprint_service.dart';

/// パターンスプリント: パターン選択・秒数選択・セッション開始
class PatternSprintListScreen extends ConsumerStatefulWidget {
  const PatternSprintListScreen({super.key});

  @override
  ConsumerState<PatternSprintListScreen> createState() =>
      _PatternSprintListScreenState();
}

class _PatternSprintListScreenState extends ConsumerState<PatternSprintListScreen> {
  int _selectedDurationSec = 45;
  String? _selectedPrefix;

  @override
  void initState() {
    super.initState();
    final patterns = PatternSprintService.predefinedPatterns;
    if (patterns.isNotEmpty) {
      _selectedPrefix = patterns.first.prefix;
    }
  }

  static const _durations = [30, 45, 60];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヒーローセクション：横長画像（training.png） or フォールバック
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
                      label: Text('${sec}秒'),
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
            ...patterns.map((p) {
              final isSelected = _selectedPrefix == p.prefix;
              return Padding(
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
                  trailing: IconButton.filledTonal(
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
                ),
              );
            }),
            const SizedBox(height: 32),
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
      ),
    );
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
