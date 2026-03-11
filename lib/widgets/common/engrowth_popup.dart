import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_provider.dart';
import '../../theme/engrowth_theme.dart';
import 'animated_backdrop.dart';
import 'engrowth_card.dart';
import 'engrowth_cta.dart';
import 'stagger_reveal.dart';

/// ポップアップのサイズバリアント
enum EngrowthPopupSize {
  /// 中身に追従（通知・確認・ガイド）
  small,

  /// 画面高さの約55%（学習カード・練習フロー）
  medium,

  /// 画面高さの約85%（説明フロー・ゴール設定）
  large,
}

/// Speak風の高級感あるポップアップテンプレート。
/// 背景ぼかし → コンテンツ段階表示 → 退場、を EngrowthPopupTokens に基づいて統一する。
class EngrowthPopup extends ConsumerStatefulWidget {
  const EngrowthPopup({
    super.key,
    this.size = EngrowthPopupSize.small,
    this.hero,
    this.title,
    this.subtitle,
    this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.autoCloseAfter,
    this.analyticsVariant,
    this.analyticsSourceScreen,
  });

  final EngrowthPopupSize size;
  final Widget? hero;
  final String? title;
  final String? subtitle;
  final Widget? body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Duration? autoCloseAfter;

  /// 計測用バリアント名（例: listen_first / session_complete など）
  final String? analyticsVariant;

  /// 計測用スクリーン名
  final String? analyticsSourceScreen;

  static Future<T?> show<T>(
    BuildContext context, {
    EngrowthPopupSize size = EngrowthPopupSize.small,
    Widget? hero,
    String? title,
    String? subtitle,
    Widget? body,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    Duration? autoCloseAfter,
    bool barrierDismissible = false,
    String? analyticsVariant,
    String? analyticsSourceScreen,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: EngrowthPopupTokens.backdropDuration,
      pageBuilder: (context, _, __) {
        return Center(
          child: EngrowthPopup(
            size: size,
            hero: hero,
            title: title,
            subtitle: subtitle,
            body: body,
            primaryLabel: primaryLabel,
            onPrimary: onPrimary,
            secondaryLabel: secondaryLabel,
            onSecondary: onSecondary,
            autoCloseAfter: autoCloseAfter,
            analyticsVariant: analyticsVariant,
            analyticsSourceScreen: analyticsSourceScreen,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<EngrowthPopup> createState() => _EngrowthPopupState();
}

class _EngrowthPopupState extends ConsumerState<EngrowthPopup> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(EngrowthPopupTokens.contentDelay, () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    final variant = widget.analyticsVariant;
    if (variant != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(analyticsServiceProvider).logEngrowthPopupShown(
              variant: variant,
              sourceScreen: widget.analyticsSourceScreen,
            );
      });
    }

    if (widget.autoCloseAfter != null) {
      Future.delayed(widget.autoCloseAfter!, () {
        if (!mounted) return;
        Navigator.of(context).maybePop();
      });
    }
  }

  List<Widget> _buildChildren(ColorScheme colorScheme, TextTheme textTheme) {
    final children = <Widget>[];

    if (widget.hero != null) {
      children.add(Center(child: widget.hero!));
    }

    if (widget.title != null) {
      children.add(Text(
        widget.title!,
        textAlign: TextAlign.center,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ));
    }

    if (widget.subtitle != null) {
      children.add(Text(
        widget.subtitle!,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ));
    }

    if (widget.body != null) {
      children.add(widget.body!);
    }

    if (widget.primaryLabel != null || widget.secondaryLabel != null) {
      children.add(const SizedBox(height: 8));
    }

    if (widget.primaryLabel != null) {
      children.add(EngrowthPrimaryButton(
        label: widget.primaryLabel!,
        onPressed: widget.onPrimary,
      ));
    }

    if (widget.secondaryLabel != null) {
      children.add(const SizedBox(height: 8));
      children.add(EngrowthSecondaryButton(
        label: widget.secondaryLabel!,
        onPressed: widget.onSecondary,
      ));
    }

    return children;
  }

  double _paddingForSize(EngrowthPopupSize size) {
    switch (size) {
      case EngrowthPopupSize.small:
        return 24;
      case EngrowthPopupSize.medium:
        return 20;
      case EngrowthPopupSize.large:
        return EngrowthPopupTokens.largePaddingH;
    }
  }

  BoxConstraints? _constraintsForSize(
    EngrowthPopupSize size,
    MediaQueryData mediaQuery,
  ) {
    final height = mediaQuery.size.height;
    switch (size) {
      case EngrowthPopupSize.small:
        return null;
      case EngrowthPopupSize.medium:
        return BoxConstraints(
          maxHeight: height * EngrowthPopupTokens.mediumHeightFraction,
        );
      case EngrowthPopupSize.large:
        return BoxConstraints(
          maxHeight: height * EngrowthPopupTokens.largeHeightFraction,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaQuery = MediaQuery.of(context);

    final children = _buildChildren(colorScheme, textTheme);
    final paddingH = _paddingForSize(widget.size);
    final constraints = _constraintsForSize(widget.size, mediaQuery);

    final cardContent = StaggerReveal(
      play: _showContent,
      children: [
        ..._interleaveSpacing(children),
      ],
    );

    Widget card = EngrowthCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: constraints != null
          ? SingleChildScrollView(child: cardContent)
          : cardContent,
    );

    if (constraints != null) {
      card = ConstrainedBox(
        constraints: constraints,
        child: card,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBackdrop(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingH),
            child: card,
          ),
        ),
      ),
    );
  }

  List<Widget> _interleaveSpacing(List<Widget> children) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i != children.length - 1) {
        result.add(const SizedBox(height: 12));
      }
    }
    return result;
  }
}

