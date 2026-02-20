import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/engrowth_theme.dart';

/// ストリークマイルストーン（7日/30日等）達成時の演出ダイアログ
class StreakMilestoneDialog extends StatefulWidget {
  final int streakDays;

  const StreakMilestoneDialog({super.key, required this.streakDays});

  @override
  State<StreakMilestoneDialog> createState() => _StreakMilestoneDialogState();
}

class _StreakMilestoneDialogState extends State<StreakMilestoneDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _message {
    if (widget.streakDays >= 30) {
      return '${widget.streakDays}日連続！\n習慣が身についています';
    }
    if (widget.streakDays >= 7) {
      return '${widget.streakDays}日連続！\n素晴らしい継続力です';
    }
    return '${widget.streakDays}日連続';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.streakDays.clamp(1, 5),
                      (_) => Icon(
                        Icons.local_fire_department,
                        size: 36,
                        color: EngrowthColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🔥 マイルストーン達成！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: EngrowthColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EngrowthColors.primary,
                      foregroundColor: EngrowthColors.onPrimary,
                    ),
                    child: const Text('やる気が出た！'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
