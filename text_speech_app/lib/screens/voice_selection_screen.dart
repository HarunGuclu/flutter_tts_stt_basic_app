
import 'package:flutter/material.dart';
import 'package:text_speech_app/api/api_service.dart';
import 'package:text_speech_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
class VoiceSelectionScreen extends StatefulWidget {
  const VoiceSelectionScreen({super.key});

  @override
  _VoiceSelectionScreenState createState() => _VoiceSelectionScreenState();
}


class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _voicesFuture;

  @override
  void initState() {
    super.initState();
    _voicesFuture = _apiService.getVoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // doğrudan Home ekranına gider
          },
        ),
        title: Text(AppLocalizations.of(context)!.selectVoice),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _voicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final voices = snapshot.data!;
            return ListView.builder(
              itemCount: voices.length,
              itemBuilder: (context, index) {
                final voice = voices[index];
                return ListTile(
                  title: Text(voice['name']),
                  onTap: () {
                    Navigator.pop(context, voice['voice_id']);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
