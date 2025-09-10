import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

typedef AudioCompleteCallback = void Function();
AudioCompleteCallback? onAudioComplete;

html.AudioElement? _audioElement;

Future<void> playAudio(String base64Data, String msgId) async {
  final bytes = Uint8List.fromList(const Base64Decoder().convert(base64Data));
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  _audioElement = html.AudioElement(url);
  _audioElement!.play();

  _audioElement!.onEnded.listen((_) {
    if (onAudioComplete != null) {
      onAudioComplete!();
    }
  });
}

Future<void> stopGlobalAudio() async {
  _audioElement?.pause();
  _audioElement?.currentTime = 0;
}
