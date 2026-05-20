import 'package:flutter/material.dart';

class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(180),
      child: Center(
        child: Container(
          width: 340,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Spielanleitung',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.white38, size: 18),
                ),
              ]),
              const SizedBox(height: 12),
              const _Section('Schnellstart'),
              const _Tip(icon: Icons.home_outlined, color: Color(0xFF4CAF50),
                  text: 'Wohnzone anlegen → nach 1-2 Ticks erscheinen Häuser'),
              const _Tip(icon: Icons.add_road, color: Color(0xFF90A4AE),
                  text: 'Straße AUF dieselbe Kachel → nötig für mittlere/große Gebäude'),
              const _Tip(icon: Icons.store_outlined, color: Color(0xFF2196F3),
                  text: 'Gewerbe & Industrie → generiert Einnahmen'),
              const SizedBox(height: 10),
              const _Section('Infrastruktur'),
              const _Tip(icon: Icons.power_outlined, color: Color(0xFFFFCC02),
                  text: 'Kraftwerk (\$5000) + Stromleitung → Strom-Abdeckung'),
              const _Tip(icon: Icons.water_damage_outlined, color: Color(0xFF00BCD4),
                  text: 'Wasserturm (\$3000) + Rohr → Wasser-Abdeckung'),
              const _Tip(icon: Icons.park_rounded, color: Color(0xFF00C853),
                  text: 'Parks (\$500) → verbessern Services-Zufriedenheit'),
              const _Tip(icon: Icons.school_outlined, color: Color(0xFFFF9800),
                  text: 'Schule (\$3500) → Bildung, Beschäftigung +'),
              const _Tip(icon: Icons.local_police_outlined, color: Color(0xFF1565C0),
                  text: 'Polizei (\$4000) → Kriminalität sinkt, Services +'),
              const _Tip(icon: Icons.local_hospital_outlined, color: Color(0xFFE53935),
                  text: 'Krankenhaus (\$6000) → Gesundheit, Services +'),
              const SizedBox(height: 10),
              const _Section('Wirtschaft'),
              const _Tip(icon: Icons.percent_outlined, color: Colors.white70,
                  text: 'Steuersätze: höher = mehr Einnahmen, langsamer Wachstum'),
              const _Tip(icon: Icons.account_balance, color: Colors.orangeAccent,
                  text: 'Kredit (Budget-Panel) wenn das Geld knapp wird'),
              const SizedBox(height: 10),
              const _Section('Spielziel'),
              const _Tip(icon: Icons.people, color: Colors.lightBlueAccent,
                  text: 'Bevölkerung wächst wenn Zufriedenheit > 50%'),
              const _Tip(icon: Icons.warning_amber, color: Colors.redAccent,
                  text: 'Game Over: Insolvenz < -\$5000 oder Zustimmung < 15%'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Los geht\'s!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}
