import 'package:flutter/material.dart';

class ShopItemVisual extends StatelessWidget {
  final String itemId;
  final double size;

  const ShopItemVisual({super.key, required this.itemId, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (itemId) {
      case 'hat_red':
        return _buildRedHat();
      case 'hat_crown':
        return _buildCrown();
      case 'face_glasses':
        return _buildGlasses();
      case 'bg_forest':
        return _buildForestBg();
      case 'bg_space':
        return _buildSpaceBg();
      case 'hat_straw':
        return _buildStrawHat();
      case 'hat_wizard':
        return _buildWizardHat();
      case 'hat_party':
        return _buildPartyHat();
      case 'face_mustache':
        return _buildMustache();
      case 'face_blush':
        return _buildBlush();
      case 'face_mask':
        return _buildMask();
      case 'bg_beach':
        return _buildBeachBg();
      case 'bg_city':
        return _buildCityBg();
      case 'bg_snow':
        return _buildSnowBg();
      default:
        return Icon(Icons.star, size: size, color: Colors.amber);
    }
  }

  Widget _buildStrawHat() {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.3,
            child: Container(
              width: size,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.amber[300],
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Colors.amber[200],
                borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.25)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardHat() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * 0.1,
            child: Container(
              width: size,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.15,
            child: ClipPath(
              clipper: ConeClipper(),
              child: Container(
                width: size * 0.7,
                height: size * 0.8,
                color: Colors.deepPurple[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyHat() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * 0.1,
            child: ClipPath(
              clipper: ConeClipper(),
              child: Container(
                width: size * 0.6,
                height: size * 0.7,
                color: Colors.pinkAccent,
              ),
            ),
          ),
          Positioned(
            top: size * 0.1,
            child: Icon(Icons.star, color: Colors.yellow, size: size * 0.3),
          )
        ],
      ),
    );
  }

  Widget _buildMustache() {
    return SizedBox(
      width: size * 0.8,
      height: size * 0.4,
      child: Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.15,
          decoration: BoxDecoration(
            color: Colors.brown[800],
            borderRadius: BorderRadius.vertical(top: Radius.circular(size), bottom: Radius.circular(size * 0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildBlush() {
    return SizedBox(
      width: size * 1.4,
      height: size * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: size * 0.35,
            height: size * 0.25,
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.35,
            height: size * 0.25,
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMask() {
    return SizedBox(
      width: size * 0.7,
      height: size * 0.4,
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildBeachBg() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[200]!, Colors.yellow[100]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: size * 0.1, left: size * 0.1,
            child: Icon(Icons.beach_access, size: size * 0.5, color: Colors.orange),
          ),
          Positioned(
            top: size * 0.1, right: size * 0.1,
            child: Icon(Icons.wb_sunny, size: size * 0.3, color: Colors.yellow[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCityBg() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B4058), Color(0xFF1E2135)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0, left: size * 0.1,
            child: Icon(Icons.location_city, size: size * 0.5, color: Colors.indigo[300]),
          ),
          Positioned(
            bottom: 0, right: size * 0.1,
            child: Icon(Icons.location_city, size: size * 0.6, color: Colors.indigo[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSnowBg() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[100]!, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0, left: size * 0.1,
            child: Icon(Icons.ac_unit, size: size * 0.3, color: Colors.lightBlue[200]),
          ),
          Positioned(
            bottom: size * 0.2, right: size * 0.2,
            child: Icon(Icons.ac_unit, size: size * 0.4, color: Colors.lightBlue[100]),
          ),
          Positioned(
            top: size * 0.1, left: size * 0.4,
            child: Icon(Icons.ac_unit, size: size * 0.25, color: Colors.blue[200]),
          ),
        ],
      ),
    );
  }

  Widget _buildRedHat() {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 모자 바디 (위가 둥글고 아래가 평평)
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.7,
              height: size * 0.6,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // 모자 챙 (가로로 길게)
          Positioned(
            bottom: size * 0.2,
            right: 0, // 오른쪽을 바라보는 캡 챙
            child: Container(
              width: size * 0.8,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrown() {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CrownPainter(color: Colors.amber),
      ),
    );
  }

  Widget _buildGlasses() {
    return SizedBox(
      width: size * 1.4,
      height: size * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 왼쪽 알
          Container(
            width: size * 0.55,
            height: size * 0.45,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // 안경 코받침 연결부
          Container(
            width: size * 0.18,
            height: size * 0.06,
            color: Colors.black87,
          ),
          // 오른쪽 알
          Container(
            width: size * 0.55,
            height: size * 0.45,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForestBg() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[300]!, Colors.lightGreen[100]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0, left: size * 0.1,
            child: Icon(Icons.park, size: size * 0.4, color: Colors.green[800]),
          ),
          Positioned(
            bottom: 0, right: size * 0.05,
            child: Icon(Icons.park, size: size * 0.6, color: Colors.green[700]),
          ),
          Positioned(
            bottom: size * 0.1, left: size * 0.4,
            child: Icon(Icons.park, size: size * 0.3, color: Colors.green[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceBg() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          radius: 0.8,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Stack(
        children: [
          Positioned(top: size*0.1, left: size*0.2, child: Icon(Icons.star, size: size*0.1, color: Colors.yellow[200])),
          Positioned(top: size*0.3, right: size*0.2, child: Icon(Icons.star, size: size*0.08, color: Colors.white)),
          Positioned(bottom: size*0.2, left: size*0.3, child: Icon(Icons.star, size: size*0.12, color: Colors.yellow[100])),
          Positioned(bottom: size*0.4, right: size*0.1, child: Icon(Icons.nights_stay, size: size*0.3, color: Colors.white70)),
        ],
      ),
    );
  }
}

class CrownPainter extends CustomPainter {
  final Color color;
  CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width * 0.9, size.height * 0.2); // Right peak
    path.lineTo(size.width * 0.7, size.height * 0.5); // Right inner dip
    path.lineTo(size.width * 0.5, size.height * 0.1); // Middle peak
    path.lineTo(size.width * 0.3, size.height * 0.5); // Left inner dip
    path.lineTo(size.width * 0.1, size.height * 0.2); // Left peak
    path.close();
    
    canvas.drawPath(path, paint);

    // Add jewels
    var jewelPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), size.width * 0.05, jewelPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.1), size.width * 0.05, jewelPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), size.width * 0.05, jewelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.5, 0); // Top center
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
