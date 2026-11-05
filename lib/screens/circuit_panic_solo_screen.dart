import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CircuitPanicSoloScreen extends StatefulWidget {
  const CircuitPanicSoloScreen({super.key});

  @override
  State<CircuitPanicSoloScreen> createState() => _CircuitPanicSoloScreenState();
}

class _CircuitPanicSoloScreenState extends State<CircuitPanicSoloScreen> {
  final List<String> buttonLabels = [
    'المفاعل A', 'المفاعل B', 'صمام الأمان',
    'توربين 1', 'ضاغط الهواء', 'مفتاح الطوارئ',
    'صمام التبريد', 'شحن الطاقة', 'إلغاء القفل'
  ];

  late String targetAction;
  int score = 0;
  double timeLeft = 4.0;
  Timer? timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNextOrder();
  }

  void _startNextOrder() {
    final rand = Random();
    targetAction = buttonLabels[rand.nextInt(buttonLabels.length)];
    timeLeft = max(1.8, 4.0 - (score * 0.15));

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (timeLeft > 0.1) {
        setState(() {
          timeLeft -= 0.1;
        });
      } else {
        _triggerGameOver();
      }
    });
  }

  void _triggerGameOver() {
    timer?.cancel();
    setState(() {
      isGameOver = true;
    });
  }

  void _onButtonPressed(String label) {
    if (isGameOver) return;

    if (label == targetAction) {
      setState(() {
        score++;
      });
      _startNextOrder();
    } else {
      _triggerGameOver();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('غرفة التحكم (فردي)'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isGameOver ? _buildGameOverUI() : _buildGameplayUI(),
      ),
    );
  }

  Widget _buildGameplayUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('النقاط: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            Text('${timeLeft.toStringAsFixed(1)} ثانية', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: timeLeft / 4.0,
          backgroundColor: Colors.white12,
          color: timeLeft < 1.5 ? Colors.redAccent : Colors.tealAccent,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Text('الأمر الفوري المطلوب منك:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                'اضغط فوراً على: "$targetAction"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('لوحة التحكم المركزية:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: buttonLabels.length,
            itemBuilder: (context, index) {
              final label = buttonLabels[index];
              return ElevatedButton(
                onPressed: () => _onButtonPressed(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF282844),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(4),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, size: 60, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('انفجرت المحطة!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 8),
            Text('تمكنت من تنفيذ $score أوامر صحيحة قبل نفاد الوقت', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  score = 0;
                  isGameOver = false;
                });
                _startNextOrder();
              },
              icon: const Icon(Icons.replay, color: Colors.white),
              label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
