// TTS URL のアクセス可否を確認し、結果をファイルに出力
// 使い方:
//   dart run scripts/check_tts_url.dart
//   dart run scripts/check_tts_url.dart "https://...mp3"
// 結果: check_tts_result.txt に出力 → AI に @check_tts_result.txt で確認依頼

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty
      ? args.first
      : 'https://munemrzmgaitfeejrtns.supabase.co/storage/v1/object/public/tts-audio/b89de9412dc11095550971a6fde28782a4abf5e9555abce167f0f1b07457bf49.mp3';

  final out = StringBuffer();
  out.writeln('TTS URL 確認結果');
  out.writeln('Generated: ${DateTime.now().toIso8601String()}');
  out.writeln('');
  out.writeln('URL: $url');
  out.writeln('');

  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', '*/*');
    final response = await request.close();

    out.writeln('Status: ${response.statusCode}');
    out.writeln('Reason: ${response.reasonPhrase}');
    if (response.headers.contentLength != null) {
      out.writeln('Content-Length: ${response.headers.contentLength}');
    }
    out.writeln('');
    out.writeln(response.statusCode == 200 ? 'OK: ファイルは取得可能です' : 'NG: ${response.statusCode}');
  } catch (e, st) {
    out.writeln('Error: $e');
    out.writeln('');
    out.writeln('Stack: $st');
  }

  final resultPath = 'check_tts_result.txt';
  await File(resultPath).writeAsString(out.toString(), encoding: utf8);
  print('結果を $resultPath に保存しました');
  print(out.toString());
}
