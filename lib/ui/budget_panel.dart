import 'package:city_builder/core/game_model.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetPanel extends ConsumerWidget {
  const BudgetPanel({super.key, required this.model, required this.onClose});

  final GameModel model;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eco = model.lastEconomy;
    final pop = model.population;
    final approval = model.approvalRating;
    final sat = model.satisfaction;
    final notifier = ref.read(gameProvider.notifier);

    return Container(
      width: 240,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('Finanzen',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close,
                    color: Colors.white38, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Budget
          _BigValue(
            label: 'Kassenstand',
            value: '\$${model.budget.toStringAsFixed(0)}',
            color: model.budget > 0 ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(height: 8),

          // Income/Expenses
          _Row(label: 'Einnahmen/Tick',
              value: '+\$${eco.taxIncome.toStringAsFixed(1)}',
              color: Colors.greenAccent),
          _Row(label: 'Ausgaben/Tick',
              value: '-\$${eco.operatingCosts.toStringAsFixed(1)}',
              color: Colors.redAccent),
          _Row(
            label: 'Bilanz/Tick',
            value: '${eco.netBalance >= 0 ? "+" : ""}\$${eco.netBalance.toStringAsFixed(1)}',
            color: eco.netBalance >= 0 ? Colors.greenAccent : Colors.redAccent,
          ),
          if (eco.netBalance < 0) ...[
            _Row(
              label: 'Insolvenz in',
              value: _ticksToBankruptcy(model.budget, eco.netBalance),
              color: Colors.orangeAccent,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Population
          _Row(label: 'Einwohner', value: '${pop.total}', color: Colors.lightBlueAccent),
          _Row(label: 'Kapazität', value: '${pop.capacity}', color: Colors.white38),
          _Row(
            label: 'Zustimmung',
            value: '${(approval * 100).toInt()}%',
            color: approval > 0.6
                ? Colors.greenAccent
                : approval > 0.35
                    ? Colors.orangeAccent
                    : Colors.redAccent,
          ),

          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Infrastructure coverage
          const Text('Infrastruktur',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          _Row(label: 'Gebäude', value: '${model.infraStats.buildings}', color: Colors.white70),
          _Row(label: 'Straße', value: '${model.infraStats.roadPct}%', color: const Color(0xFF90A4AE)),
          _Row(label: 'Strom', value: '${model.infraStats.powerPct}%', color: const Color(0xFFFFEE58)),
          _Row(label: 'Wasser', value: '${model.infraStats.waterPct}%', color: const Color(0xFF42A5F5)),
          _Row(label: 'Parks', value: '${model.infraStats.parks}', color: const Color(0xFF00C853)),
          if (model.infraStats.policeStations > 0)
            _Row(label: 'Polizei', value: '${model.infraStats.policeStations}', color: const Color(0xFF1565C0)),
          if (model.infraStats.hospitals > 0)
            _Row(label: 'Krankenh.', value: '${model.infraStats.hospitals}', color: const Color(0xFFE53935)),
          if (model.infraStats.schools > 0)
            _Row(label: 'Schulen', value: '${model.infraStats.schools}', color: const Color(0xFFFF9800)),

          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Satisfaction factors
          const Text('Zufriedenheit',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          _SatisfactionBar(label: 'Arbeit', value: sat.employment, color: const Color(0xFFFF9800)),
          _SatisfactionBar(label: 'Wohnen', value: sat.housing, color: const Color(0xFF4CAF50)),
          _SatisfactionBar(label: 'Services', value: sat.services, color: const Color(0xFF2196F3)),

          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Loan
          _Row(
            label: 'Kredit',
            value: '\$${model.loan.toStringAsFixed(0)}',
            color: model.loan > 0 ? Colors.orangeAccent : Colors.white38,
          ),
          if (model.loan > 0)
            _Row(
              label: 'Zinsen/Tick',
              value: '-\$${(model.loan * GameModel.loanInterestRate).toStringAsFixed(1)}',
              color: Colors.orangeAccent,
            ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: _LoanButton(
                label: '+\$${GameModel.loanChunkSize.toInt()}',
                enabled: model.loan < GameModel.maxLoan,
                color: Colors.orangeAccent,
                onTap: () => notifier.takeLoan(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LoanButton(
                label: 'Zurückzahlen',
                enabled: model.loan > 0 &&
                    model.budget >= GameModel.loanChunkSize,
                color: Colors.greenAccent,
                onTap: () => notifier.repayLoan(),
              ),
            ),
          ]),

          // Budget sparkline
          if (model.budgetHistory.length > 1) ...[
            const SizedBox(height: 8),
            _BudgetSparkline(history: model.budgetHistory),
          ],

          // Trend sparkline
          if (pop.history.length > 1) ...[
            const SizedBox(height: 8),
            _PopulationSparkline(history: pop.history),
          ],
        ],
      ),
    );
  }
}

class _BigValue extends StatelessWidget {
  const _BigValue(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ],
      );
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11))),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

String _ticksToBankruptcy(double budget, double netPerTick) {
  if (netPerTick >= 0) return '∞';
  final ticks = ((budget - GameModel.gameOverBudgetThreshold) / (-netPerTick)).ceil();
  if (ticks <= 0) return 'jetzt!';
  if (ticks > 9999) return '>9999 Ticks';
  return '~$ticks Ticks';
}

class _LoanButton extends StatelessWidget {
  const _LoanButton({
    required this.label,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: enabled ? color.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: enabled ? color.withAlpha(150) : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? color : Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}

class _BudgetSparkline extends StatelessWidget {
  const _BudgetSparkline({required this.history});
  final List<double> history;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget (Verlauf)',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: CustomPaint(
              painter: _BudgetSparklinePainter(history),
              size: const Size(double.infinity, 32),
            ),
          ),
        ],
      );
}

class _BudgetSparklinePainter extends CustomPainter {
  _BudgetSparklinePainter(this.data);
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = maxV - minV;
    if (range == 0) return;

    final positivePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final negativePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw zero line
    if (minV < 0 && maxV > 0) {
      final zy = size.height - ((0 - minV) / range) * size.height;
      canvas.drawLine(Offset(0, zy), Offset(size.width, zy),
          Paint()..color = Colors.white12..strokeWidth = 0.5);
    }

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minV) / range) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, data.last >= 0 ? positivePaint : negativePaint);
  }

  @override
  bool shouldRepaint(covariant _BudgetSparklinePainter old) =>
      old.data != data;
}

class _SatisfactionBar extends StatelessWidget {
  const _SatisfactionBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class _PopulationSparkline extends StatelessWidget {
  const _PopulationSparkline({required this.history});
  final List<int> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bevölkerung (Verlauf)',
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        SizedBox(
          height: 32,
          child: CustomPaint(
            painter: _SparklinePainter(history),
            size: const Size(double.infinity, 32),
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.data);
  final List<int> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max == 0) return;

    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - (data[i] / max) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.data != data;
}
