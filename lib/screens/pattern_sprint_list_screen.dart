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
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    p.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPrefix = p.prefix);
                  },
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
}
