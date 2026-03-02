import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marquee導線（ヘッダー・フッター上レール）は常時表示
/// 本番・ローカルともにトグルなしで常時表示
final enableMarqueeRailProvider = Provider<bool>((ref) => true);
