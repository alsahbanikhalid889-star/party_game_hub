import 'package:flutter/material.dart';
import '../services/local_network_manager.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final LocalNetworkManager _net = LocalNetworkManager();
  final TextEditingController _nameController = TextEditingController(text: 'لاعب 1');
  final TextEditingController _ipController = TextEditingController();

  bool inRoom = false;
  String? hostIpAddress;
  bool isTeamMode = false;

  final List<Color> teamColors = [
    Colors.grey,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
  ];

  @override
  void initState() {
    super.initState();
    _net.onPlayersUpdated = (updatedList) {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    _net.dispose();
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMsg('يرجى كتابة اسمك أولاً');
      return;
    }

    final ip = await _net.getLocalIp();
    final error = await _net.startHost(name);

    if (error == null) {
      setState(() {
        inRoom = true;
        hostIpAddress = ip ?? '192.168.43.1';
      });
    } else {
      _showMsg('خطأ أثناء الإنشاء: $error');
    }
  }

  void _joinRoom() async {
    final ip = _ipController.text.trim();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMsg('يرجى كتابة اسمك');
      return;
    }
    if (ip.isEmpty) {
      _showMsg('يرجى كتابة عنوان IP المضيف');
      return;
    }

    final error = await _net.joinHost(ip, name);
    if (error == null) {
      setState(() {
        inRoom = true;
      });
    } else {
      _showMsg('تعذر الاتصال بالمضيف! تأكد من وجودكما على نفس الشبكة');
    }
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  // نافذة اختيار اللعبة من بين الألعاب الثلاث
  void _openGameSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر اللعبة المراد بدء الجولة بها:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildGameOptionTile(
                title: 'سارق الأفكار (Word Echo)',
                subtitle: 'تخاطر ذهني ومطابقة كلمات ذكية',
                icon: Icons.lightbulb,
                color: Colors.amber,
                onTap: () {
                  Navigator.pop(ctx);
                  _showMsg('تم اختيار سارق الأفكار');
                },
              ),
              const SizedBox(height: 10),
              _buildGameOptionTile(
                title: 'غرفة التحكم المشتركة (Circuit Panic)',
                subtitle: 'تعاون سريع وأوامر لتفادي الانفجار',
                icon: Icons.bolt,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(ctx);
                  _showMsg('جاري تحضير غرفة التحكم');
                },
              ),
              const SizedBox(height: 10),
              _buildGameOptionTile(
                title: 'المفاوض الخفي (The Blind Negotiator)',
                subtitle: 'صفقات سرية وكشف المخرب',
                icon: Icons.vpn_key,
                color: Colors.deepPurpleAccent,
                onTap: () {
                  Navigator.pop(ctx);
                  _showMsg('جاري تحضير المفاوض الخفي');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: const Color(0xFF282844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(inRoom ? 'غرفة الانتظار (${_net.players.length}/6)' : 'جلسة محلية (بدون نت)'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: inRoom ? _buildLobbyUI() : _buildConnectUI(),
    );
  }

  Widget _buildConnectUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.wifi_tethering, size: 70, color: Colors.tealAccent),
          const SizedBox(height: 16),
          const Text(
            'اللعب مع الأصدقاء في نفس المكان',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'تأكد من فتح نقطة اتصال (Hotspot) من أحد الهواتف واتصال بقية الأجهزة بها.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'اسمك في اللعبة',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E2F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _createRoom,
              icon: const Icon(Icons.add_box, color: Colors.white),
              label: const Text('إنشاء غرفة جديدة (أنا المضيف)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('أو للانضمام لمضيف', style: TextStyle(color: Colors.white54))),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'اكتب IP المضيف (مثال: 192.168.43.1)',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E1E2F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _joinRoom,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('انضمام للغرفة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyUI() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_net.isHost && hostIpAddress != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.tealAccent),
              ),
              child: Text(
                'عنوانك (IP) للانضمام:\n$hostIpAddress',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('اللاعبون المتصلون:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (_net.isHost)
                Row(
                  children: [
                    const Text('نمط فرق', style: TextStyle(fontSize: 13)),
                    Switch(
                      value: isTeamMode,
                      activeColor: Colors.deepPurpleAccent,
                      onChanged: (val) {
                        setState(() => isTeamMode = val);
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _net.players.length,
              itemBuilder: (context, index) {
                final p = _net.players[index];
                return Card(
                  color: const Color(0xFF1E1E2F),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isTeamMode ? teamColors[p.teamIndex] : Colors.transparent, width: 2),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isTeamMode ? teamColors[p.teamIndex] : Colors.deepPurple,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(
                      p.isHost ? 'المضيف (قائد الغرفة)' : (isTeamMode ? 'الفريق ${p.teamIndex}' : 'لاعب مستقل'),
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    trailing: (_net.isHost && isTeamMode)
                        ? PopupMenuButton<int>(
                            icon: const Icon(Icons.swap_horiz, color: Colors.white70),
                            onSelected: (team) => _net.updateTeam(p.id, team),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 1, child: Text('الفريق الأزرق')),
                              const PopupMenuItem(value: 2, child: Text('الفريق الأحمر')),
                              const PopupMenuItem(value: 3, child: Text('الفريق الأخضر')),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          if (_net.isHost)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _openGameSelectionModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'اختيار اللعبة وبدء الجولة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
