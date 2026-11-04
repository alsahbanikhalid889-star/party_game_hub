import 'dart:async';
import 'package:flutter/material.dart';
import '../models/word_game_data.dart';
import '../utils/text_normalizer.dart';

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  late TopicItem currentTopic;
  final TextEditingController _word1Controller = TextEditingController();
  final TextEditingController _word2Controller = TextEditingController();
  final TextEditingController _word3Controller = TextEditingController();

  int timeLeft = 40;
  Timer? gameTimer;
  bool roundFinished = false;

  List<String> botWords = [];
  List<String> matchedWords = [];
  int calculatedScore = 0;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      currentTopic = WordGameBank.getRandomTopic();
      _word1Controller.clear();
      _word2Controller.clear();
      _word3Controller.clear();
      matchedWords.clear();
      botWords.clear();
      calculatedScore = 0;
      timeLeft = 40;
      roundFinished = false;
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _finishRound();
      }
    });
  }

  void _finishRound() {
    gameTimer?.cancel();

    List<String> playerWords = [
      _word1Controller.text.trim(),
      _word2Controller.text.trim(),
      _word3Controller.text.trim(),
    ].where((w) => w.isNotEmpty).toList();

    botWords = WordGameBank.getBotPicks(currentTopic);

    // التحقق من التطابق باستخدام خوارزمية التشابه والتنظيف
    List<String> matches = [];
    for (var pWord in playerWords) {
      for (var bWord in botWords) {
        if (TextNormalizer.areWordsMatching(pWord, bWord)) {
          matches.add('$pWord ~ $bWord');
          break;
        }
      }
    }

    setState(() {
      matchedWords = matches;
      calculatedScore = matches.length * 10;
      roundFinished = true;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _word1Controller.dispose();
    _word2Controller.dispose();
    _word3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سارق الأفكار (ضد البوت)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الموضوع والمؤقت
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الموضوع الحالي:', style: TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$timeLeft ثانية',
                            style: TextStyle(
                              color: timeLeft < 10 ? Colors.redAccent : Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentTopic.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentTopic.hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!roundFinished) ...[
              const Text('اكتب 3 كلمات تتوقع أن يفكر بها خصمك:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInputField(_word1Controller, 'الكلمة الأولى'),
              const SizedBox(height: 10),
              _buildInputField(_word2Controller, 'الكلمة الثانية'),
              const SizedBox(height: 10),
              _buildInputField(_word3Controller, 'الكلمة الثالثة'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _finishRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تأكيد وإرسال الكلمات', style: TextStyle(fontSize: 16)),
              ),
            ] else ...[
              // شاشة النتائج والمقارنة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'النقاط المكتسبة: $calculatedScore',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const Text('كلمات البوت (الذكاء الاصطناعي):', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: botWords.map((w) => Chip(label: Text(w), backgroundColor: Colors.deepPurple)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'التطابقات المحسوبة (${matchedWords.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (matchedWords.isEmpty)
                      const Text('لم يحدث تخاطر هذه الجولة! حاول مجدداً.', style: TextStyle(color: Colors.white54))
                    else
                      ...matchedWords.map((m) => Text('✔ $m', style: const TextStyle(color: Colors.greenAccent))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _startNewRound,
                icon: const Icon(Icons.refresh),
                label: const Text('جولة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF1E1E2F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
