import 'package:flutter/material.dart';

class AppDesignSystem extends ThemeExtension<AppDesignSystem> {
  final double cardRadius;
  final double buttonRadius;
  final double defaultPadding;
  final Color slateAlpha;

  AppDesignSystem({
    required this.cardRadius,
    required this.buttonRadius,
    required this.defaultPadding,
    required this.slateAlpha,
  });

  @override
  ThemeExtension<AppDesignSystem> copyWith({
    double? cardRadius,
    double? buttonRadius,
    double? defaultPadding,
    Color? slateAlpha,
  }) {
    return AppDesignSystem(
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      slateAlpha: slateAlpha ?? this.slateAlpha,
    );
  }

  @override
  ThemeExtension<AppDesignSystem> lerp(
    ThemeExtension<AppDesignSystem>? other,
    double t,
  ) {
    if (other is! AppDesignSystem) return this;
    return AppDesignSystem(
      cardRadius: cardRadius, // 고정값 보간
      buttonRadius: buttonRadius,
      defaultPadding: defaultPadding,
      slateAlpha: Color.lerp(slateAlpha, other.slateAlpha, t) ?? slateAlpha,
    );
  }
}
