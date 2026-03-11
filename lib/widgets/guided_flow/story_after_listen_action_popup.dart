import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/analytics_provider.dart';
import '../../providers/story_provider.dart';
import '../../theme/engrowth_theme.dart';
import '../common/engrowth_popup.dart';
import '../common/engrowth_cta.dart';

/// 一度すべての音声を聴いた後の6択アクションを、ラージサイズポップアップで時間差表示する。
/// 0.5秒間隔で上から順にボタンを表示する。
class StoryAfterListenActionPopup {
  StoryAfterListenActionPopup._();

  static const Duration staggerDelay = Duration(milliseconds: 500);

  /// 聴き終わり後のアクションを選択させるポップアップを表示する。
  /// [onNextLearning] は「次の学習へ」選択時に呼ばれ、カルーセルを次へ進めるために使う。
  static Future<void> show(
    BuildContext context, {
    required String storyId,
    required VoidCallback onNextLearning,
  }) async {
    await EngrowthPopup.show<void>(
      context,
      size: EngrowthPopupSize.large,
      barrierDismissible: true,
      hero: Icon(Icons.check_circle_outline, size: 48, color: Theme.of(context).colorScheme.primary),
      title: '次はどうする？',
      subtitle: '選んでタップしてください',
      body: _StoryAfterListenActionBody(
        storyId: storyId,
        onNextLearning: onNextLearning,
      ),
      analyticsVariant: 'story_after_listen',
      analyticsSourceScreen: 'story_study',
    );
  }
}

class _StoryAfterListenActionBody extends ConsumerStatefulWidget {
  const _StoryAfterListenActionBody({
    required this.storyId,
    required this.onNextLearning,
  });

  final String storyId;
  final VoidCallback onNextLearning;

  @override
  ConsumerState<_StoryAfterListenActionBody> createState() => _StoryAfterListenActionBodyState();
}

class _StoryAfterListenActionBodyState extends ConsumerState<_StoryAfterListenActionBody> {
  int _visibleCount = 0;
  Timer? _timer;
  bool _hasLoggedShown = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(StoryAfterListenActionPopup.staggerDelay, (_) {
      if (!mounted) return;
      if (_visibleCount < 5) {
        setState(() => _visibleCount++);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _closeAnd(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversationsAsync = ref.watch(storyConversationsProvider(widget.storyId));
    final firstId = conversationsAsync.valueOrNull?.isNotEmpty == true
        ? conversationsAsync.value!.first.id
        : null;

    final buttons = <Widget>[
      _ActionButton(
        visible: _visibleCount >= 0,
        icon: Icons.person,
        label: 'A役で会話',
        color: EngrowthColors.roleA,
        onPressed: firstId != null
            ? () => _closeAnd(() => context.push('/conversation/$firstId?mode=roleA'))
            : null,
      ),
      _ActionButton(
        visible: _visibleCount >= 1,
        icon: Icons.person_outline,
        label: 'B役で会話',
        color: EngrowthColors.roleB,
        onPressed: firstId != null
            ? () => _closeAnd(() => context.push('/conversation/$firstId?mode=roleB'))
            : null,
      ),
      _ActionButton(
        visible: _visibleCount >= 2,
        icon: Icons.people_outline,
        label: '両方の役で会話',
        color: colorScheme.primary,
        onPressed: () => Navigator.of(context).pop(), // 閉じて学習画面の A/B ボタンから選択
      ),
      _ActionButton(
        visible: _visibleCount >= 3,
        icon: Icons.replay,
        label: 'もう一度聴く',
        color: colorScheme.primary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      _ActionButton(
        visible: _visibleCount >= 4,
        icon: Icons.arrow_forward,
        label: '次の学習へ',
        color: colorScheme.primary,
        onPressed: () => _closeAnd(widget.onNextLearning),
      ),
      _ActionButton(
        visible: _visibleCount >= 5,
        icon: Icons.bar_chart,
        label: '学習進捗ページへ',
        color: colorScheme.primary,
        onPressed: () => _closeAnd(() => context.push('/progress/story-board')),
      ),
    ];

    if (!_hasLoggedShown) {
      _hasLoggedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(analyticsServiceProvider).logEvent(
                eventType: 'story_after_listen_popup_shown',
                eventProperties: {'story_id': widget.storyId},
              );
        }
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ...buttons.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: b,
            )),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.visible,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final bool visible;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: EngrowthPrimaryButton(
          label: label,
          icon: icon,
          onPressed: visible ? onPressed : null,
        ),
      ),
    );
  }
}
