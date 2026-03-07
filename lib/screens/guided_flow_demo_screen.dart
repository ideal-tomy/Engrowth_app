import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/engrowth_theme.dart';
import '../providers/guided_flow_demo_provider.dart';

/// ガイドフロー体感デモ
/// ページ遷移・ポップアップ・ボタン登場を大げさにゆっくり表示し、
/// タイミング調整の感覚を掴むためのチュートリアル
class GuidedFlowDemoScreen extends ConsumerStatefulWidget {
  const GuidedFlowDemoScreen({super.key});

  @override
  ConsumerState<GuidedFlowDemoScreen> createState() => _GuidedFlowDemoScreenState();
}

class _GuidedFlowDemoScreenState extends ConsumerState<GuidedFlowDemoScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0: 開始, 1: ポップアップ表示中, 2: ボタン表示, 3: 次アクション表示中
  AnimationController? _popupController;
  AnimationController? _buttonRevealController;
  AnimationController? _nextActionController;

  Duration _scaled(Duration base) {
    final speed = ref.read(guidedFlowDemoSpeedProvider);
    return Duration(milliseconds: (base.inMilliseconds * speed).round());
  }

  void _createControllers() {
    _popupController?.dispose();
    _buttonRevealController?.dispose();
    _nextActionController?.dispose();
    _popupController = AnimationController(
      vsync: this,
      duration: _scaled(const Duration(milliseconds: 180)),
    );
    _buttonRevealController = AnimationController(
      vsync: this,
      duration: _scaled(const Duration(milliseconds: 180)),
    );
    _nextActionController = AnimationController(
      vsync: this,
      duration: _scaled(const Duration(milliseconds: 180)),
    );
  }

  @override
  void dispose() {
    _popupController?.dispose();
    _buttonRevealController?.dispose();
    _nextActionController?.dispose();
    super.dispose();
  }

  void _startDemo() {
    _createControllers();
    setState(() => _step = 1);
    _popupController!.forward(from: 0);
  }

  void _dismissPopup() {
    HapticFeedback.selectionClick();
    _popupController!.reverse().then((_) {
      if (!mounted) return;
      setState(() => _step = 2);
      _buttonRevealController!.forward(from: 0);
    });
  }

  void _showNextAction() {
    HapticFeedback.selectionClick();
    setState(() => _step = 3);
    _nextActionController!.forward(from: 0);
  }

  void _closeNextAction() {
    HapticFeedback.selectionClick();
    _nextActionController!.reverse().then((_) {
      if (!mounted) return;
      setState(() => _step = 2);
    });
  }

  void _reset() {
    _popupController?.reset();
    _buttonRevealController?.reset();
    _nextActionController?.reset();
    setState(() => _step = 0);
  }

  @override
  Widget build(BuildContext context) {
    final speed = ref.watch(guidedFlowDemoSpeedProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ガイドフロー体感デモ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _step == 0 ? _buildIntro(speed, colorScheme) : _buildDemoScene(colorScheme),
    );
  }

  Widget _buildIntro(double speed, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.slow_motion_video, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'ガイドフロー体感デモ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'ページ遷移・ポップアップ・ボタン登場を大げさにゆっくり表示します。\n'
            'タイミング調整の感覚を掴んだら、本番でちょうどいい速度に調整してください。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            '速度倍率: ${speed.toStringAsFixed(1)}x（数が大きいほど遅い）',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: speed,
            min: 1,
            max: 10,
            divisions: 18,
            label: '${speed.toStringAsFixed(1)}x',
            onChanged: (v) => ref.read(guidedFlowDemoSpeedProvider.notifier).state = v,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _startDemo,
            icon: const Icon(Icons.play_arrow),
            label: const Text('30秒シナリオ風デモを開始'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: EngrowthColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoScene(ColorScheme colorScheme) {
    return Stack(
      children: [
        // フェイク会話学習画面風の背景
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white54),
                  const SizedBox(height: 16),
                  Text(
                    '30秒シナリオ風（デモ）',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Step 1: ListenFirstPopup
        if (_step == 1 && _popupController != null)
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _popupController!,
              curve: EngrowthElementTokens.switchCurveIn,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, EngrowthElementTokens.switchOffsetY * 3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _popupController!,
                curve: EngrowthElementTokens.switchCurveIn,
              )),
              child: GestureDetector(
                onTap: _dismissPopup,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.headphones, size: 48, color: colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'まずは音声を最後まで聴いてください',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'タップして閉じる',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Step 2: 再生ボタン登場
        if (_step >= 2 && _buttonRevealController != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: FadeTransition(
              opacity: _buttonRevealController!,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _buttonRevealController!,
                  curve: EngrowthStaggerTokens.staggerCurve,
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.icon(
                        onPressed: _step == 2 ? _showNextAction : null,
                        icon: const Icon(Icons.play_circle_filled, size: 28),
                        label: const Text('会話全体を聴く'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_step == 2)
                        TextButton(
                          onPressed: _reset,
                          child: const Text('最初からやり直す'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Step 3: 次はどうする? モーダル
        if (_step == 3)
          GestureDetector(
            onTap: _closeNextAction,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: _nextActionController != null
                    ? FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _nextActionController!,
                          curve: EngrowthElementTokens.switchCurveIn,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _nextActionController!,
                            curve: EngrowthElementTokens.switchCurveIn,
                          )),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '次はどうする？',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _closeNextAction,
                              icon: const Icon(Icons.person, size: 18),
                              label: const Text('A役で練習'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: EngrowthColors.roleA),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _closeNextAction,
                              child: const Text('閉じる'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}
