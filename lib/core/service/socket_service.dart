import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static IO.Socket? _socket;

  static Future<IO.Socket> connect() async {
    if (_socket != null && _socket!.connected) return _socket!;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final socket = IO.io(
      // iOS/Android cihazda test ediyorsan local ağ IP’ni yaz: http://192.168.x.x:5050
      'http://localhost:5050',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.onConnect((_) {
      if (userId != null && userId.isNotEmpty) {
        socket.emit('register', userId); // odaya gir
      }
    });

    _socket = socket;
    return socket;
  }

  static IO.Socket? get instance => _socket;
  static void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
