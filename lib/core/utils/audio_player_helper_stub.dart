Future<void> playAudio(String base64Data, String msgId) async {
  throw UnsupportedError("Tocar áudio não é suportado nesta plataforma");
}

Future<void> stopGlobalAudio() async {
  throw UnsupportedError("Parar áudio não é suportado nesta plataforma");
}

typedef AudioCompleteCallback = void Function();
AudioCompleteCallback? onAudioComplete;
