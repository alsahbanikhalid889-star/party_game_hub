import 'dart:async';
import 'dart:convert';
import 'dart:io';

class LocalPlayer {
  final String id;
  final String name;
  final int teamIndex;
  final bool isHost;

  LocalPlayer({
    required this.id,
    required this.name,
    this.teamIndex = 0,
    this.isHost = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teamIndex': teamIndex,
        'isHost': isHost,
      };

  factory LocalPlayer.fromJson(Map<String, dynamic> json) => LocalPlayer(
        id: json['id'],
        name: json['name'],
        teamIndex: json['teamIndex'] ?? 0,
        isHost: json['isHost'] ?? false,
      );
}

class LocalNetworkManager {
  static const int port = 40404;

  ServerSocket? _server;
  final List<Socket> _clientSockets = [];
  Socket? _myClientSocket;

  Function(List<LocalPlayer>)? onPlayersUpdated;
  Function(Map<String, dynamic>)? onGameMessageReceived;

  List<LocalPlayer> players = [];
  bool isHost = false;
  String myId = '';

  Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '192.168.43.1'; // الآي بي الافتراضي لنقطة اتصال أندرويد
  }

  Future<String?> startHost(String hostName) async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      isHost = true;
      myId = 'host_${DateTime.now().millisecondsSinceEpoch}';

      players = [LocalPlayer(id: myId, name: hostName, isHost: true, teamIndex: 1)];
      onPlayersUpdated?.call(players);

      _server?.listen((Socket client) {
        _clientSockets.add(client);
        client.listen((data) {
          _handleIncomingData(utf8.decode(data), client);
        }, onDone: () {
          _clientSockets.remove(client);
        });
      });
      return null; // نجاح بدون أخطاء
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> joinHost(String hostIp, String playerName) async {
    try {
      _myClientSocket = await Socket.connect(hostIp.trim(), port, timeout: const Duration(seconds: 5));
      isHost = false;
      myId = 'player_${DateTime.now().millisecondsSinceEpoch}';

      final joinPayload = {
        'type': 'JOIN',
        'player': LocalPlayer(id: myId, name: playerName, teamIndex: 2).toJson(),
      };
      _myClientSocket?.write(jsonEncode(joinPayload));

      _myClientSocket?.listen((data) {
        _handleClientIncomingData(utf8.decode(data));
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _handleIncomingData(String rawMessage, Socket sender) {
    try {
      final msg = jsonDecode(rawMessage);
      if (msg['type'] == 'JOIN') {
        final newPlayer = LocalPlayer.fromJson(msg['player']);
        if (players.length < 6) {
          players.add(newPlayer);
          _broadcastPlayers();
        }
      } else if (msg['type'] == 'GAME_ACTION') {
        onGameMessageReceived?.call(msg['data']);
        _broadcastToOthers(rawMessage, sender);
      }
    } catch (_) {}
  }

  void _handleClientIncomingData(String rawMessage) {
    try {
      final msg = jsonDecode(rawMessage);
      if (msg['type'] == 'PLAYERS_UPDATE') {
        final list = (msg['players'] as List).map((p) => LocalPlayer.fromJson(p)).toList();
        players = list;
        onPlayersUpdated?.call(players);
      } else if (msg['type'] == 'GAME_ACTION') {
        onGameMessageReceived?.call(msg['data']);
      }
    } catch (_) {}
  }

  void _broadcastPlayers() {
    final payload = jsonEncode({
      'type': 'PLAYERS_UPDATE',
      'players': players.map((p) => p.toJson()).toList(),
    });
    for (var s in _clientSockets) {
      s.write(payload);
    }
    onPlayersUpdated?.call(players);
  }

  void _broadcastToOthers(String rawMessage, Socket sender) {
    for (var s in _clientSockets) {
      if (s != sender) {
        s.write(rawMessage);
      }
    }
  }

  void updateTeam(String playerId, int newTeam) {
    if (!isHost) return;
    final idx = players.indexWhere((p) => p.id == playerId);
    if (idx != -1) {
      players[idx] = LocalPlayer(
        id: players[idx].id,
        name: players[idx].name,
        teamIndex: newTeam,
        isHost: players[idx].isHost,
      );
      _broadcastPlayers();
    }
  }

  void dispose() {
    for (var s in _clientSockets) {
      s.destroy();
    }
    _clientSockets.clear();
    _myClientSocket?.destroy();
    _server?.close();
  }
}
