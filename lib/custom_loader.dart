import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom rolling loader animation ported from CSS to Flutter.
///
/// This widget displays an animated orange square that rolls along a diagonal line,
/// recreating the exact animation from the original CSS.
///
/// Example usage:
/// ```dart
/// RollingLoader(
///   size: 88.0,
///   lineColor: Colors.white,
///   squareColor: Colors.orange,
/// )
/// ```
class RollingLoader extends StatefulWidget {
  /// The overall size of the loader in logical pixels.
  final double size;

  /// The color of the diagonal line.
  final Color lineColor;

  /// The color of the rolling square.
  final Color squareColor;

  /// The width of the diagonal line.
  final double lineWidth;

  /// The duration of one complete animation cycle.
  final Duration duration;

  /// Creates a rolling loader animation.
  ///
  /// [size] defaults to 88.0 (equivalent to 5.5em at 16px).
  /// [lineColor] defaults to white.
  /// [squareColor] defaults to orange.
  /// [lineWidth] defaults to 4.0.
  /// [duration] defaults to 2500 milliseconds.
  const RollingLoader({
    Key? key,
    this.size = 88.0,
    this.lineColor = Colors.white,
    this.squareColor = Colors.orange,
    this.lineWidth = 4.0,
    this.duration = const Duration(milliseconds: 2500),
  }) : super(key: key);

  @override
  _RollingLoaderState createState() => _RollingLoaderState();
}

class _RollingLoaderState extends State<RollingLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Create cubic bezier curve to match the CSS cubic-bezier(.79, 0, .47, .97)
  late final Curve _customCurve = Cubic(0.79, 0.0, 0.47, 0.97);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void didUpdateWidget(RollingLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the square size as a proportion of the overall size
    final double squareSize = widget.size / 5.5;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none, // Allow square to move outside the boundaries
          children: [
            // The diagonal line (equivalent to :before)
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: 45 * math.pi / 180, // 45 degrees in radians
                  child: Container(
                    height: widget.size,
                    width: widget.lineWidth,
                    color: widget.lineColor,
                  ),
                ),
              ),
            ),
            // The orange square (equivalent to :after)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final curvedValue = _customCurve.transform(_controller.value);
                final transform = _getRollingTransform(curvedValue, widget.size, squareSize);

                return Positioned(
                  left: 0.036 * widget.size, // 0.2em equivalent
                  bottom: 0.033 * widget.size, // 0.18em equivalent
                  child: Transform(
                    alignment: Alignment.center,
                    transform: transform,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  color: widget.squareColor,
                  borderRadius: BorderRadius.circular(squareSize * 0.15), // 15% border radius
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to replicate the CSS animation keyframes
  Matrix4 _getRollingTransform(double animationValue, double totalSize, double squareSize) {
    // Keyframes based on the original CSS animation - using non-const map with int keys
    final keyframes = {
      0: {'x': 0.0, 'y': -1.0, 'rotate': -45.0},
      5: {'x': 0.0, 'y': -1.0, 'rotate': -50.0},
      20: {'x': 1.0, 'y': -2.0, 'rotate': 47.0},
      25: {'x': 1.0, 'y': -2.0, 'rotate': 45.0},
      30: {'x': 1.0, 'y': -2.0, 'rotate': 40.0},
      45: {'x': 2.0, 'y': -3.0, 'rotate': 137.0},
      50: {'x': 2.0, 'y': -3.0, 'rotate': 135.0},
      55: {'x': 2.0, 'y': -3.0, 'rotate': 130.0},
      70: {'x': 3.0, 'y': -4.0, 'rotate': 217.0},
      75: {'x': 3.0, 'y': -4.0, 'rotate': 220.0},
      100: {'x': 0.0, 'y': -1.0, 'rotate': -225.0},
    };

    // Convert the animation value to a percentage (0-100)
    final percentValue = (animationValue * 100).toInt();

    // Find the keyframes to interpolate between
    int startKey = 0;
    int endKey = 100;

    final keys = keyframes.keys.toList()..sort();
    for (int i = 0; i < keys.length - 1; i++) {
      if (percentValue >= keys[i] && percentValue <= keys[i + 1]) {
        startKey = keys[i];
        endKey = keys[i + 1];
        break;
      }
    }

    // Calculate the interpolation factor
    final factor = percentValue == startKey ? 0.0 : (percentValue - startKey) / (endKey - startKey).toDouble();

    // Get the start and end values
    final startValues = keyframes[startKey]!;
    final endValues = keyframes[endKey]!;

    // Base unit for scaling - making it proportional to the widget size
    final baseUnit = totalSize / 5.5;

    // Interpolate the values
    final translateX = _lerp(startValues['x']! * baseUnit, endValues['x']! * baseUnit, factor);
    final translateY = _lerp(startValues['y']! * baseUnit, endValues['y']! * baseUnit, factor);
    final rotate = _lerp(startValues['rotate']!, endValues['rotate']!, factor);

    // Create the transformation matrix with proper order of operations
    final Matrix4 transform = Matrix4.identity();

    // Apply transformations in correct order (as per CSS)
    transform.translate(translateX, translateY);
    transform.rotateZ(rotate * math.pi / 180);

    return transform;
  }

  // Linear interpolation helper
  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }
}



