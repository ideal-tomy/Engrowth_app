import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/startup_shortcut_content.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/startup_shortcut_provider.dart';
import 'startup_shortcut_popup.dart';

/// 起動時ショートカットの表示制御（1日1回）
/// DashboardScreen の子として配置し、条件を満たすときのみポップアップを表示
class StartupShortcutOverlay extends ConsumerStatefulWidget {
  const StartupShortcutOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<StartupShortcutOverlay> createState() =>
      _StartupShortcutOverlayState();
}

class _StartupShortcutOverlayState extends ConsumerState<StartupShortcutOverlay> {
  bool _checkDone = false;
  StartupShortcutContent? _pendingContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPopup());
  }

  Future<void> _maybeShowPopup() async {
    if (_checkDone || !mounted) return;
    _checkDone = true;

    final service = ref.read(startupShortcutServiceProvider);
    final hasShown = await service.hasShownToday();
    if (hasShown || !mounted) return;

    final content = await ref.read(startupShortcutContentProvider.future);
    if (content == null || !mounted) return;

    await service.markShownToday();

    ref.read(analyticsServiceProvider).logHomeShortcutPopupShown(
          source: content.source,
          hasMission: content.source == 'consultant',
        );

    if (mounted) {
      setState(() => _pendingContent = content);
    }
  }

  void _onDismiss() {
    setState(() => _pendingContent = null);
  }

  void _onCtaTapped(String route) {
    setState(() => _pendingContent = null);
    if (route.startsWith('/')) {
      if (route == '/progress' || route == '/words') {
        context.go(route);
      } else {
        context.push(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _pendingContent;

    return Stack(
      children: [
        widget.child,
        if (content != null)
          StartupShortcutPopup(
            content: content,
            onDismiss: _onDismiss,
            onCtaTapped: () => _onCtaTapped(content.route),
          ),
      ],
    );
  }
}
