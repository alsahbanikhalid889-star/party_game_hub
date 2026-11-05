import 'dart:math';
import 'package:flutter/material.dart';

class BlindNegotiatorSoloScreen extends StatefulWidget {
  const BlindNegotiatorSoloScreen({super.key});

  @override
  State<BlindNegotiatorSoloScreen> createState() => _BlindNegotiatorSoloScreenState();
}

class _BlindNegotiatorSoloScreenState extends State<BlindNegotiatorSoloScreen> {
  int playerGold = 10;
  int round = 1;
  final int maxRounds = 3;

  // البوتات الثلاثة وأحدهم مخرب سري
  late int saboteurIndex;
  final List<String> botNames = ['العميل طارق (حذر)', 'العميل زياد (مغامر)', 'العميل فهد (هادئ)'];
  String negotiationLog = 'بدأت الجولة! اختر شخصاً للتفاوض معه وتبادل الصفقات.';

  @override
  void initState() {
    super.initState();
    saboteurIndex = Random().nextInt(3); // اختيار عشوائي للمخرب
  }

  void _negotiateWithBot(int botIndex) {
    if (round > maxRounds) return;

    setState(() {
      if (botIndex == saboteurIndex) {
        // المخرب يسرق منك الذهب
        playerGold = max(0, playerGold - 3);
        negotiationLog = 'صفقة خاسرة! ${botNames[botIndex]} غدر بك وسرق منك 3 قطع ذهب!';
      } else {
        // البوت الصادق يربحك ذهباً
        playerGold += 4;
        negotiationLog = 'صفقة ناجحة! عقدت شراكة رابحة مع ${botNames[botIndex]} وربحت 4 قطع ذهب.';
      }
      round++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفاوض الخفي (فردي)'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('رصيدك من الذهب', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$playerGold 💰', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('الجولة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$round من $maxRounds', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF282844),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                negotiationLog,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            if (round <= maxRounds) ...[
              const Text('اختر شخصية لإتمام صفقة معها (أحدهم مخرب متنكر!):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(botNames.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    onPressed: () => _negotiateWithBot(i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('عقد صفقة مع: ${botNames[i]}', style: const TextStyle(fontSize: 15)),
                  ),
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('انتهت الجولات!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                    const SizedBox(height: 8),
                    Text('المخرب السري كان: ${botNames[saboteurIndex]}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('الرصيد النهائي: $playerGold قطعة ذهب', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    round = 1;
                    playerGold = 10;
                    saboteurIndex = Random().nextInt(3);
                    negotiationLog = 'بدأت اللعبة من جديد!';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('إعادة التحدي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
