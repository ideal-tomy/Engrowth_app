import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/scenario_categories.dart';
import '../models/conversation.dart';
import '../providers/analytics_provider.dart';
import '../providers/conversation_provider.dart';
import '../services/tts_warmup_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';
import '../widgets/tutorial/simulated_finger_overlay.dart';
import '../widgets/tutorial/learning_intro_dialog.dart';

/// シナリオ学習ページ（Netflix型: セクション + 横スクロール行）
class ScenarioLearningScreen extends ConsumerStatefulWidget {
  const ScenarioLearningScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<ScenarioLearningScreen> createState() =>
      _ScenarioLearningScreenState();
}

class _ScenarioLearningScreenState extends ConsumerState<ScenarioLearningScreen> {
  final GlobalKey _overlayTargetKey = GlobalKey();
  bool _overlayCompleted = false;

  static IconData _iconForCategory(String iconName) {
    switch (iconName) {
      case 'local_cafe':
        return Icons.local_cafe;
      case 'hotel':
        return Icons.hotel;
      case 'flight':
        return Icons.flight;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'card_travel':
        return Icons.card_travel;
      case 'waving_hand':
        return Icons.waving_hand;
      case 'account_balance':
        return Icons.account_balance;
      case 'directions':
        return Icons.directions;
      default:
        return Icons.place;
    }
  }

  void _onOverlayComplete(Conversation firstConversation) {
    if (_overlayCompleted) return;
    _overlayCompleted = true;
    ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
          learningMode: 'quick30',
          targetId: firstConversation.id,
        );
    LearningIntroDialog.show(
      context,
      title: '30秒会話',
      body: '30秒前後の会話のやりとりを体験します。全体の会話を聴いた後、A役（B役）を選択して会話の練習を行います。',
      onStart: () {
        context.push('/conversation/${firstConversation.id}?mode=listen');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(conversationsByCategoryWithSubsectionsProvider);

    ref.listen(conversationsByCategoryWithSubsectionsProvider, (_, next) {
      next.whenData((byCategory) {
        final ids = <String>[];
        for (final category in kScenarioCategories) {
          for (final sub in (byCategory[category.id] ?? [])) {
            for (final c in sub.conversations.take(3)) {
              ids.add(c.id);
              if (ids.length >= 5) break;
            }
            if (ids.length >= 5) break;
          }
          if (ids.length >= 5) break;
        }
        if (ids.isNotEmpty) {
          TtsWarmupService().warmupForConversationIds(ref, ids);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('シナリオ学習'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: dataAsync.when(
        data: (byCategory) {
          Conversation? firstConversation;
          if (widget.fromOnboarding) {
            ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
                  stepType: 'quick30',
                );
            for (final category in kScenarioCategories) {
              final subsections = byCategory[category.id] ?? [];
              for (final sub in subsections) {
                if (sub.conversations.isNotEmpty) {
                  firstConversation = sub.conversations.first;
                  break;
                }
              }
              if (firstConversation != null) break;
            }
          }
          final items = <Widget>[];
          bool assignedKey = false;
          for (final category in kScenarioCategories) {
            final subsections = byCategory[category.id] ?? [];
            for (final sub in subsections) {
              final useKey = widget.fromOnboarding && !assignedKey && sub.conversations.isNotEmpty;
              if (useKey) assignedKey = true;
              items.add(_ScenarioSection(
                category: category,
                icon: _iconForCategory(category.iconName),
                subTitle: sub.subTitle,
                conversations: sub.conversations,
                overlayTargetKey: useKey ? _overlayTargetKey : null,
              ));
            }
            if (subsections.isEmpty) {
              items.add(_ScenarioSection(
                category: category,
                icon: _iconForCategory(category.iconName),
                subTitle: null,
                conversations: [],
                overlayTargetKey: null,
              ));
            }
          }
          final content = ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: items,
          );

          if (widget.fromOnboarding && firstConversation != null && !_overlayCompleted) {
            return Stack(
              children: [
                content,
                Positioned.fill(
                  child: SimulatedFingerOverlay(
                    targetKey: _overlayTargetKey,
                    onComplete: () => _onOverlayComplete(firstConversation!),
                  ),
                ),
              ],
            );
          }
          return content;
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: EngrowthColors.error),
              const SizedBox(height: 16),
              Text(
                'エラー: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: EngrowthColors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// セクション: タイトル + 横スクロールの会話カード行（最大10件）
class _ScenarioSection extends StatelessWidget {
  final ScenarioCategory category;
  final IconData icon;
  final String? subTitle;
  final List<Conversation> conversations;
  final GlobalKey? overlayTargetKey;

  const _ScenarioSection({
    required this.category,
    required this.icon,
    this.subTitle,
    required this.conversations,
    this.overlayTargetKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subTitle != null
                      ? '${category.displayName} - $subTitle'
                      : category.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: conversations.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final useKey = overlayTargetKey != null && index == 0;
                    return Padding(
                      key: useKey ? overlayTargetKey : null,
                      padding: const EdgeInsets.only(right: 10),
                      child: _ScenarioConversationCard(
                        conversation: conversation,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? null
              : [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                '準備中',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 横スクロール用の会話カード（サムネイル + タイトル、タップで会話学習へ）
class _ScenarioConversationCard extends StatefulWidget {
  final Conversation conversation;

  const _ScenarioConversationCard({
    required this.conversation,
  });

  @override
  State<_ScenarioConversationCard> createState() => _ScenarioConversationCardState();
}

class _ScenarioConversationCardState extends State<_ScenarioConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildThumbnail() {
    final url = widget.conversation.thumbnailUrl;
    if (url != null && url.isNotEmpty) {
      return OptimizedImage(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      kScenarioBgAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        context.push('/conversation/${widget.conversation.id}?mode=listen');
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: 120,
          height: 135,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: Theme.of(context).brightness == Brightness.dark ? null : EngrowthShadows.softCard,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景画像
                _buildThumbnail(),
                // 下部グラデーション（テキスト可読性確保）
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // タイトル（画像上・下部）
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    widget.conversation.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
