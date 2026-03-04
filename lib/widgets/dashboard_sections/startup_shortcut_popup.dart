import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/startup_shortcut_content.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/startup_shortcut_provider.dart';
import '../../theme/engrowth_theme.dart';

/// 起動時ショートカットポップアップ
/// 背景Blur + 半透明オーバーレイで「今、これだけに集中」を伝える
class StartupShortcutPopup extends ConsumerStatefulWidget {
  const StartupShortcutPopup({
    super.key,
    required this.content,
    required this.onDismiss,
    required this.onCtaTapped,
  });

  final StartupShortcutContent content;
  final VoidCallback onDismiss;
  final VoidCallback onCtaTapped;

  @override
  ConsumerState<StartupShortcutPopup> createState() =>
      _StartupShortcutPopupState();
}

class _StartupShortcutPopupState extends ConsumerState<StartupShortcutPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCtaTap() {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logHomeShortcutPopupCtaTapped(
          route: widget.content.route,
          source: widget.content.source,
        );
    widget.onCtaTapped();
  }

  void _handleDismiss() {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logHomeShortcutPopupDismissed(
          reason: 'close',
        );
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = widget.content;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _handleDismiss,
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (content.showConsultantAvatar) ...[
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  colorScheme.primary.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 28,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Text(
                              content.message,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _handleCtaTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: EngrowthColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(content.ctaLabel),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _handleDismiss,
                        child: Text(
                          'あとで',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
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
    );
  }
}
