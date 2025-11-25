import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

typedef SoundLevelCallback = void Function(double db);

class AudioService {
  FlutterSoundRecorder? _recorder;
  AudioPlayer? _player;
  bool _isRecording = false;

  AudioService() {
    _recorder = FlutterSoundRecorder();
    _player = AudioPlayer();
  }

  /// Başlatırken ses seviyesi için callback ekledik
  Future<void> startRecording({SoundLevelCallback? onProgress}) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder!.openRecorder();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recording.wav';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      
      numChannels: 1, // mono
      sampleRate: 16000, // 16 kHz
      audioSource: AudioSource.microphone,
    );

    _isRecording = true;

    // Ses seviyesi takibi
    if (onProgress != null) {
      _recorder!.onProgress!.listen((event) {
        // event.decibels null olabilir, 0 ile 1 arasında normalize edelim
        final db = event.decibels ?? 0.0;
        onProgress(db);
      });
    }
  }

  Future<String?> stopRecording() async {
    final path = await _recorder!.stopRecorder();
    await _recorder!.closeRecorder();
    _isRecording = false;
    return path;
  }

  bool get isRecording => _isRecording;

  Future<void> playAudio(String filePath) async {
    await _player!.play(DeviceFileSource(filePath));
  }

  Future<void> stopAudio() async {
    await _player!.stop();
  }

  Future<String> playAudioStream(Stream<dynamic> stream) async {
    final completer = Completer<String>();
    List<int> audioBytes = [];
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

    stream.listen(
      (data) {
        final response = json.decode(data);
        if (response['audio'] != null) {
          audioBytes.addAll(base64Decode(response['audio']));
        }
      },
      onDone: () async {
        if (audioBytes.isNotEmpty) {
          final file = File(filePath);
          await file.writeAsBytes(audioBytes);
          await _player!.play(DeviceFileSource(file.path));
          completer.complete(file.path);
        } else {
          completer.complete('');
        }
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    return completer.future;
  }

  Future<void> playAudioFile(File file) async {
    await _player!.stop();
    await _player!.play(DeviceFileSource(file.path));
  }

  void dispose() {
    _recorder?.closeRecorder();
    _recorder = null;
    _player?.dispose();
    _player = null;
  }
}
