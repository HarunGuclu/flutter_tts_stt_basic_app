
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_speech_app/api/api_service.dart';
import 'package:text_speech_app/services/audio_service.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'dart:io';
import 'package:text_speech_app/l10n/app_localizations.dart';


class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  _TtsScreenState createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  final DatabaseService _dbService = DatabaseService.instance;
  final TextEditingController _textController = TextEditingController();
  String? _selectedVoice;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultVoice();
  }

  Future<void> _loadDefaultVoice() async {
    final defaultVoice = await _dbService.getSetting('default_voice');
    if (defaultVoice != null) {
      setState(() {
        _selectedVoice = defaultVoice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.textToSpeech),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selectedVoice = await context.push('/voice-selection');
                if (selectedVoice != null) {
                  setState(() {
                    _selectedVoice = selectedVoice as String?;
                  });
                }
              },
              child: Text(_selectedVoice ?? AppLocalizations.of(context)!.selectVoice),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _textToSpeech,
                child: Text(AppLocalizations.of(context)!.convertToSpeech),
              ),
          ],
        ),
      ),
    );
  }

  void _textToSpeech() async {
    if (_textController.text.isNotEmpty && _selectedVoice != null) {
      setState(() {
        _isProcessing = true;
      });
      try {
        final stream = _apiService.textToSpeechStream(
          _textController.text,
          _selectedVoice!,
        );
        final filePath = await _audioService.playAudioStream(stream);
        await _dbService.insertTtsHistory(
            _textController.text, _selectedVoice!, filePath);
      } catch (e) {
        // Handle error
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
