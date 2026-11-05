import 'package:flutter/material.dart';
import 'word_game_screen.dart';
import 'circuit_panic_solo_screen.dart';
import 'blind_negotiator_solo_screen.dart';

class SoloGamesMenuScreen extends StatelessWidget {
  const SoloGamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألعاب التحدي الفردي (ضد البوت)'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختر اللعبة التي تريد خوض تحديها بمفردك:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _buildGameCard(
              context: context,
              title: 'سارق الأفكار (Word Echo)',
              subtitle: 'تخاطر ذهني ومطابقة كلمات ذكية ضد معجم البوت',
              icon: Icons.lightbulb,
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordGameScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context: context,
              title: 'غرفة التحكم المشتركة (Circuit Panic)',
              subtitle: 'نمط "المشغل الخارق": سرعة تنفيذ الأوامر المتتالية لمنع الانفجار',
              icon: Icons.bolt,
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CircuitPanicSoloScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context: context,
              title: 'المفاوض الخفي (The Blind Negotiator)',
              subtitle: 'نمط "محقق الدهاء": صفقات وتبادل موارد وكشف البوت المخرب',
              icon: Icons.vpn_key,
              color: Colors.deepPurpleAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlindNegotiatorSoloScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}
