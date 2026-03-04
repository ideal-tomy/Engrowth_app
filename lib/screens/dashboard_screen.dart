import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/engrowth_theme.dart';
import '../providers/user_stats_provider.dart';
import '../providers/user_plan_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/ui_experiments_provider.dart';
import '../providers/home_primary_cta_provider.dart';
import '../widgets/dashboard_sections/anonymous_data_save_banner.dart';
import '../widgets/dashboard_sections/anonymous_lp_banner.dart';
import '../widgets/dashboard_sections/coach_banner.dart';
import '../widgets/dashboard_sections/consultant_notification_banner.dart';
import '../widgets/dashboard_sections/daily_report_card.dart';
import '../widgets/dashboard_sections/onboarding_banner.dart';
import '../widgets/marquee/header_marquee_rail.dart';
import '../widgets/dashboard_sections/todays_mission_card.dart';
import '../widgets/dashboard_sections/quick_action_fab.dart';
import '../widgets/dashboard_sections/startup_shortcut_overlay.dart';
import '../widgets/common/stagger_reveal.dart';

/// Dashboard（Home タブ）
/// ヘッダー／再開カード／4x2アイコングリッドをコンパクトに表示
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hasRecordedImpression = false;

  @override
  Widget build(BuildContext context) {
    if (!_hasRecordedImpression) {
      _hasRecordedImpression = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homePrimaryCtaProvider.notifier).recordImpression();
      });
    }
    final authStage = ref.watch(authStageProvider);
    final userPlan = ref.watch(userPlanProvider);

    final enableMarquee = ref.watch(enableMarqueeRailProvider);

    return Scaffold(
      drawer: const _SettingsDrawer(),
      floatingActionButton: const QuickActionFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StartupShortcutOverlay(
        child: SafeArea(
          child: Column(
          children: [
            _DashboardHeader(),
            if (enableMarquee) ...[
              const HeaderMarqueeRail(),
              const SizedBox(height: 4),
            ],
            Expanded(
              child: SingleChildScrollView(
                primary: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StaggerReveal(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const OnboardingBanner(),
                        const SizedBox(height: 6),
                        if (authStage == AuthStage.anonymous) ...[
                          const AnonymousDataSaveBanner(),
                          const SizedBox(height: 6),
                        ],
                        if (userPlan == UserPlan.coaching) ...[
                          const CoachBanner(),
                          const SizedBox(height: 6),
                          const TodaysMissionCard(),
                          const SizedBox(height: 6),
                        ],
                        const DailyReportCard(),
                        const SizedBox(height: 6),
                        const _OnboardingHandoffBanner(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _SectionLabel(label: 'その他の機能'),
                        const SizedBox(height: 4),
                        const _MainTilesGrid(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 14),
                        if (authStage == AuthStage.anonymous) ...[
                          const AnonymousLpBanner(),
                          const SizedBox(height: 6),
                        ],
                        if (authStage == AuthStage.signedIn ||
                            authStage == AuthStage.coaching) ...[
                          const ConsultantNotificationBanner(),
                          const SizedBox(height: 6),
                        ],
                        const SizedBox(height: 88),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    ref.read(feedbackServiceProvider).selection(trigger: 'dashboard_menu_selection');
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: '設定',
                  color: colorScheme.onSurface,
                ),
                const Spacer(),
                Text(
                  'Engrowth',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        color: colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                statsAsync.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '\u{1F525}',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.streakCount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(width: 40, height: 24),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F525}', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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

class _OnboardingHandoffBanner extends ConsumerStatefulWidget {
  const _OnboardingHandoffBanner();

  @override
  ConsumerState<_OnboardingHandoffBanner> createState() =>
      _OnboardingHandoffBannerState();
}

class _OnboardingHandoffBannerState extends ConsumerState<_OnboardingHandoffBanner> {
  bool _hasLoggedShown = false;

  @override
  Widget build(BuildContext context) {
    final handoffPending = ref.watch(onboardingHandoffPendingProvider);
    if (!handoffPending) return const SizedBox.shrink();

    if (!_hasLoggedShown) {
      _hasLoggedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analyticsServiceProvider).logOnboardingHomeHandoffShown();
      });
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '右下の＋ボタンをタップして学習を始めよう',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainTilesGrid extends ConsumerWidget {
  const _MainTilesGrid();

  static const _baseItems = [
    _GridItem('conversation_training', '会話トレーニング', Icons.record_voice_over, '/conversation-training'),
    _GridItem('word_search', '単語検索', Icons.search, '/words'),
    _GridItem('pattern_sprint', 'パターンスプリント', Icons.speed, '/pattern-sprint'),
    _GridItem('sentences', 'センテンス一覧', Icons.format_list_bulleted, '/sentences'),
    _GridItem('progress', '学習進捗', Icons.bar_chart, '/progress'),
    _GridItem('favorites', 'お気に入り', Icons.favorite_border, '/favorites'),
    _GridItem('review', '本日の復習', Icons.history, '/review'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStage = ref.watch(authStageProvider);
    final showRecordings =
        authStage == AuthStage.signedIn || authStage == AuthStage.coaching;
    final items = [
      ..._baseItems,
      if (showRecordings) const _GridItem('recordings', '録音履歴', Icons.mic, '/recordings'),
      const _GridItem('settings', '設定', Icons.settings, 'drawer'),
    ];
    final width = MediaQuery.of(context).size.width - 24;
    final tileWidth = (width - 12) / 4;
    final tileHeight = tileWidth / 0.9;

    return SizedBox(
      height: tileHeight * 2 + 12,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.9,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MainTile(
            title: item.title,
            icon: item.icon,
            onTap: () {
              ref.read(feedbackServiceProvider).selection(trigger: 'dashboard_mainTile_selection');
              ref.read(homePrimaryCtaProvider.notifier).maybeRecordRecognized('main_tile');
              ref.read(analyticsServiceProvider).logMainTileTap(
                    tileId: item.tileId,
                    destination: item.route,
                    authStage: authStage.name,
                    rank: index + 1,
                  );
              if (item.route == 'drawer') {
                Scaffold.of(context).openDrawer();
              } else if (item.route == '/progress' || item.route == '/words') {
                context.go(item.route);
              } else if (item.route == '/sentences') {
                context.push(item.route);
              } else if (item.route == '/favorites') {
                context.push('/favorites');
              } else if (item.route == '/recordings') {
                context.push('/recordings');
              } else {
                context.push(item.route);
              }
            },
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _GridItem {
  final String tileId;
  final String title;
  final IconData icon;
  final String route;

  const _GridItem(this.tileId, this.title, this.icon, this.route);
}

class _MainTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MainTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? null
                : EngrowthShadows.softCard,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDrawer extends ConsumerWidget {
  const _SettingsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devViewAsSignedIn = ref.watch(devViewAsSignedInProvider);
    final authStage = ref.watch(authStageProvider);
    final isConsultant = ref.watch(isConsultantProvider).valueOrNull ?? false;
    final isAdmin = ref.watch(isAdminProvider);

    final isSignedIn =
        authStage == AuthStage.signedIn || authStage == AuthStage.coaching;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '設定',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (kDebugMode) ...[
              SwitchListTile(
                secondary: const Icon(Icons.bug_report_outlined),
                title: const Text('開発: ログイン済み画面'),
                subtitle: const Text('匿名のままログイン後UIを表示'),
                value: devViewAsSignedIn,
                onChanged: (_) {
                  ref.read(devViewAsSignedInProvider.notifier).toggle();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.person_search_outlined),
                title: const Text('開発: コンサルタント'),
                subtitle: const Text('講師用メニューを表示'),
                value: ref.watch(devViewAsConsultantProvider),
                onChanged: (_) {
                  ref.read(devViewAsConsultantProvider.notifier).toggle();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('開発: 管理者'),
                subtitle: const Text('管理者メニューを表示'),
                value: ref.watch(devViewAsAdminProvider),
                onChanged: (_) {
                  ref.read(devViewAsAdminProvider.notifier).toggle();
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('開発: 初回体験をリセット'),
                subtitle: const Text('初回体験フローを再表示'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(onboardingCompleteNotifierProvider).reset();
                  ref.invalidate(onboardingCompletedProvider);
                  if (context.mounted) context.push('/onboarding');
                },
              ),
              const Divider(),
            ],
            if (!isSignedIn)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('データ保存について'),
                onTap: () {
                  Navigator.pop(context);
                  _showDataSaveInfo(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(isSignedIn ? 'アカウント' : 'アカウント作成'),
              onTap: () {
                Navigator.pop(context);
                context.push('/account');
              },
            ),
            if (isSignedIn)
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('録音履歴'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/recordings');
                },
              ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('2秒ヒントの秒数設定'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hint-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('音声再生速度'),
              onTap: () {
                Navigator.pop(context);
                context.push('/playback-speed-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('使い方'),
              onTap: () {
                Navigator.pop(context);
                context.push('/help');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Engrowthが選ばれる理由'),
              onTap: () {
                Navigator.pop(context);
                context.push('/concept');
              },
            ),
            if (isSignedIn)
              ListTile(
                leading: const Icon(Icons.contact_support_outlined),
                title: const Text('担当コンサルタントへ連絡'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/consultant-contact');
                },
              ),
            if (isConsultant) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('講師用ダッシュボード'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/consultant');
                },
              ),
            ],
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('管理者ダッシュボード'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin');
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                'ログアウト',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDataSaveInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('データ保存について'),
        content: const Text(
          '学習記録を永続的に保存するにはアカウントの作成が必要です。\n\n'
          'アカウント作成後は、録音履歴・学習進捗・復習データを複数端末で同期して利用できます。',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              context.push('/account');
              Navigator.of(ctx).pop();
            },
            child: const Text('アカウント作成'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // 必要であればログイン画面へ
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトに失敗しました: $e')),
        );
      }
    }
  }
}
