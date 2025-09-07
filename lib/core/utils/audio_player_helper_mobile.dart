import 'dart:convert';
import 'dart:io' show File, Directory;
import 'package:just_audio/just_audio.dart';

Future<void> playAudio(String base64Data, String msgId) async {
  final bytes = const Base64Decoder().convert(base64Data);

  final tempFile = File('${Directory.systemTemp.path}/$msgId.m4a');
  await tempFile.writeAsBytes(bytes);

  final player = AudioPlayer();
  await player.setFilePath(tempFile.path);
  await player.play();
}
