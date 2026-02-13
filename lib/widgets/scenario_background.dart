import 'package:flutter/material.dart';

/// 全シチュエーション画面で使用する仮設定の背景画像
const kScenarioBgAsset = 'assets/images/temp_bg.png';

/// シチュエーション画面用の背景ウィジェット
/// temp_bg.png を全画面に表示し、オーバーレイで可読性を確保
class ScenarioBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const ScenarioBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            kScenarioBgAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(overlayOpacity * 0.5),
                  Colors.black.withOpacity(overlayOpacity),
                  Colors.black.withOpacity(overlayOpacity * 1.2),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
