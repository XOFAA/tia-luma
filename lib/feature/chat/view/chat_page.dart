import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tia_luma/core/service/ChatService.dart';
import 'package:tia_luma/core/models/mensagem_model.dart';
import 'package:tia_luma/core/utils/audio_recorder_helper.dart';
import 'package:tia_luma/core/utils/audio_player_helper.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String? perguntaInicial;

  const ChatPage({super.key, required this.userId, this.perguntaInicial});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  final chatService = ChatService();

  bool isRecording = false;
  bool isLocked = false;
  int recordingSeconds = 0;
  Timer? _timer;

  Offset startPosition = Offset.zero;

  String? thinkingMessage;
  String? playingId;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    if (widget.perguntaInicial != null &&
        widget.perguntaInicial!.trim().isNotEmpty) {
      chatService.enviarMensagem(
        widget.userId,
        widget.perguntaInicial!.trim(),
        remetente: "usuario",
      );
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    onAudioComplete = () {
      _animController.stop();
      setState(() => playingId = null);
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
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

  Future<void> _enviarMensagem() async {
    final texto = controller.text.trim();
    if (texto.isNotEmpty) {
      await chatService.enviarMensagem(
        widget.userId,
        texto,
        remetente: "usuario",
      );
      controller.clear();
    }
  }

  Future<void> _onStartRecord() async {
    setState(() {
      isRecording = true;
      isLocked = false;
      recordingSeconds = 0;
    });
    startPosition = Offset.zero;
    _startTimer();

    HapticFeedback.vibrate();
    await startRecording();
  }

  Future<void> _onStopRecord() async {
    final bytes = await stopRecording();
    _stopTimer();
    setState(() {
      isRecording = false;
      isLocked = false;
    });

    if (bytes != null && bytes.isNotEmpty) {
      await chatService.enviarAudio(
        widget.userId,
        bytes,
        mimeType: getCurrentMimeType(),
      );

      setState(() {
        thinkingMessage = "🤖 A Tia Luma está pensando na sua resposta...";
      });
    }
  }

  Future<void> _cancelRecord() async {
    await stopRecording();
    _stopTimer();
    setState(() {
      isRecording = false;
      isLocked = false;
    });
  }

  Future<void> _togglePlay(String base64, String id) async {
    if (playingId == id) {
      await stopGlobalAudio();
      _animController.stop();
      setState(() => playingId = null);
    } else {
      setState(() => playingId = id);
      _animController.repeat(reverse: true);

      playAudio(base64, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tia Luma 👩‍🏫")),
      body: Stack(
        children: [
          Column(
            children: [
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

                    if (thinkingMessage != null &&
                        mensagens.any(
                          (m) =>
                              m.remetente == "ia" &&
                              (m.texto.isNotEmpty || m.tipo == "audio"),
                        )) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => thinkingMessage = null);
                      });
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          mensagens.length + (thinkingMessage != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (thinkingMessage != null &&
                            index == mensagens.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(thinkingMessage!),
                            ),
                          );
                        }

                        final msg = mensagens[index];
                        final isUser = msg.remetente == "usuario";
                        final isSystem = msg.remetente == "sistema";

                        return Align(
                          alignment:
                              isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSystem
                                  ? Colors.grey.shade200
                                  : (isUser
                                      ? Colors.deepOrange.shade100
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: msg.tipo == "audio" &&
                                    msg.audioBase64 != null
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          playingId == msg.id
                                              ? Icons.stop
                                              : Icons.play_arrow,
                                          color: Colors.deepOrange,
                                        ),
                                        onPressed: () => _togglePlay(
                                          msg.audioBase64!,
                                          msg.id,
                                        ),
                                      ),
                                      playingId == msg.id
                                          ? AnimatedBars(
                                              animController: _animController)
                                          : const Text("Áudio"),
                                    ],
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
                    GestureDetector(
                      onLongPressStart: (details) {
                        startPosition = details.globalPosition;
                        _onStartRecord();
                      },
                      onLongPressMoveUpdate: (details) {
                        final dy = details.globalPosition.dy - startPosition.dy;
                        if (dy < -50 && !isLocked) {
                          setState(() => isLocked = true);
                        }
                      },
                      onLongPressEnd: (_) {
                        if (!isLocked) {
                          _onStopRecord();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isRecording ? Colors.red : Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Feedback enquanto grava
          if (isRecording)
            Positioned(
              bottom: 100,
              left: 30,
              right: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(recordingSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isLocked)
                    const Text(
                      "⬆️ Deslize para cima para travar",
                      style: TextStyle(color: Colors.white),
                    ),

                  if (isLocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _onStopRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text("Enviar"),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _cancelRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text("Cancelar"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedBars extends StatelessWidget {
  final AnimationController animController;

  const AnimatedBars({super.key, required this.animController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(
                parent: animController,
                curve: Interval(0.2 * i, 1.0, curve: Curves.easeInOut),
              ),
            ),
            child: Container(width: 4, height: 20, color: Colors.deepOrange),
          ),
        );
      }),
    );
  }
}
