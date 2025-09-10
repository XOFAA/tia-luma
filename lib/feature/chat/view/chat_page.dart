import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

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

  final ScrollController _scrollController = ScrollController();

  bool isRecording = false;
  bool isLocked = false;
  int recordingSeconds = 0;
  Timer? _timer;

  Offset startPosition = Offset.zero;

  /// Mostra animação de "pensando"
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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
      FocusScope.of(context).unfocus(); // fecha teclado

      // Ativa animação pensando
      setState(() => thinkingMessage = "thinking");

      // Timeout de segurança
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && thinkingMessage != null) {
          setState(() => thinkingMessage = null);
        }
      });
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

      setState(() => thinkingMessage = "thinking");
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
      backgroundColor: const Color(0xFF0E0822),
      appBar: AppBar(
        backgroundColor: const Color(0xFF411960),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tia Luma",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Online agora",
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
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

                    // Remove animação quando chega a última resposta da tia_luma
                    if (thinkingMessage != null &&
                        mensagens.isNotEmpty &&
                        mensagens.last.remetente == "tia_luma") {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => thinkingMessage = null);
                      });
                    }

                    _scrollToBottom();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          mensagens.length + (thinkingMessage != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        // animação pensando
                        if (thinkingMessage != null &&
                            index == mensagens.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E44AD),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SizedBox(
                                height: 40,
                                width: 60,
                                child: Lottie.asset(
                                  "assets/lottie/LoadingDot.json",
                                  repeat: true,
                                ),
                              ),
                            ),
                          );
                        }

                        final msg = mensagens[index];
                        final isUser = msg.remetente == "usuario";

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF3498DB)
                                  : const Color(0xFF8E44AD),
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
                                          color: Colors.white,
                                        ),
                                        onPressed: () => _togglePlay(
                                          msg.audioBase64!,
                                          msg.id,
                                        ),
                                      ),
                                      playingId == msg.id
                                          ? AnimatedBars(
                                              animController: _animController)
                                          : const Text("Áudio",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                    ],
                                  )
                                : Text(
                                    msg.texto,
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Digite sua mensagem...",
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF411960),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.send, color: Color(0xFF00C853)),
                      onPressed: _enviarMensagem,
                    ),
                    GestureDetector(
                      onLongPressStart: (details) {
                        startPosition = details.globalPosition;
                        _onStartRecord();
                      },
                      onLongPressEnd: (_) {
                        if (!isLocked) {
                          _onStopRecord();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C853),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic,
                            color: Colors.white, size: 28),
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
                  const Text("⬆️ Segure para gravar",
                      style: TextStyle(color: Colors.white)),
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
            child: Container(width: 4, height: 20, color: Colors.white),
          ),
        );
      }),
    );
  }
}
