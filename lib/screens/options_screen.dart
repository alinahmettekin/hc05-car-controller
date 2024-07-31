import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> showOptionsScreen(
    BuildContext context, Map<String, String> currentOptions) async {
  return await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _OptionsScreen(currentOptions: currentOptions),
    ),
  );
}

class _OptionsScreen extends StatefulWidget {
  final Map<String, String> currentOptions;

  const _OptionsScreen({required this.currentOptions});

  @override
  __OptionsScreenState createState() => __OptionsScreenState();
}

class __OptionsScreenState extends State<_OptionsScreen> {
  late Map<String, String> buttonOptions;
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    buttonOptions = Map.from(widget.currentOptions);
    controllers = {};
    buttonOptions.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });
    _loadButtonOptions();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  _loadButtonOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      buttonOptions.forEach((key, value) {
        String savedValue = prefs.getString(key) ?? value;
        buttonOptions[key] = savedValue;
        controllers[key]!.text = savedValue;
      });
    });
  }

  _saveButtonOption(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuş Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(buttonOptions);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: buttonOptions.length,
        itemBuilder: (context, index) {
          String key = buttonOptions.keys.elementAt(index);
          return ListTile(
            title: Text(key),
            trailing: SizedBox(
              width: 100,
              child: TextField(
                controller: controllers[key],
                decoration: const InputDecoration(
                  hintText: 'Değer girin',
                ),
                onChanged: (value) {
                  buttonOptions[key] = value;
                  _saveButtonOption(key, value);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
