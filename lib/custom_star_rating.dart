import 'package:flutter/material.dart';

/// A customizable star rating widget with animations matching the provided HTML/CSS design.
/// Supports hover effects, selection animations, and configurable appearance.
class StarRating extends StatefulWidget {
  /// Number of stars to display (default: 5).
  final int starCount;

  /// Size of each star in pixels (default: 32.0, matching 2rem).
  final double size;

  /// Spacing between stars in pixels (default: 3.0, matching 0.3rem gap).
  final double spacing;

  /// Initial rating (0 to starCount, default: 0).
  final double initialRating;

  /// Color of the star stroke when unselected (default: #666666).
  final Color strokeColor;

  /// Color of the star fill and stroke when selected or hovered (default: #ffc73a).
  final Color fillColor;

  /// Whether the widget is interactive (default: true).
  final bool isEnabled;

  /// Callback triggered when the rating changes. Returns the new rating (1 to starCount).
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    this.starCount = 5,
    this.size = 32.0,
    this.spacing = 3.0,
    this.initialRating = 0,
    this.strokeColor = const Color(0xFF666666),
    this.fillColor = const Color(0xFFFFC73A),
    this.isEnabled = true,
    this.onRatingChanged,
  }) : assert(starCount > 0, 'starCount must be greater than 0'),
        assert(size > 0, 'size must be greater than 0'),
        assert(spacing >= 0, 'spacing must be non-negative'),
        assert(initialRating >= 0 && initialRating <= starCount, 'initialRating must be between 0 and starCount');

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> with TickerProviderStateMixin {
  int? _selectedIndex;
  int? _hoveredIndex;
  late List<AnimationController> _idleControllers;
  late List<AnimationController> _yippeeControllers;

  @override
  void initState() {
    super.initState();
    // Set initial rating
    _selectedIndex = widget.initialRating.round() - 1;

    // Initialize animation controllers
    _idleControllers = List.generate(
      widget.starCount,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(),
    );
    _yippeeControllers = List.generate(
      widget.starCount,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      ),
    );

    // Trigger yippee animation for initially selected stars
    if (_selectedIndex != null && _selectedIndex! >= 0) {
      for (int i = 0; i <= _selectedIndex!; i++) {
        _yippeeControllers[i].forward();
      }
    }
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.starCount != widget.starCount) {
      // Stop and dispose old controllers
      _idleControllers.forEach((controller) => controller.stop());
      _idleControllers.forEach((controller) => controller.dispose());
      _yippeeControllers.forEach((controller) => controller.stop());
      _yippeeControllers.forEach((controller) => controller.dispose());

      // Reinitialize controllers
      _idleControllers = List.generate(
        widget.starCount,
            (_) => AnimationController(
          vsync: this,
          duration: const Duration(seconds: 4),
        )..repeat(),
      );
      _yippeeControllers = List.generate(
        widget.starCount,
            (_) => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 750),
        ),
      );
    }
    if (oldWidget.initialRating != widget.initialRating) {
      if (mounted) {
        setState(() {
          _selectedIndex = widget.initialRating.round() - 1;
          // Reset and trigger animations for new selection
          for (var controller in _yippeeControllers) {
            controller.reset();
          }
          if (_selectedIndex != null && _selectedIndex! >= 0) {
            for (int i = 0; i <= _selectedIndex!; i++) {
              _yippeeControllers[i].forward();
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Stop all animations before disposal
    for (var controller in _idleControllers) {
      controller.stop();
      controller.dispose();
    }
    for (var controller in _yippeeControllers) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (!widget.isEnabled || !mounted) return;
    setState(() {
      _selectedIndex = index;
      // Trigger yippee animation for selected stars
      for (int i = 0; i < widget.starCount; i++) {
        _yippeeControllers[i].reset();
        if (i <= index) {
          _yippeeControllers[i].forward();
        }
      }
      widget.onRatingChanged?.call(index + 1);
    });
  }

  void _onEnter(int index) {
    if (!widget.isEnabled || !mounted) return;
    setState(() {
      _hoveredIndex = index;
    });
  }

  void _onExit(int index) {
    if (!widget.isEnabled || !mounted) return;
    setState(() {
      _hoveredIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.rtl, // Match CSS row-reverse
      children: List.generate(
        widget.starCount,
            (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: MouseRegion(
            onEnter: (_) => _onEnter(index),
            onExit: (_) => _onExit(index),
            child: GestureDetector(
              onTap: () => _onTap(index),
              child: StarWidget(
                size: widget.size,
                isSelected: _selectedIndex != null && index <= _selectedIndex!,
                isHovered: _hoveredIndex != null && index <= _hoveredIndex!,
                idleController: _idleControllers[index],
                yippeeController: _yippeeControllers[index],
                strokeColor: widget.strokeColor,
                fillColor: widget.fillColor,
                isEnabled: widget.isEnabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StarWidget extends StatelessWidget {
  final double size;
  final bool isSelected;
  final bool isHovered;
  final AnimationController idleController;
  final AnimationController yippeeController;
  final Color strokeColor;
  final Color fillColor;
  final bool isEnabled;

  const StarWidget({
    super.key,
    required this.size,
    required this.isSelected,
    required this.isHovered,
    required this.idleController,
    required this.yippeeController,
    required this.strokeColor,
    required this.fillColor,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([idleController, yippeeController]),
      builder: (context, _) {
        // Idle animation: stroke dash offset from 24 to 0
        final idleAnimation = Tween<double>(begin: 24, end: 0).animate(
          CurvedAnimation(parent: idleController, curve: Curves.linear),
        );

        // Yippee animation: scale and style changes
        final scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 30.0),
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 0.1),
          TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 29.9),
          TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 40.0),
        ]).animate(CurvedAnimation(parent: yippeeController, curve: Curves.easeInOut));

        final fillOpacityAnimation = TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 30.0),
          TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 70.0),
        ]).animate(yippeeController);

        final strokeWidthAnimation = TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 30.0),
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 8.0), weight: 0.1),
          TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: 8.0), weight: 69.9),
        ]).animate(yippeeController);

        final strokeDashArrayAnimation = TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: 10.0), weight: 30.0),
          TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: 0.0), weight: 0.1),
          TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 69.9),
        ]).animate(yippeeController);

        final strokeOpacityAnimation = TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 30.0),
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 70.0),
        ]).animate(yippeeController);

        return Transform.scale(
          scale: isSelected ? scaleAnimation.value : 1.0,
          child: CustomPaint(
            size: Size(size, size),
            painter: StarPainter(
              strokeColor: isSelected || (isEnabled && isHovered) ? fillColor : strokeColor,
              fillColor: fillColor,
              strokeWidth: isSelected ? strokeWidthAnimation.value : 1.0,
              fillOpacity: isSelected ? fillOpacityAnimation.value : 0.0,
              strokeDashArray: isSelected ? strokeDashArrayAnimation.value : 12.0,
              strokeDashOffset: isSelected ? 0.0 : idleAnimation.value,
              strokeOpacity: isSelected ? strokeOpacityAnimation.value : 1.0,
              isSelected: isSelected,
            ),
          ),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final double fillOpacity;
  final double strokeDashArray;
  final double strokeDashOffset;
  final double strokeOpacity;
  final bool isSelected;

  StarPainter({
    required this.strokeColor,
    required this.fillColor,
    required this.strokeWidth,
    required this.fillOpacity,
    required this.strokeDashArray,
    required this.strokeDashOffset,
    required this.strokeOpacity,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor.withOpacity(fillOpacity);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor.withOpacity(strokeOpacity)
      ..strokeWidth = strokeWidth
      ..strokeJoin = isSelected ? StrokeJoin.miter : StrokeJoin.bevel;

    // Define star path (normalized from SVG path)
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.708) // 12, 17.27
      ..lineTo(size.width * 0.759, size.height * 0.875) // 18.18, 21
      ..lineTo(size.width * 0.689, size.height * 0.582) // 16.54, 13.97
      ..lineTo(size.width * 0.917, size.height * 0.385) // 22, 9.24
      ..lineTo(size.width * 0.617, size.height * 0.359) // 14.81, 8.62
      ..lineTo(size.width * 0.5, size.height * 0.083) // 12, 2
      ..lineTo(size.width * 0.383, size.height * 0.359) // 9.19, 8.62
      ..lineTo(size.width * 0.083, size.height * 0.385) // 2, 9.24
      ..lineTo(size.width * 0.311, size.height * 0.582) // 7.45, 13.97
      ..lineTo(size.width * 0.242, size.height * 0.875) // 5.82, 21
      ..close();

    // Apply stroke dash effect
    if (strokeDashArray > 0) {
      final dashPath = Path();
      final dashArray = [strokeDashArray, strokeDashArray];
      var dashOffset = strokeDashOffset;
      final pathMetrics = path.computeMetrics();
      for (var metric in pathMetrics) {
        var start = dashOffset % (strokeDashArray * 2);
        while (start < metric.length) {
          final end = (start + strokeDashArray).clamp(0.0, metric.length);
          dashPath.addPath(metric.extractPath(start, end), Offset.zero);
          start += strokeDashArray * 2;
        }
        dashOffset -= metric.length;
      }
      canvas.drawPath(dashPath, strokePaint);
    } else {
      canvas.drawPath(path, strokePaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor ||
          oldDelegate.fillColor != fillColor ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.fillOpacity != fillOpacity ||
          oldDelegate.strokeDashArray != strokeDashArray ||
          oldDelegate.strokeDashOffset != strokeDashOffset ||
          oldDelegate.strokeOpacity != strokeOpacity ||
          oldDelegate.isSelected != isSelected;
}


// import 'package:flutter/material.dart';
// import 'custom_star_rating.dart';
// import 'custom_switch.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
//
//   @override
//   void dispose() {
//     _themeMode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: _themeMode,
//       builder: (context, themeMode, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData.light(),
//           darkTheme: ThemeData.dark(),
//           themeMode: themeMode,
//           home: Scaffold(
//             body: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                   child: CustomSwitch(
//                     width: 220,
//                     height: 110,
//                     onThemeChanged: (isLightMode) {
//                       _themeMode.value = isLightMode ? ThemeMode.light : ThemeMode.dark;
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 StarRating(
//                   starCount: 5,
//                   size: 32.0,
//                   spacing: 3.0,
//                   initialRating: 2,
//                   isEnabled: true,
//                   onRatingChanged: (rating) {
//                     print('New rating: $rating');
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 const StarRating(starCount: 3, size: 24.0, initialRating: 1, isEnabled: false, strokeColor: Colors.blueGrey, fillColor: Colors.amber),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
//


