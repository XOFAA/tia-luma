import 'package:flutter/material.dart';
import 'package:tia_luma/core/service/ChatService.dart';
import 'package:tia_luma/core/utils/audio_recorder_helper.dart'; // helper novo
import '../../chat/view/chat_page.dart';

class PerguntaPage extends StatefulWidget {
  final String userId;

  const PerguntaPage({super.key, required this.userId});

  @override
  State<PerguntaPage> createState() => _PerguntaPageState();
}

class _PerguntaPageState extends State<PerguntaPage> {
  final controller = TextEditingController();
  final ChatService _chatService = ChatService();
  bool isRecording = false;

  Future<void> _toggleRecording() async {
    if (isRecording) {
      final bytes = await stopRecording();
      print("🛑 Gravação parada no PerguntaPage");

      if (bytes != null && bytes.isNotEmpty) {
        await _chatService.enviarAudio(
          widget.userId,
          bytes,
          mimeType: getCurrentMimeType(),
        );
        print("✅ Áudio enviado com sucesso");
      } else {
        print("❌ Nenhum áudio capturado");
      }

      setState(() => isRecording = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(userId: widget.userId)),
        );
      }
    } else {
      await startRecording();
      setState(() => isRecording = true);
    }
  }

  Future<void> _enviarTexto() async {
    final texto = controller.text.trim();
    if (texto.isNotEmpty) {
      await _chatService.enviarMensagem(widget.userId, texto);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatPage(userId: widget.userId, perguntaInicial: texto),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Faça sua pergunta",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Ex: Como resolver esta equação?",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepOrange),
                  onPressed: _enviarTexto,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: futuro (foto exercício)
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      "Foto\nExercício",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleRecording,
                    icon: Icon(isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                      isRecording ? "Gravando..." : "Áudio\nDúvida",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
