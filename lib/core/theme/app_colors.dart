import 'package:flutter/material.dart';

class AppColors {
  // 인스턴스화하지 못하도록 private 생성자 정의
  AppColors._();
  // 라이트 모드 컬러들
  static const Color lightBackground = Color(0xFFF5F9F9); // 연한 민트 그레이
  static const Color lightPrimary = Color(0xFFA7D8DE); // 소프트 민트
  static const Color lightSecondary = Color(0xFFF9E076); // 레몬 옐로우
  static const Color darkSlateGray = Color(0xFF2F4F4F); // 다크 슬레이트 그레이
  // 다크 모드 컬러들
  static const Color darkBackground = Color(0xFF1E2729); // 연한 민트톤 다크 그레이
  static const Color darkPrimary = Color(0xFF7CB8BE); // 어두운 민트
  static const Color darkSecondary = Color(0xFFE5CC5A); // 어두운 레몬
  static const Color darkSurface = Color(0xFF283437);
  static const Color slateAlpha = Color(0xFF94A3B8);
  static const Color accentBlue = Colors.blueAccent;
  static const Color pointBlue = Color(0xFF1E88E5); // Colors.blue[600]에 상응
  static const Color warningOrange = Colors.orange;
  static const Color orangeAccent = Colors.orangeAccent;
  static const Color greenAccent = Colors.greenAccent;
  static const Color grey200 = Color(0xFFEEEEEE); // Colors.grey[200]
  static const Color grey800 = Color(0xFF424242); // Colors.grey[800]
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white24 = Colors.white24;
}
