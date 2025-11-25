
import 'package:flutter/material.dart';
import 'package:text_speech_app/api/api_service.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'package:text_speech_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
            context.go('/'); // doğrudan Home ekranına gider
          },
          ),
          title: Text(AppLocalizations.of(context)!.history),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.sttHistory),
              Tab(text: AppLocalizations.of(context)!.ttsHistory),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSttHistoryList(),
            _buildTtsHistoryList(),
          ],
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearHistory),
        content: Text(AppLocalizations.of(context)!.clearHistoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbService.clearSttHistory();
      await _dbService.clearTtsHistory();
      setState(() {});
    }
  }

  Widget _buildSttHistoryList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbService.getSttHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title: Text(item['text']),
                subtitle: Text('${item['timestamp']} \nID: ${item['transcription_id'] ?? 'N/A'}'),
                trailing: item['transcription_id'] != null
                    ? IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          final transcription = await _apiService.getTranscript(item['transcription_id']);
                          setState(() {
                            history[index]['text'] = transcription.text;
                          });
                        },
                      )
                    : null,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTtsHistoryList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbService.getTtsHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title: Text(item['text']),
                subtitle: Text('${item['voice']} - ${item['timestamp']}'),
              );
            },
          );
        }
      },
    );
  }
}
