import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../providers/anonymous_conversion_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../services/auth_service.dart';
import '../theme/engrowth_theme.dart';

/// アカウント画面
/// 匿名時: アカウント作成（リンク）・ログイン
/// ログイン済み: メール表示・ログアウト
class AccountScreen extends ConsumerStatefulWidget {
  final String? initialProvider;

  const AccountScreen({super.key, this.initialProvider});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: EngrowthElementTokens.switchDuration,
    );
    if (widget.initialProvider == 'google') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(0);
          _signInWithGoogle();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _linkAnonymous() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'メールアドレスとパスワードを入力してください');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'パスワードは6文字以上にしてください');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.linkAnonymousToPermanent(email: email, password: password);
      if (mounted) {
        await ref.read(anonymousConversionProvider.notifier).resetOnConversion();
        ref.read(analyticsServiceProvider).logAnonToRegisteredSuccess();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アカウントを作成しました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _formatAuthError(e);
        });
      }
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'メールアドレスとパスワードを入力してください');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'パスワードは6文字以上にしてください');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(email: email, password: password);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('確認メールを送信しました。メール内のリンクから登録を完了してください')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _formatAuthError(e);
        });
      }
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'メールアドレスとパスワードを入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(email: email, password: password);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログインしました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _formatAuthError(e);
        });
      }
    }
  }

  Future<void> _signOut() async {
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      // サインアウト後は匿名ユーザーとして再サインイン（アプリを継続利用可能に）
      await _authService.ensureSignedIn();
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログアウトしました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ログアウトに失敗しました';
        });
      }
    }
  }

  String _formatAuthError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'メールアドレスまたはパスワードが正しくありません';
    }
    if (msg.contains('Email not confirmed')) {
      return 'メールアドレスの確認が完了していません。確認メールのリンクをクリックしてください';
    }
    if (msg.contains('already registered')) {
      return 'このメールアドレスは既に登録されています。ログインをお試しください';
    }
    if (msg.contains('Manual linking') || msg.contains('manual linking')) {
      return 'Google連携には Supabase で「Manual linking」の有効化が必要です。ダッシュボードで有効化済みの場合は、しばらく待ってから再試行してください。';
    }
    if (msg.contains('redirect') && msg.contains('url')) {
      return 'リダイレクトURLの設定を確認してください。Supabase の Authentication > URL Configuration にこのアプリのURLを追加してください。';
    }
    return msg.length > 80 ? '${msg.substring(0, 80)}...' : msg;
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymous = ref.watch(isAnonymousProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
        bottom: isAnonymous
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'アカウント作成'),
                  Tab(text: 'ログイン'),
                ],
              )
            : null,
      ),
      body: isAnonymous ? _buildAnonymousBody() : _buildSignedInBody(user),
    );
  }

  Widget _buildAnonymousBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLinkForm(),
        _buildSignInForm(),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    final wasAnonymous = ref.read(isAnonymousProvider);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        setState(() => _isLoading = false);
        if (wasAnonymous) {
          await ref.read(anonymousConversionProvider.notifier).resetOnConversion();
          ref.read(analyticsServiceProvider).logAnonToRegisteredSuccess();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(wasAnonymous ? 'Googleでアカウントを作成しました' : 'ログインしました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _formatAuthError(e);
        });
      }
    }
  }

  Widget _buildLinkForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '学習記録を保存するにはアカウントを作成してください。',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 22),
            label: const Text('Googleでアカウントを作成'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'または',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _linkAnonymous,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('アカウントを作成'),
          ),
          const SizedBox(height: 32),
          _buildThemeSetting(),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    final current = ref.watch(themeModeProvider);
    final themeMode = current ?? ThemeMode.system;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6_outlined, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(
                  '表示',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('端末に合わせる'),
                  icon: Icon(Icons.brightness_auto, size: 18),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('ライト'),
                  icon: Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('ダーク'),
                  icon: Icon(Icons.dark_mode, size: 18),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<ThemeMode> selected) {
                ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '既にアカウントをお持ちの方はこちら',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 22),
            label: const Text('Googleでログイン'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'または',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _signIn,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ログイン'),
          ),
          const SizedBox(height: 32),
          _buildThemeSetting(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'メールアドレス',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email_outlined),
      ),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'パスワード',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildSignedInBody(dynamic user) {
    final email = user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email.isNotEmpty ? email : 'ログイン中',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (email.isEmpty)
                              Text(
                                'メール未設定',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildThemeSetting(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signOut,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('ログアウト'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
