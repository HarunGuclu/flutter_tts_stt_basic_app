
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:text_speech_app/api/api_service.dart';
import 'package:text_speech_app/services/audio_service.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'dart:io';

import 'package:text_speech_app/l10n/app_localizations.dart';
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

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      if (path != null) {
        final transcription = await _apiService.speechToText(File(path));
        await _dbService.insertSttHistory(transcription.text, path, transcriptionId: transcription.transcriptionId);
        setState(() {
          _text = transcription.text;
          _isProcessing = false;
        });
      }
    } else {
      await _audioService.startRecording();
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
        await _dbService.insertSttHistory(transcription.text, path, transcriptionId: transcription.transcriptionId);
        setState(() {
          _text = transcription.text;
          _isProcessing = false;
        });
      }
    }
  }
}
