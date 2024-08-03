import 'package:car_control_app/screens/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final List<BluetoothDevice> _devices = [];
  late bool _isScanning = false;
  late AnimationController _animationController;
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _checkBluetoothStatus();
  }

  void _checkBluetoothStatus() async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await _bluetooth.requestEnable();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void scanDevices() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      _bluetooth.startDiscovery().listen((r) {
        setState(() {
          final existingIndex = _devices
              .indexWhere((element) => element.address == r.device.address);
          if (existingIndex >= 0) {
            _devices[existingIndex] = r.device;
          } else {
            _devices.add(r.device);
          }
        });
      }).onDone(() {
        setState(() {
          _isScanning = false;
        });
      });
    } catch (ex) {
      print('Error scanning Bluetooth devices: $ex');
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bağlanılıyor'),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text('${device.name} bağlanılıyor...'),
            ],
          ),
        );
      },
    );

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      Navigator.of(context).pop(); // Dialog'u kapat
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ControlScreen(device: device, connection: connection!),
        ),
      );
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
      Navigator.of(context).pop(); // Dialog'u kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı başarısız: $exception')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Uzaktan Araç Kontrol',
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isScanning ? null : scanDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _isScanning
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: _animationController.value * 2 * 3.14,
                                  child: child,
                                );
                              },
                              child: const Icon(Icons.refresh),
                            ),
                            const SizedBox(width: 10),
                            const Text('Taranıyor...'),
                          ],
                        )
                      : const Text('Cihazları Tara'),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: _devices.isEmpty
                    ? const Center(
                        child: Text('Henüz cihaz bulunamadı.'),
                      )
                    : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: ListTile(
                              leading: const Icon(Icons.bluetooth,
                                  color: Colors.blue),
                              title: Text(
                                  _devices[index].name ?? 'Bilinmeyen Cihaz'),
                              subtitle: Text(_devices[index].address),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _connectToDevice(_devices[index]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
