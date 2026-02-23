import 'dart:math' as math;

/// 正弦波ベースのx座標計算
/// 「4ステップで弧の頂点、次の4ステップで反対側に折り返す」周期
/// x = center + sin(i / 周期) × 振幅
const _period = 4.0; // 4ステップで頂点 → 8ステップで1サイクル（sinはπ/4刻みでπ/2ずつ = 4で頂点、8で一周）

/// ノードインデックスからx座標を算出
/// [index] グローバルノードインデックス（0始まり）
/// [centerX] 画面中央のx
/// [amplitude] 振幅（左右の振れ幅）
double nodeXAt(int index, double centerX, double amplitude) {
  return centerX + amplitude * math.sin(index * math.pi / _period);
}

/// ノードインデックスでのパス接線の傾き（dx/dy）
/// 区間どうしを滑らかにつなぐベジェの制御点計算に使用
double nodeSlopeAt(int index, double amplitude) {
  return amplitude * (math.pi / _period) * math.cos(index * math.pi / _period);
}

/// 周期定数（テスト・可視化用）
double get pathPeriod => _period;
