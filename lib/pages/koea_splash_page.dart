import 'dart:async';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class KoeaSplashPage extends StatefulWidget {
  final Widget nextPage;

  const KoeaSplashPage({
    super.key,
    required this.nextPage,
  });

  @override
  State<KoeaSplashPage> createState() => _KoeaSplashPageState();
}

class _KoeaSplashPageState extends State<KoeaSplashPage> {
  bool showPanda = false;
  bool showKoea = false;
  bool showGames = false;
  bool fadeOut = false;

  @override
  void initState() {
    super.initState();
    _runIntro();
  }

  Future<void> _runIntro() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => showPanda = true);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => showKoea = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => showGames = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => fadeOut = true);

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => widget.nextPage,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        opacity: fadeOut ? 0 : 1,
        duration: const Duration(milliseconds: 650),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                top: showPanda ? 250 : 80,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: showPanda ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: const Center(
                    child: PandaFace(size: 82),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: showKoea ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: AnimatedScale(
                  scale: showKoea ? 1 : 0.92,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: const KoeaLogo(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + 55,
                child: AnimatedOpacity(
                  opacity: showGames ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'G A M E S',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KoeaLogo extends StatelessWidget {
  const KoeaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoLetter('K'),
        SizedBox(width: 8),
        PandaFace(size: 74),
        SizedBox(width: 8),
        _LogoLetter('E'),
        SizedBox(width: 8),
        _LogoLetter('A'),
      ],
    );
  }
}

class _LogoLetter extends StatelessWidget {
  final String letter;

  const _LogoLetter(this.letter);

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 68,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

class PandaFace extends StatelessWidget {
  final double size;

  const PandaFace({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PandaFacePainter(),
    );
  }
}

class _PandaFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    final purple = Paint()..color = AppColors.primary.withOpacity(0.35);

    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;

    canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.23),
        size.width * 0.15, black);
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.23),
        size.width * 0.15, black);

    canvas.drawCircle(c, r, white);

    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.48),
        size.width * 0.14, black);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.48),
        size.width * 0.14, black);

    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.45),
        size.width * 0.035, white);
    canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.45),
        size.width * 0.035, white);

    final nosePath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.59)
      ..lineTo(size.width * 0.43, size.height * 0.66)
      ..lineTo(size.width * 0.57, size.height * 0.66)
      ..close();

    canvas.drawPath(nosePath, black);

    final mouth = Paint()
      ..color = Colors.black
      ..strokeWidth = size.width * 0.025
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.47, size.height * 0.70),
        width: size.width * 0.14,
        height: size.height * 0.10,
      ),
      0.2,
      1.1,
      false,
      mouth,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.53, size.height * 0.70),
        width: size.width * 0.14,
        height: size.height * 0.10,
      ),
      1.8,
      1.1,
      false,
      mouth,
    );

    final glow = Paint()
      ..color = purple.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;

    canvas.drawCircle(c, r + 2, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
