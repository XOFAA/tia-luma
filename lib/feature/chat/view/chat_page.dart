import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tia_luma/core/service/ChatService.dart';
import 'package:tia_luma/core/models/mensagem_model.dart';
import 'package:tia_luma/core/utils/audio_recorder_helper.dart'; // usamos o mesmo helper
import 'package:tia_luma/core/utils/audio_player_helper.dart'; // para reproduzir áudios

class ChatPage extends StatefulWidget {
  final String userId;
  final String? perguntaInicial;

  const ChatPage({super.key, required this.userId, this.perguntaInicial});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final chatService = ChatService();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    // Se veio pergunta inicial da Home, já envia
    if (widget.perguntaInicial != null &&
        widget.perguntaInicial!.trim().isNotEmpty) {
      chatService.enviarMensagem(widget.userId, widget.perguntaInicial!.trim());
    }
  }

  Future<void> _enviarMensagem() async {
    final texto = controller.text.trim();
    if (texto.isNotEmpty) {
      await chatService.enviarMensagem(widget.userId, texto);
      controller.clear();
    }
  }

  Future<void> _toggleRecording() async {
    if (isRecording) {
      final bytes = await stopRecording();
      print("🛑 Gravação parada no ChatPage");

      if (bytes != null && bytes.isNotEmpty) {
        await chatService.enviarAudio(
          widget.userId,
          bytes,
          mimeType: getCurrentMimeType(),
        );
        print("✅ Áudio enviado do ChatPage");
      } else {
        print("❌ Nenhum áudio capturado");
      }

      setState(() => isRecording = false);
    } else {
      await startRecording();
      setState(() => isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tia Luma 👩‍🏫")),
      body: Column(
        children: [
          // Histórico em tempo real do Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(widget.userId)
                  .collection("mensagens")
                  .orderBy("enviadaEm", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final mensagens = docs
                    .map(
                      (doc) => Mensagem.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    final isUser = msg.remetente == "usuario";

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepOrange.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: msg.tipo == "audio" && msg.audioBase64 != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.deepOrange,
                                ),
                                onPressed: () =>
                                    playAudio(msg.audioBase64!, msg.id),
                              )
                            : Text(msg.texto),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de texto + botões
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Digite sua dúvida...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepOrange),
                  onPressed: _enviarMensagem,
                ),
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.deepOrange,
                  ),
                  onPressed: _toggleRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
