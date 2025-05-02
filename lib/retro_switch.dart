import 'package:flutter/material.dart';
import 'dart:math';

// A customizable retro-style switch widget with toggle animation and visual effects.
class RetroSwitch extends StatefulWidget {
  final double width;
  final double height;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color glowColor;
  final Color textColor;

  const RetroSwitch({
    super.key,
    this.width = 150.0,
    this.height = 195.0,
    this.initialValue = false,
    this.onChanged,
    this.activeColor = const Color(0xFF980000),
    this.inactiveColor = const Color(0xFF6F0000),
    this.glowColor = const Color(0xFFFF1818),
    this.textColor = Colors.white,
  });

  @override
  _RetroSwitchState createState() => _RetroSwitchState();
}

class _RetroSwitchState extends State<RetroSwitch> with SingleTickerProviderStateMixin {
  late bool isChecked;
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;

    // Initialize animation controller for flicker effect
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _flickerAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _flickerController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flickerController.reverse();
      } else if (status == AnimationStatus.dismissed && isChecked) {
        _flickerController.forward();
      }
    });
    if (isChecked) {
      _flickerController.forward();
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  void _toggleSwitch() {
    setState(() {
      isChecked = !isChecked;
      if (isChecked) {
        _flickerController.forward();
      } else {
        _flickerController.stop();
      }
      widget.onChanged?.call(isChecked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSwitch,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: CustomPaint(
          painter: InsetShadowPainter(),
          size: Size(widget.width, widget.height),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(isChecked ? pi / 7.2 : -pi / 7.2) // 25 degrees
                ..translate(0.0, 0.0, 20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.activeColor,
                      widget.inactiveColor,
                      widget.inactiveColor,
                      widget.activeColor,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  boxShadow: isChecked
                      ? [BoxShadow(color: widget.glowColor, blurRadius: 20, offset: const Offset(0, -10))]
                      : [],
                ),
                child: Stack(
                  children: [
                    // Light effect when turned on
                    AnimatedBuilder(
                      animation: _flickerAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: isChecked ? _flickerAnimation.value : 0.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFFFC97E),
                                  Color(0x99FF1818),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.4, 0.7],
                                center: Alignment.center,
                                radius: 0.8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Dots pattern
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: DotsPainter(),
                    ),
                    // Characters (ON/OFF symbols)
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: CharactersPainter(textColor: widget.textColor),
                    ),
                    // Shine effect
                    AnimatedOpacity(
                      opacity: isChecked ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: ShinePainter(),
                      ),
                    ),
                    // Shadow effect
                    AnimatedOpacity(
                      opacity: isChecked ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: ShadowPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dots pattern
class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x650000).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    const dotSize = 10.0;
    for (var x = 0.0; x < size.width; x += dotSize) {
      for (var y = 0.0; y < size.height; y += dotSize) {
        canvas.drawCircle(
          Offset(x + dotSize / 2, y + dotSize / 2),
          dotSize * 0.35,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for ON/OFF symbols
class CharactersPainter extends CustomPainter {
  final Color textColor;

  CharactersPainter({required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;

    // Vertical line (I symbol for ON)
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.475,
        size.height * 0.2,
        size.width * 0.05,
        size.height * 0.2,
      ),
      paint,
    );

    // Circle (O symbol for OFF)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.8),
      size.width * 0.165,
      paint,
    );

    // Inner circle cutout
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.8),
      size.width * 0.12,
      Paint()..color = const Color(0xFF6F0000)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for shine effect
class ShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * 0.015,
      size.height * 0.015,
      size.width * 0.97,
      size.height * 0.97,
    );

    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [Colors.white, Colors.transparent],
      stops: const [0.0, 0.03],
    );

    canvas.drawRect(rect, Paint()..shader = topGradient.createShader(rect));

    final verticalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.5),
        Colors.transparent,
        Colors.transparent,
        Colors.white.withOpacity(0.5),
      ],
      stops: const [0.0, 0.5, 0.8, 1.0],
    );

    canvas.drawRect(rect, Paint()..shader = verticalGradient.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for shadow effect
class ShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
      stops: const [0.7, 1.0],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for inset shadow effect
class InsetShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw container background
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw white top edge highlight
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      const Offset(2, 2),
      Offset(size.width - 2, 2),
      whitePaint,
    );

    // Draw middle inset
    final purplePaint = Paint()
      ..color = const Color(0xFF47434C)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(15, 15, size.width - 15, size.height - 15),
      purplePaint,
    );

    // Draw black inner inset
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(22, 22, size.width - 22, size.height - 22),
      blackPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}