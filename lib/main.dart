import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/word_game_screen.dart';

void main() {
  runApp(const PartyGameApp());
}

class PartyGameApp extends StatelessWidget {
  const PartyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ألعاب الأصدقاء',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF12121E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFFF6584),
          surface: Color(0xFF1E1E2F),
        ),
        fontFamily: 'sans-serif',
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حزمة الألعاب الجماعية'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.sports_esports, size: 70, color: Color(0xFF6C63FF)),
                    SizedBox(height: 12),
                    Text(
                      'اختر نمط اللعب',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
                         _buildGameModeCard(
             title: 'لعب فردي (ضد الذكاء الاصطناعي)',
             subtitle: 'تحديات ومراحل بدون إنترنت',
             icon: Icons.person,
             color: Colors.deepPurple,
             onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const WordGameScreen()),
               );
             },
           ),

              const SizedBox(height: 16),
              _buildGameModeCard(
                title: 'جلسة محلية (نفس الغرفة)',
                subtitle: 'لعب عبر نقطة الاتصال Wi-Fi / Hotspot بدون نت',
                icon: Icons.wifi,
                color: Colors.teal,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري إعداد الربط المحلي')),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildGameModeCard(
                title: 'لعب أونلاين (عبر الإنترنت)',
                subtitle: 'غرف خاصة برمز PIN أو بحث عشوائي',
                icon: Icons.public,
                color: Colors.indigo,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري تجهيز الخادم السحابي')),
                  );
                },
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'الإصدار 1.0.0 • يدعم من 1 إلى 6 لاعبين',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E2F),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
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
