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
    Colors.grey,        // 0: فردي
    Colors.blueAccent,  // 1: الفريق الأزرق
    Colors.redAccent,   // 2: الفريق الأحمر
    Colors.greenAccent, // 3: الفريق الأخضر
  ];

  @override
  void initState() {
    super.initState();
    _net.onPlayersUpdated = (updatedList) {
      setState(() {});
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
    final ip = await _net.getLocalIp();
    final ok = await _net.startHost(_nameController.text.trim());
    if (ok) {
      setState(() {
        inRoom = true;
        hostIpAddress = ip ?? '127.0.0.1';
      });
    } else {
      _showMsg('تعذر إنشاء الغرفة، تأكد من تشغيل نقطة الاتصال Wi-Fi');
    }
  }

  void _joinRoom() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showMsg('يرجى كتابة عنوان IP المضيف');
      return;
    }
    final ok = await _net.joinHost(ip, _nameController.text.trim());
    if (ok) {
      setState(() {
        inRoom = true;
      });
    } else {
      _showMsg('تعذر الاتصال بالمضيف! تأكد من أنك على نفس الشبكة');
    }
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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

  // واجهة الانضمام أو الإنشاء
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
            decoration: InputDecoration(
              labelText: 'اسمك في اللعبة',
              filled: true,
              fillColor: const Color(0xFF1E1E2F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createRoom,
            icon: const Icon(Icons.add_box, color: Colors.white),
            label: const Text('إنشاء غرفة جديدة (أنا المضيف)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
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
            decoration: InputDecoration(
              hintText: 'اكتب IP المضيف (مثال: 192.168.43.1)',
              filled: true,
              fillColor: const Color(0xFF1E1E2F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _joinRoom,
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('انضمام للغرفة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // واجهة داخل الغرفة وقائمة اللاعبين وتوزيع الفرق
  Widget _buildLobbyUI() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_net.isHost && hostIpAddress != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.tealAccent),
              ),
              child: Text(
                'أخبر أصدقاءك بكتابة هذا الـ IP للانضمام:\n$hostIpAddress',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.tealAccent),
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
            ElevatedButton(
              onPressed: _net.players.length >= 2
                  ? () {
                      _showMsg('جاهزون للانطلاق! سنربط شاشة اختيار اللعبة الجماعية');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _net.players.length >= 2 ? 'بدء اللعبة واختيار النمط' : 'في انتظار لاعبين (2 على الأقل)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
