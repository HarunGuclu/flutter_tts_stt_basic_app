import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_speech_app/api/api_service.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'package:text_speech_app/l10n/app_localizations.dart';
import 'package:text_speech_app/services/audio_service.dart';
import '../widgets/sound_level_visualizer.dart';

class SttScreen extends StatefulWidget {
  const SttScreen({super.key});

  @override
  _SttScreenState createState() => _SttScreenState();
}

class _SttScreenState extends State<SttScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;

  String _text = '';
  bool _isProcessing = false;
  double _soundLevel = 0.0;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // Home ekranına dön
          },
        ),
        title: Text(AppLocalizations.of(context)!.speechToText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    child: Text(_audioService.isRecording
                        ? AppLocalizations.of(context)!.stopRecording
                        : AppLocalizations.of(context)!.startRecording),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text(AppLocalizations.of(context)!.selectFile),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Ses seviyesi göstergesi
            SoundLevelVisualizer(level: _soundLevel),
            const SizedBox(height: 20),
            Text(_text),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() async {
    if (_audioService.isRecording) {
      setState(() {
        _isProcessing = true;
      });
      final path = await _audioService.stopRecording();
      final file = File(path!);
      print('Dosya boyutu: ${file.lengthSync()} bytes');

      if (path != null && File(path).lengthSync() > 0) {
        final transcription = await _apiService.speechToText(File(path));

        // Eğer API boş dönerse uyarı göster
        if (transcription.text.isEmpty) {
          setState(() {
            _text = 'Kayıt algılanamadı, lütfen tekrar deneyin';
            _isProcessing = false;
            _soundLevel = 0.0;
          });
          return;
        }

        await _dbService.insertSttHistory(transcription.text, path,
            transcriptionId: transcription.transcriptionId);

        setState(() {
          _text = transcription.text;
          _isProcessing = false;
          _soundLevel = 0.0;
        });
      }
    } else {
      await _audioService.startRecording(onProgress: (db) {
        setState(() {
          
          _soundLevel = (db + 50) / 50; // normalize et 0-1 arası
        });
      });
      setState(() {});
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _isProcessing = true;
      });
      final path = result.files.single.path;
      if (path != null) {
        final transcription = await _apiService.speechToText(File(path));

        if (transcription.text.isEmpty) {
          setState(() {
            _text = 'Seçilen dosyadan metin algılanamadı';
            _isProcessing = false;
            _soundLevel = 0.0;
          });
          return;
        }

        await _dbService.insertSttHistory(transcription.text, path,
            transcriptionId: transcription.transcriptionId);

        setState(() {
          _text = transcription.text;
          _isProcessing = false;
          _soundLevel = 0.0;
        });
      }
    }
  }
}
