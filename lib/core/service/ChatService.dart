import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/mensagem_model.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> enviarMensagem(String userId, String texto) async {
    final mensagem = Mensagem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      remetente: "usuario",
      texto: texto,
      enviadaEm: DateTime.now(),
      tipo: "texto",
    );

    // grava no Firestore
    await firestore
        .collection('usuarios')
        .doc(userId)
        .collection('mensagens')
        .doc(mensagem.id)
        .set(mensagem.toMap());

    // dispara para o n8n
    await http.post(
      Uri.parse("https://automacao.agenciadigital.com.vc/webhook/tia-luma"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "Texto": texto}),
    );
  }

  Future<void> enviarAudio(
    String userId,
    List<int> bytes, {
    String mimeType = "audio/aac",
  }) async {
    // transforma em base64
    final base64Audio = base64Encode(bytes);

    final mensagem = Mensagem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      remetente: "usuario",
      texto: "[áudio enviado]",
      enviadaEm: DateTime.now(),
      tipo: "audio",
      audioBase64: base64Audio, // <- precisa existir no modelo
    );

    // grava no Firestore
    await firestore
        .collection('usuarios')
        .doc(userId)
        .collection('mensagens')
        .doc(mensagem.id)
        .set(mensagem.toMap());

    // dispara para o n8n
    await http.post(
      Uri.parse("https://automacao.agenciadigital.com.vc/webhook/tia-luma"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "audioBase64": base64Audio,
        "mimeType": mimeType,
      }),
    );
  }
}
