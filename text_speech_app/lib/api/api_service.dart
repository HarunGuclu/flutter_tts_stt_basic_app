
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:text_speech_app/models/transcription.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http_parser/http_parser.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ApiService {
  final String? apiKey = dotenv.env['ELEVENLABS_API_KEY'];
  final String baseUrl = 'https://api.elevenlabs.io/v1';

  Future<List<dynamic>> getVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/voices'),
        headers: {'xi-api-key': apiKey ?? ''},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['voices'];
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid API key');
      } else {
        throw ApiException('Failed to load voices: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load voices: $e');
    }
  }

  Future<File> textToSpeech(String text, String voiceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': apiKey ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
        }),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${Uuid().v4()}.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid API key');
      } else {
        throw ApiException('Failed to convert text to speech: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to convert text to speech: $e');
    }
  }
Future<Transcription> speechToText(File audioFile) async {
  try {
    final uri = Uri.parse("$baseUrl/speech-to-text");

    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "xi-api-key": apiKey ?? "",
    });

    request.fields["model_id"] = "scribe_v1";
    request.fields["language_code"] = "tr";

    final bytes = await audioFile.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: audioFile.path.split('/').last,
        contentType: MediaType("audio", "mpeg"),
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("STT RESP (${response.statusCode}): $body");

    if (response.statusCode == 200) {
      return Transcription.fromJson(jsonDecode(body));
    }

    throw ApiException("STT Error ${response.statusCode}: $body");
  } catch (e, stack) {
    print("STT ERROR: $e");
    print(stack);
    throw ApiException("Failed STT: $e");
  }
}



  Future<Transcription> getTranscript(String transcriptionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/speech-to-text/transcripts/$transcriptionId'),
        headers: {'xi-api-key': apiKey ?? ''},
      );
      if (response.statusCode == 200) {
        return Transcription.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid API key');
      } else {
        throw ApiException('Failed to load transcript: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load transcript: $e');
    }
  }

  Stream<dynamic> textToSpeechStream(String text, String voiceId) {
    final uri = Uri.parse('wss://api.elevenlabs.io/v1/text-to-speech/$voiceId/stream-input');
    final channel = WebSocketChannel.connect(uri);

    channel.sink.add(json.encode({
      'text': ' ',
      'voice_settings': {
        'speed': 1,
        'stability': 0.5,
        'similarity_boost': 0.8,
      },
      'xi_api_key': apiKey,
    }));

    channel.sink.add(json.encode({
      'text': text,
      'try_trigger_generation': true,
    }));

    channel.sink.add(json.encode({'text': ''}));

    return channel.stream;
  }
}
