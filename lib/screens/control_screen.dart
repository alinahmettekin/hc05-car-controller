import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'options_screen.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;

  const ControlScreen(
      {super.key, required this.device, required this.connection});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String _direction = "Dur";
  Map<String, String> buttonOptions = {
    'Sol': '',
    'Sağ': '',
    'İleri': '',
    'Geri': '',
    'Dur': '',
    'Buton 1': '',
    'Buton 2': '',
    'Buton 3': '',
    'Buton 4': '',
  };

  @override
  void initState() {
    super.initState();
    _loadButtonOptions();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void sendData(String data) async {
    data = data.trim();
    if (data.isNotEmpty) {
      try {
        List<int> list = data.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);
        widget.connection.output.add(bytes);
        await widget.connection.output.allSent;
        print('Veri gönderildi: $data');
      } catch (e) {
        print('Veri gönderme hatası: $e');
        // Hata durumunda kullanıcıya bilgi verebilirsiniz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri gönderme hatası: $e')),
        );
      }
    }
  }

  _loadButtonOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      buttonOptions.forEach((key, value) {
        buttonOptions[key] = prefs.getString(key) ?? '';
      });
    });
  }

  void _sendCommand(String command) {
    if (command.isNotEmpty) {
      print('Gönderilen komut: $command');
      print(buttonOptions);
      sendData(command);

      // Burada Bluetooth üzerinden komutu gönderme işlemi yapılacak
    }
  }

  Widget _buildButton(String label, IconData icon) {
    return ElevatedButton(
      onPressed: () => _sendCommand(buttonOptions[label] ?? ''),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12), // Padding'i azalttık
        backgroundColor: Colors.blue,
        minimumSize: const Size(50, 50), // Minimum boyutu belirledik
      ),
      child: Icon(icon, size: 20), // İkon boyutunu küçülttük
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          '${widget.device.name} Kontrol',
          style: const TextStyle(fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              final updatedOptions =
                  await showOptionsScreen(context, buttonOptions);
              setState(() {
                buttonOptions = updatedOptions;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Sol taraf - Joystick
          Positioned(
            left: 50,
            top: 100,
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Joystick(
                    mode: JoystickMode.all,
                    listener: (details) {
                      setState(() {
                        if (details.x > 0.5) {
                          _direction = "Sağ";
                          _sendCommand(buttonOptions['Sağ'] ?? '');
                        } else if (details.x < -0.5) {
                          _direction = "Sol";
                          _sendCommand(buttonOptions['Sol'] ?? '');
                        } else if (details.y > 0.5) {
                          _direction = "Geri";
                          _sendCommand(buttonOptions['Geri'] ?? '');
                        } else if (details.y < -0.5) {
                          _direction = "İleri";
                          _sendCommand(buttonOptions['İleri'] ?? '');
                        } else {
                          _direction = "Dur";
                          _sendCommand(buttonOptions['Dur'] ?? '');
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Text(_direction, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          // Sağ alt - Eşkenar dörtgen butonlar
          Positioned(
            right: 50,
            bottom: 10,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  Positioned(
                    left: 40,
                    top: 100,
                    child: _buildButton('Buton 1', Icons.lightbulb),
                  ),
                  Positioned(
                    left: 0,
                    top: 150,
                    child: _buildButton('Buton 2', Icons.volume_up),
                  ),
                  Positioned(
                    right: 20,
                    top: 100,
                    child: _buildButton('Buton 3', Icons.speed),
                  ),
                  Positioned(
                    left: 90,
                    bottom: 0,
                    child: _buildButton('Buton 4', Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
