
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'package:text_speech_app/l10n/app_localizations.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  String? _defaultVoice;
  String? _language;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final defaultVoice = await _dbService.getSetting('default_voice');
    final language = await _dbService.getSetting('language');
    setState(() {
      _defaultVoice = defaultVoice;
      _language = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'tr', child: Text('Turkish')),
                ],
                onChanged: (value) {
                  _dbService.setSetting('language', value!);
                  setState(() {
                    _language = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Default Voice'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final selectedVoice = await context.push('/voice-selection');
                  if (selectedVoice != null) {
                    await _dbService.setSetting('default_voice', selectedVoice as String);
                    setState(() {
                      _defaultVoice = selectedVoice;
                    });
                  }
                },
                child: Text(_defaultVoice ?? AppLocalizations.of(context)!.selectVoice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
