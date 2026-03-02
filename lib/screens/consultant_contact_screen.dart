import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../services/consultant_contact_service.dart';
import '../theme/engrowth_theme.dart';

/// B15: 担当コンサルタントへ連絡・報告ハブ
class ConsultantContactScreen extends ConsumerStatefulWidget {
  final String? initialReportType;
  final String? relatedSubmissionId;

  const ConsultantContactScreen({
    super.key,
    this.initialReportType,
    this.relatedSubmissionId,
  });

  @override
  ConsumerState<ConsultantContactScreen> createState() =>
      _ConsultantContactScreenState();
}

class _ConsultantContactScreenState extends ConsumerState<ConsultantContactScreen> {
  List<String>? _consultantIds;
  bool _loading = true;
  String? _error;
  late String _selectedReportType;
  final _messageController = TextEditingController();
  bool _sending = false;

  static const _reportTypes = [
    _ReportType('today_submitted', '今日の提出報告', Icons.check_circle_outline),
    _ReportType('consultation', '相談したいこと', Icons.chat_bubble_outline),
    _ReportType('question', '質問', Icons.help_outline),
    _ReportType('other', 'その他', Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ConsultantContactService();
      final ids = await service.getAssignedConsultantIds();
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logConsultantContactOpened(
            hasConsultant: ids.isNotEmpty,
          );
      setState(() {
        _consultantIds = ids;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _sendInAppReport() async {
    final ids = _consultantIds;
    if (ids == null || ids.isEmpty) return;
    final consultantId = ids.first;
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メッセージを入力してください')),
      );
      return;
    }
    setState(() => _sending = true);
    ref.read(analyticsServiceProvider).logConsultantContactChannelSelected(
          channel: 'in_app',
        );
    try {
      final service = ConsultantContactService();
      await service.sendReport(
        consultantId: consultantId,
        reportType: _selectedReportType,
        message: message,
        relatedSubmissionId: widget.relatedSubmissionId,
      );
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logConsultantContactMessageSent(
            channel: 'in_app',
            reportType: _selectedReportType,
          );
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('報告を送信しました')),
      );
    } catch (e) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logConsultantContactMessageFailed(
            channel: 'in_app',
            reason: e.toString(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('送信に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onExternalChannelTap(String channel) {
    ref.read(analyticsServiceProvider).logConsultantContactChannelSelected(
          channel: channel,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$channel 連携は準備中です。アプリ内報告をご利用ください。'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('担当コンサルタントへ連絡'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text('読み込みエラー: $_error'),
                      ],
                    ),
                  ),
                )
              : _consultantIds == null || _consultantIds!.isEmpty
                  ? _buildNoConsultantFallback(colorScheme)
                  : _buildContactHub(colorScheme),
    );
  }

  Widget _buildNoConsultantFallback(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.contact_support_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '担当コンサルタントが割り当てられていません',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '担当割当は管理者が行います。ご不明な点はサポートまでお問い合わせください。',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactHub(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '担当コンサルタント',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'アプリ内で報告・相談ができます',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '連絡チャネル',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _ChannelChip(
                label: 'アプリ内報告',
                icon: Icons.chat_bubble_outline,
                selected: true,
                onTap: () {},
              ),
              _ChannelChip(
                label: 'LINE',
                icon: Icons.chat,
                selected: false,
                onTap: () => _onExternalChannelTap('line'),
              ),
              _ChannelChip(
                label: 'LINE WORKS',
                icon: Icons.business_center,
                selected: false,
                onTap: () => _onExternalChannelTap('line_works'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'クイック報告',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._reportTypes.map((e) => RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(e.icon, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(e.label),
                  ],
                ),
                value: e.id,
                groupValue: _selectedReportType,
                onChanged: (v) => setState(() => _selectedReportType = v!),
              )),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'メッセージを入力...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _sending ? null : _sendInAppReport,
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_sending ? '送信中...' : '送信'),
          ),
        ],
      ),
    );
  }
}

class _ReportType {
  final String id;
  final String label;
  final IconData icon;
  const _ReportType(this.id, this.label, this.icon);
}

class _ChannelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? colorScheme.onPrimary : colorScheme.onSurface),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
