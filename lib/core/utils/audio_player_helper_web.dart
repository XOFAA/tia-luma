import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

Future<void> playAudio(String base64Data, String msgId) async {
  final bytes = Uint8List.fromList(const Base64Decoder().convert(base64Data));
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final audio = html.AudioElement(url);
  audio.play();
}
