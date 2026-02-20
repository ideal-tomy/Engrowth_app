import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/engrowth_theme.dart';
import 'word_detail_sheet.dart';

/// 3カラムグリッド用のコンパクト単語タイル
/// タップで詳細ハーフシートを表示
///
/// 注意: カードの「縦の高さ」は親の GridView の [childAspectRatio] で決まります。
/// Flutter では親が子にレイアウト制約を渡すため、このウィジェット内の padding だけでは
/// セル全体の高さは変わりません。高さを変える場合は word_list_accordion の gridDelegate を編集してください。
class WordTile extends StatelessWidget {
  final Word word;

  const WordTile({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: () => WordDetailSheet.show(context, word),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.volume_up_outlined,
                size: 16,
                color: EngrowthColors.primary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
