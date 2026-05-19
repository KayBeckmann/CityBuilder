import 'dart:math';

/// Simplex-Noise-Implementierung (2D) nach Stefan Gustavson.
/// Deterministisch durch Seed.
class SimplexNoise {
  SimplexNoise(int seed) : _perm = _buildPerm(seed);

  final List<int> _perm;

  static const _f2 = 0.366025403;
  static const _g2 = 0.211324865;

  static final _grad3 = <List<double>>[
    [1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0],
    [1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1],
    [0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1],
  ];

  static List<int> _buildPerm(int seed) {
    final rng = Random(seed);
    final p = List<int>.generate(256, (i) => i)..shuffle(rng);
    return [...p, ...p];
  }

  double noise(double xin, double yin) {
    final s = (xin + yin) * _f2;
    final i = (xin + s).floor();
    final j = (yin + s).floor();
    final t = (i + j) * _g2;
    final x0 = xin - (i - t);
    final y0 = yin - (j - t);

    final int i1, j1;
    if (x0 > y0) {
      i1 = 1;
      j1 = 0;
    } else {
      i1 = 0;
      j1 = 1;
    }

    final x1 = x0 - i1 + _g2;
    final y1 = y0 - j1 + _g2;
    final x2 = x0 - 1.0 + 2.0 * _g2;
    final y2 = y0 - 1.0 + 2.0 * _g2;

    final ii = i & 255;
    final jj = j & 255;

    final gi0 = _perm[ii + _perm[jj]] % 12;
    final gi1 = _perm[ii + i1 + _perm[jj + j1]] % 12;
    final gi2 = _perm[ii + 1 + _perm[jj + 1]] % 12;

    double n0 = 0.0, n1 = 0.0, n2 = 0.0;

    var t0 = 0.5 - x0 * x0 - y0 * y0;
    if (t0 >= 0) {
      t0 *= t0;
      n0 = t0 * t0 * _dot2(_grad3[gi0], x0, y0);
    }

    var t1 = 0.5 - x1 * x1 - y1 * y1;
    if (t1 >= 0) {
      t1 *= t1;
      n1 = t1 * t1 * _dot2(_grad3[gi1], x1, y1);
    }

    var t2 = 0.5 - x2 * x2 - y2 * y2;
    if (t2 >= 0) {
      t2 *= t2;
      n2 = t2 * t2 * _dot2(_grad3[gi2], x2, y2);
    }

    return 70.0 * (n0 + n1 + n2);
  }

  static double _dot2(List<double> g, double x, double y) =>
      g[0] * x + g[1] * y;

  double octave(double x, double y, {int octaves = 6, double persistence = 0.5}) {
    double value = 0;
    double amplitude = 1;
    double frequency = 1;
    double maxValue = 0;

    for (var i = 0; i < octaves; i++) {
      value += noise(x * frequency, y * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }

    return value / maxValue;
  }
}
