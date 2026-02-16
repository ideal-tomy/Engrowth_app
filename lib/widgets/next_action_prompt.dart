import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// 次のアクションを促すCTA群
/// 会話全体再生後などに自動表示。外側タップで即収納。
class NextActionPrompt extends StatelessWidget {
  final List<NextActionItem> actions;
  final VoidCallback onDismiss;
  final String? title;
  final bool useDarkTheme;

  const NextActionPrompt({
    super.key,
    required this.actions,
    required this.onDismiss,
    this.title,
    this.useDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = useDarkTheme ? Colors.white70 : EngrowthColors.onSurfaceVariant;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: useDarkTheme
                  ? Colors.black.withOpacity(0.85)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: a.style == NextActionStyle.primary
                      ? ElevatedButton.icon(
                          onPressed: a.onPressed,
                          icon: Icon(a.icon, size: 20),
                          label: Text(a.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: a.color ?? EngrowthColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: a.onPressed,
                          icon: Icon(a.icon, size: 18),
                          label: Text(a.label),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: useDarkTheme ? Colors.white : EngrowthColors.onSurface,
                            side: BorderSide(
                              color: a.color ?? (useDarkTheme ? Colors.white54 : EngrowthColors.primary),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              )),
              const SizedBox(height: 8),
              Text(
                'タップして閉じる',
                style: TextStyle(
                  color: subtitleColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ],
    );
  }
}

class NextActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final NextActionStyle style;
  final Color? color;

  NextActionItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = NextActionStyle.primary,
    this.color,
  });
}

enum NextActionStyle { primary, outlined }
