import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uzaktan Araç Kontrol',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<String> devices = [];
  bool isScanning = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void scanDevices() {
    setState(() {
      isScanning = true;
    });
    // Bluetooth tarama işlevi buraya eklenecek
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        devices = ['HC-05 Araç Kontrolü', 'Arduino Bluetooth Modülü'];
        isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzaktan Araç Kontrol'),
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
              Text(
                'Bluetooth Cihazları',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isScanning ? null : scanDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: isScanning
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
                child: devices.isEmpty
                    ? const Center(
                        child: Text('Henüz cihaz bulunamadı.'),
                      )
                    : ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: ListTile(
                              leading: const Icon(Icons.bluetooth,
                                  color: Colors.blue),
                              title: Text(devices[index]),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Bağlantı simülasyonu
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
                                          Text(
                                              '${devices[index]} bağlanılıyor...'),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                // 2 saniye sonra bağlantı başarılı varsayalım ve kontrol ekranına geçiş yapalım
                                Future.delayed(const Duration(seconds: 2), () {
                                  Navigator.of(context).pop(); // Dialog'u kapat
                                });
                              },
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
