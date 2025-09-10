import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tia_luma/core/service/ChatService.dart';
import 'package:tia_luma/core/utils/audio_recorder_helper.dart';
import '../../chat/view/chat_page.dart';

class PerguntaPage extends StatefulWidget {
  final String userId;

  const PerguntaPage({super.key, required this.userId});

  @override
  State<PerguntaPage> createState() => _PerguntaPageState();
}

class _PerguntaPageState extends State<PerguntaPage>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  final ChatService _chatService = ChatService();

  bool isRecording = false;
  bool isLoadingText = false;
  bool isLoadingAudio = false;
  int recordingSeconds = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<Color?>  _colorAnimation;

  @override
  void initState() {
    super.initState();

    // animação para "piscar" quando gravando
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.redAccent,
      end: Colors.red.withOpacity(0.4),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    recordingSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => recordingSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    recordingSeconds = 0;
  }

  Future<void> _toggleRecording() async {
    if (isLoadingAudio) return;

    if (isRecording) {
      setState(() => isLoadingAudio = true);

      final bytes = await stopRecording();
      _stopTimer();
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

      setState(() {
        isRecording = false;
        isLoadingAudio = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(userId: widget.userId)),
        );
      }
    } else {
      await startRecording();
      _startTimer();
      setState(() => isRecording = true);
    }
  }

  Future<void> _enviarTexto() async {
    final texto = controller.text.trim();
    if (texto.isEmpty || isLoadingText) return;

    setState(() => isLoadingText = true);

    try {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatPage(userId: widget.userId, perguntaInicial: texto),
          ),
        );
        controller.clear(); // 👈 limpa o campo ao navegar
      }
    } finally {
      setState(() => isLoadingText = false);
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
                suffixIcon: isLoadingText
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepOrange),
                        onPressed: _enviarTexto,
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // indicador de gravação estilo WhatsApp
            if (isRecording)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Gravando...  ${recordingSeconds}s",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

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
                    onPressed: isLoadingAudio ? null : _toggleRecording,
                    icon: isLoadingAudio
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                      isRecording
                          ? "Parar"
                          : (isLoadingAudio ? "Enviando..." : "Áudio\nDúvida"),
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
