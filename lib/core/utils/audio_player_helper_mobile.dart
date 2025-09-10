import 'dart:convert';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

AudioPlayer? _globalPlayer;
String? _currentId;

/// Callback global opcional para avisar o ChatPage quando terminar o áudio
typedef AudioCompleteCallback = void Function();
AudioCompleteCallback? onAudioComplete;

Future<void> playAudio(String base64Data, String msgId) async {
  if (_globalPlayer != null && _globalPlayer!.playing) {
    await _globalPlayer!.stop();
  }

  _globalPlayer ??= AudioPlayer();
  _currentId = msgId;

  String cleanBase64 =
      base64Data.replaceFirst(RegExp(r'data:audio/[^;]+;base64,'), '');
  final bytes = const Base64Decoder().convert(cleanBase64);

  final tempFile = File('${Directory.systemTemp.path}/$msgId.mp3');
  await tempFile.writeAsBytes(bytes);

  await _globalPlayer!.setFilePath(tempFile.path);
  await _globalPlayer!.play();

  // 🔑 listener para saber quando terminou
  _globalPlayer!.playerStateStream.listen((state) {
    if (state.processingState == ProcessingState.completed) {
      stopGlobalAudio();
      if (onAudioComplete != null) {
        onAudioComplete!();
      }
    }
  });
}

Future<void> stopGlobalAudio() async {
  if (_globalPlayer != null && _globalPlayer!.playing) {
    await _globalPlayer!.stop();
  }
}
