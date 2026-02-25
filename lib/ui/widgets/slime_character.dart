import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import '../../data/models/shop_item.dart';
import '../shop/shop_item_visual.dart';

enum SlimeState { hungry, active, party }

class SlimeCharacter extends StatefulWidget {
  final int currentSteps;
  final int dailyGoal;
  final int totalLifetimeSteps; // For evolution
  final VoidCallback? onMultiTap;
  final List<ShopItem> equippedItems;

  const SlimeCharacter({
    super.key,
    required this.currentSteps,
    required this.dailyGoal,
    this.totalLifetimeSteps = 0,
    this.onMultiTap,
    this.equippedItems = const [],
  });

  @override
  _SlimeCharacterState createState() => _SlimeCharacterState();
}

class _SlimeCharacterState extends State<SlimeCharacter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _waveController;
  late Animation<double> _breatheAnimation;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get progress => (widget.currentSteps / widget.dailyGoal).clamp(0.0, 1.0);

  SlimeState get currentState {
    if (progress < 0.2) return SlimeState.hungry;
    if (progress >= 1.0) return SlimeState.party;
    return SlimeState.active;
  }

  int get evolutionLevel {
    if (widget.totalLifetimeSteps >= 100000) return 3;
    if (widget.totalLifetimeSteps >= 10000) return 2;
    return 1;
  }

  Color get slimeColor {
    // Interpolate from Pale Mint to Main Mint based on progress
    return Color.lerp(const Color(0xFFD1EAEF), const Color(0xFFA7D8DE), progress) ??
        const Color(0xFFA7D8DE);
  }

  String speechText(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (currentState) {
      case SlimeState.hungry:
        return localizations.slimeSpeechHungry(widget.dailyGoal - widget.currentSteps);
      case SlimeState.active:
        return localizations.slimeSpeechActive;
      case SlimeState.party:
        return localizations.slimeSpeechParty;
    }
  }

  Widget _buildEvolutionDeco() {
    if (evolutionLevel == 3) {
      return Positioned(
        top: -20,
        child: Text("👑", style: TextStyle(fontSize: 40)),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildEyes({required bool isHungry}) {
    double size = isHungry ? 6 : 9;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: Color(0xFF2E2E2E), shape: BoxShape.circle),
        ),
        const SizedBox(width: 25),
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: Color(0xFF2E2E2E), shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildFace() {
    switch (currentState) {
      case SlimeState.hungry:
        return _buildEyes(isHungry: true);
      case SlimeState.party:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
            SizedBox(width: 25),
            Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
          ],
        );
      case SlimeState.active:
      default:
        return _buildEyes(isHungry: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseSize = evolutionLevel == 1
        ? 100.0
        : evolutionLevel == 2
            ? 130.0
            : 160.0;

    Widget speechBubble = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 4),
                blurRadius: 4,
              )
            ],
          ),
          child: Text(
            speechText(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        CustomPaint(
          painter: TrianglePainter(strokeColor: Colors.white, paintingStyle: PaintingStyle.fill),
          child: SizedBox(
            height: 10,
            width: 20,
          ),
        ),
      ],
    );

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Opacity(
              opacity: 0,
              child: speechBubble,
            ),
            SizedBox(height: 10),
            // Animated Slime
            GestureDetector(
          onTap: () {
            _tapCount++;
            if (_tapCount >= 5) {
              _tapCount = 0;
              widget.onMultiTap?.call();
            }
          },
          child: AnimatedBuilder(
            animation: _breatheAnimation,
            builder: (context, child) {
            return Transform.scale(
              scale: currentState == SlimeState.hungry
                  ? 1.0 // Don't breathe much if hungry/tired
                  : _breatheAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none, // 아이템(모자 등)이 넘어갈 수 있게 허용
                children: [
                  _buildEvolutionDeco(),
                  CustomPaint(
                    painter: SlimeShadowPainter(shadowColor: slimeColor.withValues(alpha: 0.4)),
                    child: ClipPath(
                      clipper: SlimeClipper(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: baseSize,
                        height: baseSize,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFEBF4F5),
                              Color(0xFFD4E8EA),
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                final hsl = HSLColor.fromColor(slimeColor);
                                final darkerSlimeColor = hsl
                                    .withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0))
                                    .toColor();
                                return ClipPath(
                                  clipper: WaveClipper(
                                    animationValue: _waveController.value,
                                    progress: progress,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          slimeColor.withValues(alpha: 0.8),
                                          slimeColor,
                                          darkerSlimeColor,
                                        ],
                                      ),
                                    ),
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              },
                            ),
                            // 3D Glass/Sphere Effect Overlay
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(-0.35, -0.45),
                                  radius: 1.1,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.8), // Specular highlight
                                    Colors.white.withValues(alpha: 0.1), // Bright mid
                                    Colors.transparent, // Neutral
                                    Colors.black.withValues(alpha: 0.05), // Edge shadow
                                    Colors.black.withValues(alpha: 0.25), // Deep edge shadow
                                  ],
                                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: baseSize * 0.1),
                                child: _buildFace(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...widget.equippedItems.where((i) => i.category == 'face').map((face) => 
                     Center(
                       child: Padding(
                         padding: EdgeInsets.only(top: baseSize * 0.1),
                         child: ShopItemVisual(itemId: face.id, size: baseSize * 0.5)
                       )
                     )
                  ),
                  ...widget.equippedItems.where((i) => i.category == 'head').map((head) => 
                     Positioned(
                        top: -baseSize * 0.12, // 모자 위치 조정 (슬라임 머리에 맞게 내림)
                        child: ShopItemVisual(itemId: head.id, size: baseSize * 0.6)
                     )
                  ),
                ],
              ),
            );
          },
        ),
        ),
          ],
        ),
        Positioned(
          top: 0,
          child: speechBubble,
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x / 2, y)
      ..lineTo(x, 0)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animationValue; 
  final double progress; 

  WaveClipper({required this.animationValue, required this.progress});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (progress <= 0.0) return path;
    if (progress >= 1.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    double waterHeight = size.height * (1 - progress);
    double waveAmplitude = 10.0; 
    
    path.moveTo(0, waterHeight);
    
    for (double x = 0; x <= size.width; x++) {
      double y = waterHeight + sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * waveAmplitude;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return oldClipper.animationValue != animationValue || oldClipper.progress != progress;
  }
}

class SlimeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final w = size.width;
    final h = size.height;
    
    path.moveTo(w * 0.5, h * 0.1); 
    path.cubicTo(w * 0.75, h * 0.1, w * 0.95, h * 0.3, w * 0.95, h * 0.6);
    path.cubicTo(w * 0.95, h * 0.85, w * 0.8, h * 0.925, w * 0.5, h * 0.925);
    path.cubicTo(w * 0.2, h * 0.925, w * 0.05, h * 0.85, w * 0.05, h * 0.6);
    path.cubicTo(w * 0.05, h * 0.3, w * 0.25, h * 0.1, w * 0.5, h * 0.1);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class SlimeShadowPainter extends CustomPainter {
  final Color shadowColor;
  SlimeShadowPainter({required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = SlimeClipper().getClip(size);
    // Draw an ambient, softer shadow behind
    canvas.drawShadow(path, shadowColor, 12, false);
    
    // Draw a sharper, darker directional shadow slightly shifted downwards
    canvas.drawShadow(path.shift(const Offset(0, 4)), shadowColor.withValues(alpha: 0.7), 8, false);
  }

  @override
  bool shouldRepaint(covariant SlimeShadowPainter oldDelegate) {
    return oldDelegate.shadowColor != shadowColor;
  }
}
