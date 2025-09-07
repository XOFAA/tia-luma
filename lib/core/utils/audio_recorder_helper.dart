import 'dart:io' show File; // só usamos File no mobile
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

final AudioRecorder _recorder = AudioRecorder();
String? _lastPath;
String _mime = "audio/aac";

/// Inicia a gravação
Future<void> startRecording() async {
  if (await _recorder.hasPermission()) {
    if (kIsWeb) {
      // 🌍 WEB
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.opus,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '', // no web o path é ignorado
      );
      _mime = "audio/webm";
      print("🌍 Web → gravação iniciada...");
    } else {
      // 📱 ANDROID/IOS
      final dir = await getTemporaryDirectory();
      _lastPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _lastPath.toString(),
      );

      _mime = "audio/aac";
      print("📱 Mobile → gravação iniciada em $_lastPath");
    }
  } else {
    print("❌ Sem permissão para gravar áudio");
  }
}

/// Para a gravação e retorna os bytes
Future<List<int>?> stopRecording() async {
  final path = await _recorder.stop();
  print("🛑 Gravação parada. Path retornado = $path");

  if (path == null) return null;

  if (kIsWeb) {
    // No web o path é um blob URL
    final response = await http.get(Uri.parse(path));
    return response.bodyBytes;
  } else {
    // Mobile → arquivo físico
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
  }
  return null;
}

/// Retorna o mime type atual
String getCurrentMimeType() => _mime;
