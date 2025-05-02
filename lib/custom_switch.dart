import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final double width;
  final double height;
  final ValueChanged<bool>? onThemeChanged;

  const CustomSwitch({super.key, required this.width, required this.height, this.onThemeChanged});

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  bool isLightMode = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  double get widthScale => widget.width / 220;

  double get heightScale => widget.height / 110;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLightMode = !isLightMode;
      _controller.forward(from: 0.0);
      widget.onThemeChanged?.call(isLightMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sunMoonSize = 90 * heightScale;
    final borderRadius = 55 * widthScale;
    final borderWidth = 1 * widthScale;
    final sunMoonLeftPosition = isLightMode ? 10 * widthScale : (widget.width - sunMoonSize - 10 * widthScale);
    final topPadding = 10 * heightScale;

    return GestureDetector(
      onTap: toggleMode,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: borderWidth),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15 * widthScale, offset: Offset(0, 5 * heightScale)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10 * widthScale, spreadRadius: -5 * widthScale, offset: const Offset(0, 0)),
          ],
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius - borderWidth),
                gradient: LinearGradient(
                  colors: isLightMode ? [const Color(0xFFFFDAB9), const Color(0xFF87CEEB)] : [const Color(0xFF191970), const Color(0xFF000000)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Visibility(
                visible: isLightMode,
                child: Stack(
                  children: [
                    // Larger fluffy cloud
                    Positioned(
                      top: 15 * heightScale,
                      right: 30 * widthScale,
                      child: Container(
                        width: 50 * widthScale,
                        height: 25 * heightScale,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12 * widthScale),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5 * widthScale, offset: Offset(2 * widthScale, 2 * heightScale)),
                          ],
                        ),
                      ),
                    ),
                    // Medium cloud with slightly different position
                    Positioned(
                      top: 35 * heightScale,
                      right: 50 * widthScale,
                      child: Container(
                        width: 35 * widthScale,
                        height: 18 * heightScale,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(9 * widthScale),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5 * widthScale, offset: Offset(2 * widthScale, 2 * heightScale)),
                          ],
                        ),
                      ),
                    ),
                    // Small cloud
                    Positioned(
                      top: 25 * heightScale,
                      right: 70 * widthScale,
                      child: Container(
                        width: 30 * widthScale,
                        height: 15 * heightScale,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8 * widthScale),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5 * widthScale, offset: Offset(2 * widthScale, 2 * heightScale)),
                          ],
                        ),
                      ),
                    ),
                    // Add a few smaller cloud puffs for more realism
                    Positioned(
                      top: 20 * heightScale,
                      right: 45 * widthScale,
                      child: Container(
                        width: 20 * widthScale,
                        height: 10 * heightScale,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(7 * widthScale),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4 * widthScale, offset: Offset(1 * widthScale, 1 * heightScale)),
                          ],
                        ),
                      ),
                    ),
                    // Additional cloud detail
                    Positioned(
                      top: 28 * heightScale,
                      right: 85 * widthScale,
                      child: Container(
                        width: 25 * widthScale,
                        height: 12 * heightScale,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(6 * widthScale),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3 * widthScale, offset: Offset(1 * widthScale, 1 * heightScale)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Visibility(
                visible: !isLightMode,
                child: Stack(
                  children: [
                    Positioned(
                      top: 15 * heightScale,
                      left: 40 * widthScale,
                      child: Container(
                        width: 6 * widthScale,
                        height: 6 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.9),
                          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 5 * widthScale, spreadRadius: 1 * widthScale)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40 * heightScale,
                      left: 30 * widthScale,
                      child: Container(
                        width: 4 * widthScale,
                        height: 4 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.7),
                          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 4 * widthScale, spreadRadius: 1 * widthScale)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25 * heightScale,
                      left: 50 * widthScale,
                      child: Container(
                        width: 5 * widthScale,
                        height: 5 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8),
                          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.25), blurRadius: 4 * widthScale, spreadRadius: 1 * widthScale)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 35 * heightScale,
                      left: 60 * widthScale,
                      child: Container(
                        width: 3 * widthScale,
                        height: 3 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.6),
                          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.15), blurRadius: 3 * widthScale, spreadRadius: 1 * widthScale)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: sunMoonLeftPosition,
              top: topPadding,
              child:
              isLightMode
                  ? Container(
                width: sunMoonSize,
                height: sunMoonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700),
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFE066), Color(0xFFFFA500)],
                    center: Alignment(-0.3, -0.3),
                    focal: Alignment(-0.3, -0.3),
                    focalRadius: 0.1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 15 * widthScale, spreadRadius: 5 * widthScale),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5 * widthScale, offset: Offset(3 * widthScale, 3 * heightScale)),
                  ],
                ),
              )
                  : Container(
                width: sunMoonSize,
                height: sunMoonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD3D3D3),
                  gradient: const RadialGradient(
                    colors: [Color(0xFFE8E8E8), Color(0xFFA9A9A9)],
                    center: Alignment(-0.3, -0.3),
                    focal: Alignment(-0.3, -0.3),
                    focalRadius: 0.1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 15 * widthScale, spreadRadius: 5 * widthScale),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5 * widthScale, offset: Offset(3 * widthScale, 3 * heightScale)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 25 * heightScale,
                      left: 20 * widthScale,
                      child: Container(
                        width: 25 * widthScale,
                        height: 25 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3 * widthScale,
                              offset: Offset(2 * widthScale, 2 * heightScale),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50 * heightScale,
                      left: 40 * widthScale,
                      child: Container(
                        width: 15 * widthScale,
                        height: 15 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3 * widthScale,
                              offset: Offset(2 * widthScale, 2 * heightScale),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15 * heightScale,
                      left: 50 * widthScale,
                      child: Container(
                        width: 10 * widthScale,
                        height: 10 * heightScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3 * widthScale,
                              offset: Offset(2 * widthScale, 2 * heightScale),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}