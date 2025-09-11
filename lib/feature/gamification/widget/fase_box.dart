import 'package:flutter/material.dart';

class FaseBox extends StatelessWidget {
  final bool desbloqueada;
  final bool atual;
  final VoidCallback? onTap;

  const FaseBox({
    super.key,
    required this.desbloqueada,
    this.atual = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: desbloqueada ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge customizado "COMEÇAR"
          if (atual && desbloqueada)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Text(
                    "COMEÇAR",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "RubikScribble",
                      fontSize: 12,
                    ),
                  ),
                  // Setinha
                  Positioned(
                    bottom: -6,
                    left: 20,
                    child: CustomPaint(
                      size: const Size(12, 6),
                      painter: _TrianglePainter(),
                    ),
                  ),
                ],
              ),
            ),

          // Imagem azul ou cinza
          Image.asset(
            desbloqueada
                ? "assets/images/fase_unlocked.png"
                : "assets/images/fase_locked.png",
            width: 90,
            height: 90,
          ),
        ],
      ),
    );
  }
}

// 🔽 Triângulo amarelo embaixo do badge
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellow;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
